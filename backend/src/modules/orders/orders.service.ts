import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
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
import { CouponsService } from '@modules/promotions/coupons.service';
import { PromotionsService } from '@modules/promotions/promotions.service';
import { ProductsService } from '@modules/products/products.service';
import { CreateOrderDto } from './dto/create-order.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Orders Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

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
    private couponsService: CouponsService,
    private promotionsService: PromotionsService,
    private productsService: ProductsService,
  ) {}

  /**
   * Check if order can be cancelled by customer (pending, confirmed, processing only)
   */
  private isOrderCancellable(status: string): boolean {
    return ['pending', 'confirmed', 'processing'].includes(status);
  }

  /**
   * Map OrderItem documents (from order_items collection) to client format
   */
  private mapOrderItemsToClientFormat(
    items: OrderItemDocument[] | any[],
  ): any[] {
    return items.map((item) => {
      const productId =
        typeof item.productId === 'object' && item.productId?._id
          ? item.productId._id.toString()
          : item.productId?.toString?.() ?? item.productId;
      const productImage =
        item.productImage ||
        (typeof item.productId === 'object' &&
          (item.productId?.mainImage || item.productId?.images?.[0]));
      return {
        productId,
        sku: item.productSku ?? item.sku ?? '',
        name: item.productName ?? item.name ?? '',
        nameAr: item.productNameAr ?? item.nameAr ?? null,
        image: productImage ?? item.image ?? null,
        quantity: item.quantity ?? 0,
        unitPrice: item.unitPrice ?? 0,
        discount: item.discount ?? 0,
        total: item.totalPrice ?? item.total ?? 0,
      };
    });
  }

  /**
   * Map embedded order items (from order document) to client format
   */
  private mapEmbeddedOrderItemsToClientFormat(items: any[]): any[] {
    if (!items?.length) return [];
    return items.map((item) => {
      let productId = item.productId;
      if (typeof productId === 'object' && productId != null) {
        productId =
          productId._id?.toString() ??
          productId.$oid?.toString() ??
          productId.toString?.();
      } else if (productId != null) {
        productId = productId.toString();
      }
      return {
        productId: productId ?? '',
        sku: item.sku ?? '',
        name: item.name ?? '',
        nameAr: item.nameAr ?? null,
        image: item.image ?? null,
        quantity: item.quantity ?? 0,
        unitPrice: item.unitPrice ?? 0,
        discount: item.discount ?? 0,
        total: item.total ?? 0,
      };
    });
  }

  /**
   * Create order from cart
   */
  async createOrder(
    customerId: string,
    data: CreateOrderDto,
  ): Promise<OrderDocument> {
    this.logger.debug(`createOrder: customerId=${customerId}`);
    const cart = await this.cartService.getCart(customerId);
    this.logger.debug(
      `createOrder: cartId=${cart._id}, itemsCount=${cart.items?.length || 0}`,
    );

    if (!cart.items.length) {
      throw new BadRequestException('Cart is empty');
    }

    const orderNumber = await this.generateOrderNumber();

    // Calculate subtotal from cart
    const subtotal = cart.subtotal;
    let couponDiscount = 0;
    let couponId: Types.ObjectId | undefined;
    let couponCode: string | undefined;

    // Validate and apply coupon if provided
    if (data.couponCode) {
      try {
        // Check if this is customer's first order
        const previousOrdersCount = await this.orderModel.countDocuments({
          customerId: new Types.ObjectId(customerId),
        });
        const isFirstOrder = previousOrdersCount === 0;

        // Validate coupon
        const validation = await this.couponsService.validate(
          data.couponCode,
          customerId,
          subtotal,
          isFirstOrder,
        );

        couponId = validation.coupon._id;
        couponCode = validation.coupon.code;
        couponDiscount = validation.discountAmount;
      } catch (error) {
        // If validation fails, throw error
        throw new BadRequestException(error.message || 'Invalid coupon code');
      }
    }

    // Calculate totals
    const taxAmount = cart.taxAmount;
    const shippingCost = cart.shippingCost;
    const discount = cart.discount; // Other discounts (promotions)
    const total =
      subtotal - discount - couponDiscount + taxAmount + shippingCost;

    // Create order (currency default SAR)
    const order = await this.orderModel.create({
      orderNumber,
      customerId,
      status: 'pending',
      subtotal,
      taxAmount,
      shippingCost,
      discount,
      couponDiscount,
      total,
      currencyCode: 'SAR',
      couponId,
      couponCode,
      appliedPromotions: cart.appliedPromotions,
      shippingAddress: data.shippingAddress,
      shippingAddressId: data.shippingAddressId,
      paymentMethod: data.paymentMethod,
      customerNotes: data.customerNotes,
      source: data.source || 'mobile',
    });

    // Create order items with product details
    this.logger.debug(
      `createOrder: creating order items for orderId=${order._id}`,
    );
    const orderItems = await Promise.all(
      cart.items.map(async (item, index) => {
        this.logger.debug(
          `createOrder: processing item ${index}, productId=${item.productId}`,
        );
        // Fetch product details to populate sku and name
        let productSku = '';
        let productName = '';
        let productNameAr = '';
        let productImage = '';

        try {
          const product = await this.productsService.findByIdOrSlug(
            item.productId.toString(),
          );
          productSku = product.sku || '';
          productName = product.name || '';
          productNameAr = product.nameAr || '';
          productImage = product.mainImage || product.images?.[0] || '';
          this.logger.debug(
            `createOrder: product found, sku=${productSku}, name=${productName}`,
          );
        } catch (error) {
          // If product not found, use placeholder values
          this.logger.error(
            `createOrder: product not found for productId=${item.productId}, error=${error.message}`,
          );
          productSku = 'N/A';
          productName = 'Unknown Product';
        }

        return {
          orderId: order._id,
          productId: item.productId,
          productSku,
          productName,
          productNameAr,
          productImage,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
        };
      }),
    );

    this.logger.debug(
      `createOrder: inserting ${orderItems.length} order items`,
    );
    const insertedItems = await this.orderItemModel.insertMany(orderItems);
    this.logger.debug(
      `createOrder: inserted ${insertedItems.length} order items`,
    );

    // Persist items to order document (Order schema format: productId, sku, name, quantity, unitPrice, total)
    const orderItemsForDoc = orderItems.map((item) => ({
      productId: item.productId,
      sku: item.productSku,
      name: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.totalPrice,
    }));
    await this.orderModel.findByIdAndUpdate(order._id, {
      $set: { items: orderItemsForDoc },
    });

    // Convert cart
    await this.cartService.convertCart(customerId, order._id.toString());

    // Record coupon usage if applied
    if (order.couponId && order.couponDiscount > 0) {
      await this.couponsService.recordUsage({
        couponId: order.couponId.toString(),
        customerId: customerId,
        orderId: order._id.toString(),
        discountAmount: order.couponDiscount,
        orderAmount: order.subtotal,
      });
    }

    // Record promotion usage if applied
    if (order.appliedPromotions && order.appliedPromotions.length > 0) {
      // Calculate promotion discount (discount minus coupon discount)
      // Note: Promotions might be applied at item level, so we use 0 if no separate promotion discount
      // If there's a general promotion discount, it would be: order.discount - order.couponDiscount
      const totalPromotionDiscount = Math.max(
        0,
        order.discount - order.couponDiscount,
      );
      const promotionDiscountPerPromo =
        totalPromotionDiscount > 0
          ? totalPromotionDiscount / order.appliedPromotions.length
          : 0;

      await Promise.all(
        order.appliedPromotions.map((promotionId) =>
          this.promotionsService.recordUsage({
            promotionId: promotionId.toString(),
            customerId: customerId,
            orderId: order._id.toString(),
            discountAmount: promotionDiscountPerPromo,
            orderAmount: order.subtotal,
          }),
        ),
      );
    }

    // Create invoice
    await this.createInvoice(order);

    // Return order with items merged (client format)
    const mappedItems = this.mapOrderItemsToClientFormat(
      insertedItems as OrderItemDocument[],
    );
    return {
      ...order.toObject(),
      items: mappedItems,
      cancellable: true,
    } as any;
  }

  /**
   * Find orders with filters
   */
  async findAll(
    filters?: any,
  ): Promise<{ data: any[]; total: number }> {
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

    const [orders, total] = await Promise.all([
      this.orderModel
        .find(query)
        .populate('customerId', 'shopName responsiblePersonName phone')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ [sort]: order === 'desc' ? -1 : 1 }),
      this.orderModel.countDocuments(query),
    ]);

    if (orders.length === 0) {
      return { data: [], total };
    }

    const orderIds = orders.map((o) => o._id);
    const allItems = await this.orderItemModel
      .find({ orderId: { $in: orderIds } })
      .populate('productId', 'name nameAr mainImage');

    const itemsByOrderId = new Map<string, OrderItemDocument[]>();
    for (const item of allItems) {
      const oid = item.orderId.toString();
      const list = itemsByOrderId.get(oid) || [];
      list.push(item);
      itemsByOrderId.set(oid, list);
    }

    const data = orders.map((order) => {
      const orderObj = order.toObject();
      const orderItems = itemsByOrderId.get(order._id.toString()) || [];
      const mappedItems =
        orderItems.length > 0
          ? this.mapOrderItemsToClientFormat(orderItems)
          : this.mapEmbeddedOrderItemsToClientFormat(orderObj.items || []);
      return {
        ...orderObj,
        items: mappedItems,
        cancellable: this.isOrderCancellable(order.status),
      };
    });

    return { data, total };
  }

  /**
   * Find order with raw items (internal use)
   */
  private async findOrderAndItems(id: string): Promise<{
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

    const orderIdForQuery =
      typeof order._id === 'string'
        ? new Types.ObjectId(order._id)
        : order._id;
    const [items, history] = await Promise.all([
      this.orderItemModel
        .find({ orderId: orderIdForQuery })
        .populate('productId', 'name nameAr mainImage'),
      this.statusHistoryModel
        .find({ orderId: orderIdForQuery })
        .sort({ createdAt: 1 }),
    ]);

    return { order, items, history };
  }

  /**
   * Find order by ID or number - returns merged object with items for API
   */
  async findById(id: string): Promise<any> {
    const { order, items, history } = await this.findOrderAndItems(id);
    const orderObj = order.toObject();
    // Use order_items if available, otherwise fallback to embedded order.items
    const mappedItems =
      items.length > 0
        ? this.mapOrderItemsToClientFormat(items)
        : this.mapEmbeddedOrderItemsToClientFormat(orderObj.items || []);
    return {
      ...orderObj,
      items: mappedItems,
      history,
      cancellable: this.isOrderCancellable(order.status),
    };
  }

  /**
   * Cancel order by customer (only if status is pending, confirmed, or processing)
   */
  async cancelOrderByCustomer(
    orderId: string,
    customerId: string,
    reason: string,
  ): Promise<any> {
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    const orderCustomerId = (
      (order.customerId as any)?._id ?? order.customerId
    )?.toString();
    if (orderCustomerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    if (!this.isOrderCancellable(order.status)) {
      throw new BadRequestException(
        'لا يمكن إلغاء الطلب بعد مرحلة التجهيز',
      );
    }

    await this.updateStatus(orderId, 'cancelled', undefined, reason);

    return this.findById(orderId);
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
    const { order, items } = await this.findOrderAndItems(orderId);
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

  /**
   * Get order statistics
   */
  async getStats(customerId?: string): Promise<{
    total: number;
    byStatus: Record<string, number>;
    byPaymentStatus: Record<string, number>;
    totalRevenue: number;
    totalPaid: number;
    totalUnpaid: number;
    todayOrders: number;
    todayRevenue: number;
    thisMonthOrders: number;
    thisMonthRevenue: number;
  }> {
    const query: any = {};
    if (customerId) {
      query.customerId = new Types.ObjectId(customerId);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const thisMonthStart = new Date(today.getFullYear(), today.getMonth(), 1);
    const nextMonthStart = new Date(
      today.getFullYear(),
      today.getMonth() + 1,
      1,
    );

    const [
      total,
      byStatus,
      byPaymentStatus,
      totalRevenue,
      totalPaid,
      totalUnpaid,
      todayOrders,
      todayRevenue,
      thisMonthOrders,
      thisMonthRevenue,
    ] = await Promise.all([
      // Total orders
      this.orderModel.countDocuments(query),

      // Count by status
      this.orderModel.aggregate([
        { $match: query },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
          },
        },
      ]),

      // Count by payment status
      this.orderModel.aggregate([
        { $match: query },
        {
          $group: {
            _id: '$paymentStatus',
            count: { $sum: 1 },
          },
        },
      ]),

      // Total revenue
      this.orderModel.aggregate([
        { $match: query },
        {
          $group: {
            _id: null,
            total: { $sum: '$total' },
          },
        },
      ]),

      // Total paid
      this.orderModel.aggregate([
        { $match: { ...query, paymentStatus: 'paid' } },
        {
          $group: {
            _id: null,
            total: { $sum: '$paidAmount' },
          },
        },
      ]),

      // Total unpaid
      this.orderModel.aggregate([
        { $match: { ...query, paymentStatus: { $in: ['unpaid', 'partial'] } } },
        {
          $group: {
            _id: null,
            total: { $sum: { $subtract: ['$total', '$paidAmount'] } },
          },
        },
      ]),

      // Today orders
      this.orderModel.countDocuments({
        ...query,
        createdAt: { $gte: today, $lt: tomorrow },
      }),

      // Today revenue
      this.orderModel.aggregate([
        {
          $match: {
            ...query,
            createdAt: { $gte: today, $lt: tomorrow },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$total' },
          },
        },
      ]),

      // This month orders
      this.orderModel.countDocuments({
        ...query,
        createdAt: { $gte: thisMonthStart, $lt: nextMonthStart },
      }),

      // This month revenue
      this.orderModel.aggregate([
        {
          $match: {
            ...query,
            createdAt: { $gte: thisMonthStart, $lt: nextMonthStart },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$total' },
          },
        },
      ]),
    ]);

    // Format byStatus
    const statusMap: Record<string, number> = {};
    byStatus.forEach((item: any) => {
      statusMap[item._id] = item.count;
    });

    // Format byPaymentStatus
    const paymentStatusMap: Record<string, number> = {};
    byPaymentStatus.forEach((item: any) => {
      paymentStatusMap[item._id] = item.count;
    });

    return {
      total,
      byStatus: statusMap,
      byPaymentStatus: paymentStatusMap,
      totalRevenue: totalRevenue[0]?.total || 0,
      totalPaid: totalPaid[0]?.total || 0,
      totalUnpaid: totalUnpaid[0]?.total || 0,
      todayOrders,
      todayRevenue: todayRevenue[0]?.total || 0,
      thisMonthOrders,
      thisMonthRevenue: thisMonthRevenue[0]?.total || 0,
    };
  }
}
