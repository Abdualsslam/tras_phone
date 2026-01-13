import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Order, OrderDocument } from './schemas/order.schema';
import { OrderItem, OrderItemDocument } from './schemas/order-item.schema';
import {
  OrderStatusHistory,
  OrderStatusHistoryDocument,
} from './schemas/order-status-history.schema';
import { Invoice, InvoiceDocument } from './schemas/invoice.schema';
import { Shipment, ShipmentDocument } from './schemas/shipment.schema';
import { Payment, PaymentDocument } from './schemas/payment.schema';
import { OrderNote, OrderNoteDocument } from './schemas/order-note.schema';
import {
  BankAccount,
  BankAccountDocument,
} from './schemas/bank-account.schema';
import { CartService } from './cart.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Orders Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(OrderItem.name)
    private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(OrderStatusHistory.name)
    private statusHistoryModel: Model<OrderStatusHistoryDocument>,
    @InjectModel(Invoice.name) private invoiceModel: Model<InvoiceDocument>,
    @InjectModel(Shipment.name) private shipmentModel: Model<ShipmentDocument>,
    @InjectModel(Payment.name) private paymentModel: Model<PaymentDocument>,
    @InjectModel(OrderNote.name)
    private orderNoteModel: Model<OrderNoteDocument>,
    @InjectModel(BankAccount.name)
    private bankAccountModel: Model<BankAccountDocument>,
    private cartService: CartService,
  ) {}

  /**
   * Create order from cart
   */
  async createOrder(customerId: string, data: any): Promise<OrderDocument> {
    const cart = await this.cartService.getCart(customerId);

    if (!cart.items.length) {
      throw new BadRequestException('Cart is empty');
    }

    const orderNumber = await this.generateOrderNumber();

    // Create order
    const order = await this.orderModel.create({
      orderNumber,
      customerId,
      status: 'pending',
      subtotal: cart.subtotal,
      taxAmount: cart.taxAmount,
      shippingCost: cart.shippingCost,
      discount: cart.discount,
      couponDiscount: cart.couponDiscount,
      total: cart.total,
      couponId: cart.couponId,
      couponCode: cart.couponCode,
      appliedPromotions: cart.appliedPromotions,
      shippingAddress: data.shippingAddress,
      shippingAddressId: data.shippingAddressId,
      paymentMethod: data.paymentMethod,
      customerNotes: data.notes,
      source: data.source || 'web',
      ...data,
    });

    // Create order items
    const orderItems = cart.items.map((item) => ({
      orderId: order._id,
      productId: item.productId,
      productSku: '', // Will be populated from product
      productName: '', // Will be populated from product
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
    }));

    await this.orderItemModel.insertMany(orderItems);

    // Record status history
    await this.recordStatusChange(
      order._id.toString(),
      '',
      'pending',
      'Order created',
      undefined,
      true,
    );

    // Convert cart
    await this.cartService.convertCart(customerId, order._id.toString());

    // Create invoice
    await this.createInvoice(order);

    return order;
  }

  /**
   * Find orders with filters
   */
  async findAll(
    filters?: any,
  ): Promise<{ data: OrderDocument[]; total: number }> {
    const {
      page = 1,
      limit = 20,
      customerId,
      status,
      paymentStatus,
      startDate,
      endDate,
      sort = 'createdAt',
      order = 'desc',
    } = filters || {};

    const query: any = {};

    if (customerId) query.customerId = customerId;
    if (status) query.status = status;
    if (paymentStatus) query.paymentStatus = paymentStatus;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const [data, total] = await Promise.all([
      this.orderModel
        .find(query)
        .populate('customerId', 'shopName responsiblePersonName phone')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ [sort]: order === 'desc' ? -1 : 1 }),
      this.orderModel.countDocuments(query),
    ]);

    return { data, total };
  }

  /**
   * Find order by ID or number
   */
  async findById(id: string): Promise<{
    order: OrderDocument;
    items: OrderItemDocument[];
    history: OrderStatusHistoryDocument[];
  }> {
    const query = Types.ObjectId.isValid(id)
      ? { _id: id }
      : { orderNumber: id };

    const order = await this.orderModel
      .findOne(query)
      .populate('customerId')
      .populate('shippingAddressId');

    if (!order) throw new NotFoundException('Order not found');

    const [items, history] = await Promise.all([
      this.orderItemModel
        .find({ orderId: order._id })
        .populate('productId', 'name nameAr mainImage'),
      this.statusHistoryModel
        .find({ orderId: order._id })
        .sort({ createdAt: 1 }),
    ]);

    return { order, items, history };
  }

  /**
   * Update order status
   */
  async updateStatus(
    orderId: string,
    newStatus: string,
    userId?: string,
    notes?: string,
  ): Promise<OrderDocument> {
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    const oldStatus = order.status;

    // Validate status transition
    this.validateStatusTransition(oldStatus, newStatus);

    // Update order
    const updateData: any = { status: newStatus };

    switch (newStatus) {
      case 'confirmed':
        updateData.confirmedAt = new Date();
        break;
      case 'shipped':
        updateData.shippedAt = new Date();
        break;
      case 'delivered':
        updateData.deliveredAt = new Date();
        break;
      case 'completed':
        updateData.completedAt = new Date();
        break;
      case 'cancelled':
        updateData.cancelledAt = new Date();
        updateData.cancellationReason = notes;
        break;
    }

    const updatedOrder = await this.orderModel.findByIdAndUpdate(
      orderId,
      { $set: updateData },
      { new: true },
    );

    if (!updatedOrder) {
      throw new NotFoundException('Order not found');
    }

    // Record history
    await this.recordStatusChange(
      orderId,
      oldStatus,
      newStatus,
      notes,
      userId,
      false,
    );

    // Update order items status
    await this.orderItemModel.updateMany(
      { orderId },
      { $set: { status: newStatus } },
    );

    return updatedOrder;
  }

  /**
   * Validate status transition
   */
  private validateStatusTransition(from: string, to: string): void {
    const validTransitions: Record<string, string[]> = {
      pending: ['confirmed', 'cancelled'],
      confirmed: ['processing', 'cancelled'],
      processing: ['ready_for_pickup', 'shipped', 'cancelled'],
      ready_for_pickup: ['shipped', 'cancelled'],
      shipped: ['out_for_delivery', 'delivered'],
      out_for_delivery: ['delivered'],
      delivered: ['completed', 'refunded'],
      completed: ['refunded'],
      cancelled: [],
      refunded: [],
    };

    if (!validTransitions[from]?.includes(to)) {
      throw new BadRequestException(`Cannot transition from ${from} to ${to}`);
    }
  }

  /**
   * Record status change
   */
  private async recordStatusChange(
    orderId: string,
    fromStatus: string,
    toStatus: string,
    notes?: string,
    changedBy?: string,
    isSystem: boolean = false,
  ): Promise<void> {
    await this.statusHistoryModel.create({
      orderId,
      fromStatus: fromStatus || 'new',
      toStatus,
      notes,
      changedBy,
      isSystemGenerated: isSystem,
    });
  }

  /**
   * Create invoice
   */
  private async createInvoice(order: OrderDocument): Promise<InvoiceDocument> {
    const invoiceNumber = await this.generateInvoiceNumber();

    return this.invoiceModel.create({
      invoiceNumber,
      orderId: order._id,
      customerId: order.customerId,
      subtotal: order.subtotal,
      taxAmount: order.taxAmount,
      shippingCost: order.shippingCost,
      discount: order.discount + order.couponDiscount,
      total: order.total,
      issueDate: new Date(),
      status: 'issued',
    });
  }

  /**
   * Create shipment
   */
  async createShipment(orderId: string, data: any): Promise<ShipmentDocument> {
    const { order, items } = await this.findById(orderId);
    const shipmentNumber = await this.generateShipmentNumber();

    return this.shipmentModel.create({
      shipmentNumber,
      orderId: order._id,
      warehouseId: order.warehouseId,
      status: 'pending',
      shippingAddress: order.shippingAddress,
      items: items.map((item) => ({
        orderItemId: item._id,
        productId: item.productId,
        quantity: item.quantity,
      })),
      ...data,
    });
  }

  /**
   * Update shipment status
   */
  async updateShipmentStatus(
    shipmentId: string,
    status: string,
    trackingNumber?: string,
  ): Promise<ShipmentDocument> {
    const updateData: any = { status };

    if (trackingNumber) updateData.trackingNumber = trackingNumber;

    switch (status) {
      case 'picked':
        updateData.pickedAt = new Date();
        break;
      case 'packed':
        updateData.packedAt = new Date();
        break;
      case 'shipped':
        updateData.shippedAt = new Date();
        break;
      case 'delivered':
        updateData.deliveredAt = new Date();
        break;
    }

    const shipment = await this.shipmentModel.findByIdAndUpdate(
      shipmentId,
      { $set: updateData },
      { new: true },
    );

    if (!shipment) throw new NotFoundException('Shipment not found');

    // Update order status if shipped or delivered
    if (['shipped', 'delivered'].includes(status)) {
      await this.updateStatus(shipment.orderId.toString(), status);
    }

    return shipment;
  }

  /**
   * Record payment
   */
  async recordPayment(orderId: string, data: any): Promise<PaymentDocument> {
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    const paymentNumber = await this.generatePaymentNumber();

    const payment = await this.paymentModel.create({
      paymentNumber,
      orderId,
      customerId: order.customerId,
      amount: data.amount,
      paymentMethod: data.paymentMethod,
      status: 'completed',
      paidAt: new Date(),
      ...data,
    });

    // Update order
    const newPaidAmount = order.paidAmount + data.amount;
    const paymentStatus = newPaidAmount >= order.total ? 'paid' : 'partial';

    await this.orderModel.findByIdAndUpdate(orderId, {
      $set: { paidAmount: newPaidAmount, paymentStatus },
    });

    // Update invoice
    await this.invoiceModel.findOneAndUpdate(
      { orderId },
      {
        $set: {
          paidAmount: newPaidAmount,
          status: paymentStatus,
          paidDate: new Date(),
        },
      },
    );

    return payment;
  }

  /**
   * Add note to order
   */
  async addNote(
    orderId: string,
    content: string,
    type: string,
    userId?: string,
  ): Promise<OrderNoteDocument> {
    return this.orderNoteModel.create({
      orderId,
      content,
      type,
      createdBy: userId,
    });
  }

  /**
   * Get order notes
   */
  async getNotes(orderId: string): Promise<OrderNoteDocument[]> {
    return this.orderNoteModel.find({ orderId }).sort({ createdAt: -1 });
  }

  // ═════════════════════════════════════
  // Number Generators
  // ═════════════════════════════════════

  private async generateOrderNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'ORD';
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');

    const count = await this.orderModel.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
    });

    return `${prefix}${year}${month}${day}${(count + 1).toString().padStart(4, '0')}`;
  }

  private async generateInvoiceNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'INV';
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');

    const count = await this.invoiceModel.countDocuments({
      createdAt: { $gte: new Date(date.getFullYear(), date.getMonth(), 1) },
    });

    return `${prefix}${year}${month}${(count + 1).toString().padStart(5, '0')}`;
  }

  private async generateShipmentNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'SHP';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.shipmentModel.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(3, '0')}`;
  }

  private async generatePaymentNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'PAY';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.paymentModel.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(3, '0')}`;
  }

  // ═════════════════════════════════════
  // Payment Management
  // ═════════════════════════════════════

  /**
   * Upload payment receipt
   */
  async uploadReceipt(orderId: string, data: any): Promise<OrderDocument> {
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    // Update order with receipt info
    order.transferReceiptImage = data.receiptImage;
    order.transferReference = data.transferReference;
    order.transferDate = data.transferDate
      ? new Date(data.transferDate)
      : undefined;
    order.paymentStatus = 'pending'; // Waiting for verification

    await order.save();

    // Add note
    if (data.notes) {
      await this.addNote(orderId, data.notes, 'payment_receipt');
    }

    return order;
  }

  /**
   * Verify payment (admin only)
   */
  async verifyPayment(
    orderId: string,
    verified: boolean,
    adminId: string,
    rejectionReason?: string,
    notes?: string,
  ): Promise<OrderDocument> {
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    if (verified) {
      order.transferVerifiedAt = new Date();
      order.transferVerifiedBy = new Types.ObjectId(adminId);
      order.paymentStatus = 'paid';
      order.paidAmount = order.total;

      // Record payment
      await this.recordPayment(orderId, {
        amount: order.total,
        paymentMethod: order.paymentMethod || 'bank_transfer',
        gatewayReference: order.transferReference,
      });
    } else {
      order.transferVerifiedAt = undefined;
      order.transferVerifiedBy = undefined;
      order.paymentStatus = 'unpaid';
      order.rejectionReason = rejectionReason;
    }

    await order.save();

    // Add note
    if (notes) {
      await this.addNote(
        orderId,
        notes,
        verified ? 'payment_verified' : 'payment_rejected',
        adminId,
      );
    }

    return order;
  }

  /**
   * Rate order
   */
  async rateOrder(
    orderId: string,
    customerId: string,
    rating: number,
    comment?: string,
  ): Promise<OrderDocument> {
    const order = await this.orderModel.findOne({
      _id: orderId,
      customerId: new Types.ObjectId(customerId),
    });

    if (!order) throw new NotFoundException('Order not found');

    // Can only rate delivered or completed orders
    if (!['delivered', 'completed'].includes(order.status)) {
      throw new BadRequestException(
        'Can only rate delivered or completed orders',
      );
    }

    order.customerRating = rating;
    order.customerRatingComment = comment;
    order.ratedAt = new Date();

    await order.save();

    return order;
  }

  /**
   * Get pending payment orders
   */
  async getPendingPaymentOrders(customerId?: string): Promise<OrderDocument[]> {
    const query: any = {
      paymentStatus: { $in: ['unpaid', 'partial'] },
      paymentMethod: 'bank_transfer',
    };

    if (customerId) {
      query.customerId = new Types.ObjectId(customerId);
    }

    return this.orderModel
      .find(query)
      .populate('customerId', 'shopName responsiblePersonName')
      .sort({ createdAt: -1 });
  }

  /**
   * Get bank accounts
   */
  async getBankAccounts(): Promise<BankAccountDocument[]> {
    return this.bankAccountModel
      .find({ isActive: true })
      .sort({ sortOrder: 1, isDefault: -1 });
  }
}
