import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
  Inject,
  forwardRef,
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
import { CustomersService } from '@modules/customers/customers.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { AuditService } from '@modules/audit/audit.service';
import {
  AuditAction,
  AuditResource,
} from '@modules/audit/schemas/audit-log.schema';
import { ReturnsService } from '@modules/returns/returns.service';
import { WalletService } from '@modules/wallet/wallet.service';
import * as PDFDocument from 'pdfkit';
import { StorageService } from '@modules/integrations/storage.service';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';

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
    private customersService: CustomersService,
    private auditService: AuditService,
    private walletService: WalletService,
    private storageService: StorageService,
    private configService: ConfigService,
    @Inject(forwardRef(() => ReturnsService))
    private returnsService: ReturnsService,
  ) { }

  private normalizePaymentMethod(method?: string): string {
    const normalized = (method || 'bank_transfer').toLowerCase();
    const paymentMethodMap: Record<string, string> = {
      cod: 'cash_on_delivery',
      cash: 'cash_on_delivery',
      cash_on_delivery: 'cash_on_delivery',
      card: 'credit_card',
      credit_card: 'credit_card',
      mada: 'mada',
      apple_pay: 'apple_pay',
      stc_pay: 'stc_pay',
      bank_transfer: 'bank_transfer',
      wallet: 'wallet',
      credit: 'credit',
    };

    return paymentMethodMap[normalized] || 'bank_transfer';
  }

  /**
   * Check if order can be cancelled by customer (pending, confirmed, processing only)
   */
  private isOrderCancellable(status: string): boolean {
    return ['pending', 'confirmed', 'processing'].includes(status);
  }

  /**
   * Map OrderItem documents (from order_items collection) to client format.
   * reservedByOrderItemId: quantity reserved in active returns (pending, approved, etc. - not cancelled/rejected)
   */
  private mapOrderItemsToClientFormat(
    items: OrderItemDocument[] | any[],
    reservedByOrderItemId?: Map<string, number>,
  ): any[] {
    return items.map((item) => {
      const productId =
        typeof item.productId === 'object' && item.productId?._id
          ? item.productId._id.toString()
          : (item.productId?.toString?.() ?? item.productId);
      const productImage =
        item.productImage ||
        (typeof item.productId === 'object' &&
          (item.productId?.mainImage || item.productId?.images?.[0]));
      const quantity = item.quantity ?? 0;
      const returnedQuantity = item.returnedQuantity ?? 0;
      const orderItemIdStr =
        item._id?.toString?.() ?? item.id?.toString?.() ?? '';
      const reservedQty = reservedByOrderItemId?.get(orderItemIdStr) ?? 0;
      const effectiveReturned = returnedQuantity + reservedQty;
      const returnableQuantity = Math.max(0, quantity - effectiveReturned);
      const effectiveQuantity = returnableQuantity;
      const isEffectivelyFullyReturned = effectiveReturned >= quantity;
      const returnStatus =
        effectiveReturned === 0
          ? 'none'
          : effectiveReturned >= quantity
            ? 'full'
            : 'partial';
      return {
        _id: orderItemIdStr,
        productId,
        sku: item.productSku ?? item.sku ?? '',
        name: item.productName ?? item.name ?? '',
        nameAr: item.productNameAr ?? item.nameAr ?? null,
        image: productImage ?? item.image ?? null,
        quantity,
        returnedQuantity,
        reservedQuantity: reservedQty,
        returnableQuantity,
        effectiveQuantity,
        returnStatus,
        isEffectivelyFullyReturned,
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
      const quantity = item.quantity ?? 0;
      const returnedQuantity = item.returnedQuantity ?? 0;
      const returnableQuantity = Math.max(0, quantity - returnedQuantity);
      const returnStatus =
        returnedQuantity === 0
          ? 'none'
          : returnedQuantity >= quantity
            ? 'full'
            : 'partial';
      return {
        _id: item._id?.toString?.() ?? item.id?.toString?.(),
        productId: productId ?? '',
        sku: item.sku ?? '',
        name: item.name ?? '',
        nameAr: item.nameAr ?? null,
        image: item.image ?? null,
        quantity,
        returnedQuantity,
        returnableQuantity,
        effectiveQuantity: returnableQuantity,
        returnStatus,
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
    const paymentMethod = this.normalizePaymentMethod(data.paymentMethod);

    let walletAmountUsed = Math.max(0, Number(data.walletAmountUsed || 0));

    if (paymentMethod === 'wallet') {
      walletAmountUsed = total;
    }

    if (walletAmountUsed > total) {
      throw new BadRequestException(
        'Wallet amount cannot be greater than order total',
      );
    }

    if (walletAmountUsed > 0) {
      const walletBalance = await this.walletService.getBalance(customerId);
      if (walletBalance < walletAmountUsed) {
        throw new BadRequestException(
          `Insufficient wallet balance. Available: ${walletBalance.toFixed(2)} SAR, required: ${walletAmountUsed.toFixed(2)} SAR`,
        );
      }
    }

    const remainingAfterWallet = total - walletAmountUsed;

    // Validate credit limit when paying with credit
    if (paymentMethod === 'credit') {
      const customer = await this.customersService.findById(customerId);
      const creditLimit = customer?.creditLimit ?? 0;
      const creditUsed = customer?.creditUsed ?? 0;
      const availableCredit = creditLimit - creditUsed;
      if (remainingAfterWallet > availableCredit) {
        throw new BadRequestException(
          `حد الائتمان غير كافٍ. المتاح: ${availableCredit.toFixed(2)} ر.س، المطلوب: ${remainingAfterWallet.toFixed(2)} ر.س`,
        );
      }
    }

    // Get customer's price level for order record
    let priceLevelId: Types.ObjectId | undefined;
    try {
      const customer = await this.customersService.findById(customerId);
      priceLevelId = customer?.priceLevelId;
    } catch {
      // Continue without priceLevelId if customer lookup fails
    }

    const paidAmount = walletAmountUsed;
    const paymentStatus =
      paidAmount <= 0 ? 'unpaid' : paidAmount >= total ? 'paid' : 'partial';
    const transferStatus =
      paymentMethod === 'bank_transfer' && remainingAfterWallet > 0
        ? 'awaiting_receipt'
        : 'not_required';

    // Create order (currency default SAR)
    const order = await this.orderModel.create({
      orderNumber,
      customerId,
      priceLevelId,
      status: 'pending',
      subtotal,
      taxAmount,
      shippingCost,
      discount,
      couponDiscount,
      walletAmountUsed,
      total,
      paidAmount,
      paymentStatus,
      transferStatus,
      currencyCode: 'SAR',
      couponId,
      couponCode,
      appliedPromotions: cart.appliedPromotions,
      shippingAddress: data.shippingAddress,
      shippingAddressId: data.shippingAddressId,
      paymentMethod,
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

    // Debit wallet if wallet amount is used
    if (walletAmountUsed > 0) {
      await this.walletService.debit({
        customerId,
        amount: walletAmountUsed,
        transactionType: 'order_payment',
        referenceType: 'order',
        referenceId: order._id.toString(),
        referenceNumber: order.orderNumber,
        description: `Wallet payment for order ${order.orderNumber}`,
        descriptionAr: `الدفع من المحفظة للطلب ${order.orderNumber}`,
        idempotencyKey: `order:${order._id.toString()}:wallet_debit`,
      });
    }

    // Increment credit used when order is placed on credit
    if (paymentMethod === 'credit' && remainingAfterWallet > 0) {
      this.logger.debug(
        `createOrder: incrementing creditUsed for customerId=${customerId}, amount=${remainingAfterWallet}`,
      );
      const updatedCustomer = await this.customersService.incrementCreditUsed(
        customerId,
        remainingAfterWallet,
      );
      this.logger.debug(
        `createOrder: creditUsed updated. New creditUsed=${updatedCustomer.creditUsed}, creditLimit=${updatedCustomer.creditLimit}`,
      );
    }

    // Update customer statistics (totalOrders, totalSpent, averageOrderValue, lastOrderAt)
    try {
      await this.customersService.updateStatistics(customerId, order.total);
      this.logger.debug(
        `createOrder: updated statistics for customerId=${customerId}, orderTotal=${order.total}`,
      );
    } catch (error) {
      // Log error but don't fail order creation if statistics update fails
      this.logger.warn(
        `createOrder: failed to update statistics for customerId=${customerId}`,
        error,
      );
    }

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
  async findAll(filters?: any): Promise<{ data: any[]; total: number }> {
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

    const orderItemIds = allItems.map((i) =>
      typeof i._id === 'string' ? new Types.ObjectId(i._id) : i._id,
    );
    const reservedMap =
      orderItemIds.length > 0
        ? await this.returnsService.getReservedQuantitiesByOrderItemIds(
          orderItemIds,
        )
        : new Map<string, number>();

    const data = orders.map((order) => {
      const orderObj = order.toObject();
      const orderItems = itemsByOrderId.get(order._id.toString()) || [];
      const mappedItems =
        orderItems.length > 0
          ? this.mapOrderItemsToClientFormat(orderItems, reservedMap)
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
      typeof order._id === 'string' ? new Types.ObjectId(order._id) : order._id;
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
    let reservedMap = new Map<string, number>();
    if (items.length > 0) {
      const orderItemIds = items.map((i) =>
        typeof i._id === 'string' ? new Types.ObjectId(i._id) : i._id,
      );
      reservedMap =
        await this.returnsService.getReservedQuantitiesByOrderItemIds(
          orderItemIds,
        );
    }
    // Use order_items if available, otherwise fallback to embedded order.items
    const mappedItems =
      items.length > 0
        ? this.mapOrderItemsToClientFormat(items, reservedMap)
        : this.mapEmbeddedOrderItemsToClientFormat(orderObj.items || []);
    return {
      ...orderObj,
      items: mappedItems,
      history,
      cancellable: this.isOrderCancellable(order.status),
    };
  }

  /**
   * Get invoice metadata and URL for an order
   */
  async getOrderInvoice(
    orderId: string,
    customerId?: string,
  ): Promise<{ invoiceNumber: string; url: string }> {
    const { order } = await this.findOrderAndItems(orderId);
    this.assertOrderOwnership(order, customerId);

    const invoice = await this.getOrCreateInvoice(order);
    const ensured = await this.ensureInvoicePdfUploaded(order, invoice);

    return {
      invoiceNumber: invoice.invoiceNumber,
      url: ensured.url,
    };
  }

  /**
   * Build invoice PDF for an order
   */
  async buildOrderInvoicePdf(
    orderId: string,
    customerId?: string,
  ): Promise<{ buffer: Buffer; filename: string; invoiceNumber: string; url?: string }> {
    const { order, items } = await this.findOrderAndItems(orderId);
    this.assertOrderOwnership(order, customerId);

    const invoice = await this.getOrCreateInvoice(order);
    const buffer = await this.generateInvoicePdfBuffer(order, invoice, items);
    const filename = `invoice-${invoice.invoiceNumber}.pdf`;

    return {
      buffer,
      filename,
      invoiceNumber: invoice.invoiceNumber,
      url: invoice.pdfUrl,
    };
  }

  private assertOrderOwnership(order: OrderDocument, customerId?: string): void {
    if (!customerId) return;

    const orderCustomerId = (
      (order.customerId as any)?._id ?? order.customerId
    )?.toString();
    if (orderCustomerId !== customerId) {
      throw new NotFoundException('Order not found');
    }
  }

  private async getOrCreateInvoice(order: OrderDocument): Promise<InvoiceDocument> {
    const orderObjectId =
      typeof order._id === 'string' ? new Types.ObjectId(order._id) : order._id;

    let invoice = await this.invoiceModel.findOne({ orderId: orderObjectId });
    if (!invoice) {
      await this.createInvoice(order);
      invoice = await this.invoiceModel.findOne({ orderId: orderObjectId });
    }
    if (!invoice) {
      throw new NotFoundException('Invoice not found');
    }

    return invoice as InvoiceDocument;
  }

  private async ensureInvoicePdfUploaded(
    order: OrderDocument,
    invoice: InvoiceDocument,
  ): Promise<{ url: string; regenerated: boolean }> {
    if (invoice.pdfUrl) {
      return { url: invoice.pdfUrl, regenerated: false };
    }

    const orderId =
      typeof order._id === 'string' ? order._id : (order._id as any).toString();
    const { items } = await this.findOrderAndItems(orderId);
    const buffer = await this.generateInvoicePdfBuffer(order, invoice, items);

    const uploadResult = await this.storageService.upload({
      file: buffer,
      filename: `invoice-${invoice.invoiceNumber}.pdf`,
      mimetype: 'application/pdf',
      folder: 'invoices',
      isPublic: true,
    });

    if (!uploadResult.success || !uploadResult.url) {
      throw new BadRequestException(
        uploadResult.error || 'Failed to upload invoice PDF',
      );
    }

    invoice.pdfUrl = uploadResult.url;
    await invoice.save();

    return { url: uploadResult.url, regenerated: true };
  }

  private async generateInvoicePdfBuffer(
    order: OrderDocument,
    invoice: InvoiceDocument,
    items: OrderItemDocument[] | any[],
  ): Promise<Buffer> {
    const logo = this.loadInvoiceLogo();

    return new Promise<Buffer>((resolve, reject) => {
      const doc = new PDFDocument({ margin: 40, size: 'A4' });
      const chunks: Buffer[] = [];

      doc.on('data', (chunk) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      const orderDate = order.createdAt || new Date();
      const issueDate = invoice.issueDate || orderDate;
      const currency = order.currencyCode || 'SAR';
      const customer = order.customerId as any;
      const customerName =
        invoice.customerName ||
        customer?.shopName ||
        customer?.responsiblePersonName ||
        order.shippingAddress?.fullName ||
        'Customer';
      const customerPhone =
        invoice.customerPhone || customer?.phone || order.shippingAddress?.phone || '-';

      const pageWidth = doc.page.width;
      const headerX = 40;
      const headerY = 40;
      const headerWidth = pageWidth - 80;

      doc.save();
      doc.roundedRect(headerX, headerY, headerWidth, 88, 12).fill('#0F4C81');
      doc.restore();

      if (logo) {
        try {
          doc.image(logo, headerX + 14, headerY + 14, { fit: [64, 64] });
        } catch {
          // Ignore logo rendering errors and continue with text-based branding
        }
      }

      doc.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(18);
      doc.text('TRAS PHONE', headerX + 90, headerY + 18, { width: 220 });
      doc.fontSize(10).font('Helvetica');
      doc.text('Professional Invoice | فاتورة ضريبية', headerX + 90, headerY + 42, {
        width: 260,
      });

      doc.font('Helvetica-Bold').fontSize(11);
      doc.text(`Invoice: ${invoice.invoiceNumber}`, headerX + headerWidth - 210, headerY + 20, {
        width: 180,
        align: 'right',
      });
      doc.font('Helvetica').fontSize(10);
      doc.text(`Date: ${issueDate.toISOString().slice(0, 10)}`, headerX + headerWidth - 210, headerY + 40, {
        width: 180,
        align: 'right',
      });
      doc.text(`Order: ${order.orderNumber}`, headerX + headerWidth - 210, headerY + 58, {
        width: 180,
        align: 'right',
      });

      const infoTop = 150;
      doc.save();
      doc.roundedRect(40, infoTop, 255, 92, 10).fill('#F4F8FC');
      doc.roundedRect(305, infoTop, 250, 92, 10).fill('#F4F8FC');
      doc.restore();

      doc.fillColor('#0F4C81').font('Helvetica-Bold').fontSize(11);
      doc.text('Bill To | بيانات العميل', 52, infoTop + 12);
      doc.fillColor('#222222').font('Helvetica').fontSize(10);
      doc.text(`Name: ${customerName}`, 52, infoTop + 34, { width: 235 });
      doc.text(`Phone: ${customerPhone}`, 52, infoTop + 52, { width: 235 });

      doc.fillColor('#0F4C81').font('Helvetica-Bold').fontSize(11);
      doc.text('Payment | الدفع', 317, infoTop + 12);
      doc.fillColor('#222222').font('Helvetica').fontSize(10);
      doc.text(`Method: ${order.paymentMethod || '-'}`, 317, infoTop + 34, {
        width: 225,
      });
      doc.text(`Status: ${order.paymentStatus || 'unpaid'}`, 317, infoTop + 52, {
        width: 225,
      });

      const tableTop = 265;
      doc.save();
      doc.roundedRect(40, tableTop, 515, 26, 6).fill('#0F4C81');
      doc.restore();
      doc.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(10);
      doc.text('Item', 52, tableTop + 8, { width: 210 });
      doc.text('Qty', 275, tableTop + 8, { width: 40, align: 'right' });
      doc.text('Unit Price', 332, tableTop + 8, { width: 95, align: 'right' });
      doc.text('Total', 445, tableTop + 8, { width: 96, align: 'right' });

      doc.fillColor('#222222').font('Helvetica').fontSize(10);
      let y = tableTop + 34;
      const renderedItems =
        items.length > 0
          ? items
          : (order.items || []).map((item: any) => ({
              productName: item.name,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              totalPrice: item.total,
            }));

      for (let index = 0; index < renderedItems.length; index += 1) {
        const item: any = renderedItems[index];
        const rowHeight = 22;

        if (y > 700) {
          doc.addPage();
          y = 70;
        }

        if (index % 2 === 0) {
          doc.save();
          doc.rect(40, y - 4, 515, rowHeight).fill('#F9FBFD');
          doc.restore();
          doc.fillColor('#222222');
        }

        const productName = item.productName || item.name || 'Item';
        const qty = Number(item.quantity || 0);
        const unitPrice = Number(item.unitPrice || 0);
        const lineTotal = Number(item.totalPrice ?? item.total ?? 0);

        doc.text(productName, 52, y, { width: 210 });
        doc.text(`${qty}`, 275, y, { width: 40, align: 'right' });
        doc.text(`${unitPrice.toFixed(2)} ${currency}`, 332, y, {
          width: 95,
          align: 'right',
        });
        doc.text(`${lineTotal.toFixed(2)} ${currency}`, 445, y, {
          width: 96,
          align: 'right',
        });

        y += rowHeight;
      }

      const totalsY = Math.max(y + 14, 590);
      doc.save();
      doc.roundedRect(330, totalsY, 225, 104, 8).fill('#F4F8FC');
      doc.restore();

      const drawTotalLine = (label: string, value: number, offset: number, bold = false) => {
        doc.font(bold ? 'Helvetica-Bold' : 'Helvetica').fontSize(bold ? 11 : 10);
        doc.fillColor('#0F4C81').text(label, 342, totalsY + offset, { width: 100 });
        doc.fillColor('#222222').text(`${value.toFixed(2)} ${currency}`, 440, totalsY + offset, {
          width: 100,
          align: 'right',
        });
      };

      drawTotalLine('Subtotal', Number(invoice.subtotal || 0), 14);
      drawTotalLine('Discount', Number(invoice.discount || 0), 32);
      drawTotalLine('Tax', Number(invoice.taxAmount || 0), 50);
      drawTotalLine('Shipping', Number(invoice.shippingCost || 0), 68);
      drawTotalLine('Grand Total', Number(invoice.total || 0), 86, true);

      doc.fillColor('#666666').font('Helvetica').fontSize(9);
      doc.text('Thank you for your business | شكرا لتعاملكم معنا', 40, 790, {
        width: 515,
        align: 'center',
      });

      doc.end();
    });
  }

  private loadInvoiceLogo(): Buffer | undefined {
    const customPath = this.configService.get<string>('INVOICE_LOGO_PATH');
    const candidatePaths = [
      customPath,
      path.resolve(process.cwd(), '../mobile/assets/images/logo.png'),
      path.resolve(process.cwd(), '../admin/src/assets/logo.png'),
      path.resolve(process.cwd(), 'assets/logo.png'),
    ].filter(Boolean) as string[];

    for (const logoPath of candidatePaths) {
      try {
        if (fs.existsSync(logoPath)) {
          return fs.readFileSync(logoPath);
        }
      } catch {
        continue;
      }
    }

    return undefined;
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
      throw new BadRequestException('لا يمكن إلغاء الطلب بعد مرحلة التجهيز');
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

    // Validate status transition (allow admin to skip intermediate steps)
    // If userId is provided, it's an admin action - allow more flexible transitions
    const isAdminAction = !!userId;
    this.validateStatusTransition(oldStatus, newStatus, isAdminAction);

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

        // Earn loyalty points once per completed order
        if (order.customerId) {
          const alreadyAwarded = await this.walletService.hasLoyaltyTransaction({
            customerId: order.customerId.toString(),
            transactionType: 'order_earn',
            referenceType: 'order',
            referenceId: order._id.toString(),
          });

          if (!alreadyAwarded) {
            const pointsCalculation =
              await this.walletService.calculatePointsForOrder(
                order.customerId.toString(),
                order.total,
              );

            if (pointsCalculation.points > 0) {
              await this.walletService.earnPoints({
                customerId: order.customerId.toString(),
                points: pointsCalculation.points,
                multiplier: pointsCalculation.multiplier,
                transactionType: 'order_earn',
                orderAmount: order.total,
                referenceType: 'order',
                referenceId: order._id.toString(),
                referenceNumber: order.orderNumber,
                description: `Points earned for order ${order.orderNumber}`,
              });
            }
          }
        }
        break;
      case 'cancelled':
        updateData.cancelledAt = new Date();
        updateData.cancellationReason = notes;
        if (order.paymentMethod === 'credit') {
          const creditAmount = Math.max(
            0,
            (order.total || 0) - (order.walletAmountUsed || 0),
          );

          if (creditAmount > 0) {
            await this.customersService.decrementCreditUsed(
              order.customerId.toString(),
              creditAmount,
            );
          }
        }

        if ((order.walletAmountUsed || 0) > 0) {
          await this.walletService.credit({
            customerId: order.customerId.toString(),
            amount: order.walletAmountUsed,
            transactionType: 'order_refund',
            referenceType: 'order',
            referenceId: order._id.toString(),
            referenceNumber: order.orderNumber,
            description: `Wallet refund for cancelled order ${order.orderNumber}`,
            descriptionAr: `استرداد للمحفظة بسبب إلغاء الطلب ${order.orderNumber}`,
            idempotencyKey: `order:${order._id.toString()}:cancel_wallet_refund`,
          });

          updateData.paymentStatus = 'refunded';
          updateData.paidAmount = 0;
        }
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

    // Audit log
    const actorId =
      userId ??
      (newStatus === 'cancelled' ? order.customerId?.toString() : undefined);
    const actorType = userId
      ? 'admin'
      : newStatus === 'cancelled'
        ? 'customer'
        : 'system';
    const isCritical = ['cancelled', 'refunded'].includes(newStatus);
    await this.auditService
      .log({
        action:
          newStatus === 'cancelled'
            ? AuditAction.CANCEL
            : newStatus === 'refunded'
              ? AuditAction.REFUND
              : AuditAction.STATUS_CHANGE,
        resource: AuditResource.ORDER,
        resourceId: orderId,
        resourceName: (order as any).orderNumber ?? orderId,
        actorType,
        actorId,
        description: `Order status changed from ${oldStatus} to ${newStatus}`,
        descriptionAr: `تم تغيير حالة الطلب من ${oldStatus} إلى ${newStatus}`,
        severity: isCritical ? 'critical' : 'info',
        success: true,
      })
      .catch(() => undefined);

    return updatedOrder;
  }

  /**
   * Validate status transition
   * @param from - Current status
   * @param to - Target status
   * @param isAdminAction - If true, allows admin to skip intermediate steps
   */
  private validateStatusTransition(
    from: string,
    to: string,
    isAdminAction: boolean = false,
  ): void {
    // Admin actions: allow any transition (admin can force status changes)
    if (isAdminAction) {
      return;
    }

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
    // Standard validation for non-admin actions
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
   * Get shipments for an order
   */
  async getShipments(orderId: string): Promise<any[]> {
    const orderObjectId = Types.ObjectId.isValid(orderId)
      ? new Types.ObjectId(orderId)
      : orderId;

    const shipments = await this.shipmentModel
      .find({ orderId: orderObjectId })
      .populate('items.productId', 'name nameAr');

    if (!shipments.length) return [];

    return shipments.map((shipment) => {
      const shipmentObj = shipment.toObject();
      return {
        _id: shipmentObj._id,
        orderId: shipmentObj.orderId,
        trackingNumber: shipmentObj.trackingNumber,
        carrier: shipmentObj.carrier,
        status: shipmentObj.status,
        items: (shipmentObj.items || []).map((item: any) => {
          const product: any = item.productId || {};
          const productId =
            typeof product === 'object' && product?._id
              ? product._id.toString()
              : (item.productId?.toString?.() ?? '');
          return {
            productId,
            productName: product.name || product.nameAr || undefined,
            quantity: item.quantity,
          };
        }),
        shippedAt: shipmentObj.shippedAt,
        deliveredAt: shipmentObj.deliveredAt,
        createdAt: shipmentObj.createdAt,
      };
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
    const orderUpdate: any = { paidAmount: newPaidAmount, paymentStatus };

    if (order.paymentMethod === 'bank_transfer' && newPaidAmount >= order.total) {
      orderUpdate.transferStatus = 'verified';
    }

    await this.orderModel.findByIdAndUpdate(orderId, {
      $set: orderUpdate,
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

    // Decrement credit used when customer pays off a credit order
    if (order.paymentMethod === 'credit') {
      await this.customersService.decrementCreditUsed(
        order.customerId.toString(),
        data.amount,
      );
    }

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

    if (order.paymentMethod !== 'bank_transfer') {
      throw new BadRequestException(
        'Receipt upload is only allowed for bank transfer orders',
      );
    }

    if ((order.transferStatus as string) === 'verified') {
      throw new BadRequestException('Payment already verified for this order');
    }

    const remainingAmount = Math.max(0, (order.total || 0) - (order.paidAmount || 0));
    if (remainingAmount <= 0) {
      throw new BadRequestException('Order is already fully paid');
    }

    // Update order with receipt info
    order.transferReceiptImage = data.receiptImage;
    order.transferReference = data.transferReference;
    order.transferDate = data.transferDate
      ? new Date(data.transferDate)
      : undefined;
    order.transferStatus = 'receipt_uploaded';
    order.transferVerifiedAt = undefined;
    order.transferVerifiedBy = undefined;
    order.rejectionReason = undefined;

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

    if (order.paymentMethod !== 'bank_transfer') {
      throw new BadRequestException(
        'Payment verification is only allowed for bank transfer orders',
      );
    }

    if (verified) {
      if (!order.transferReceiptImage) {
        throw new BadRequestException('No transfer receipt uploaded');
      }

      const remainingAmount = Math.max(
        0,
        (order.total || 0) - (order.paidAmount || 0),
      );

      if (remainingAmount <= 0) {
        throw new BadRequestException('Order is already fully paid');
      }

      // Record payment
      await this.recordPayment(orderId, {
        amount: remainingAmount,
        paymentMethod: 'bank_transfer',
        gatewayReference: order.transferReference,
      });

      await this.orderModel.findByIdAndUpdate(orderId, {
        $set: {
          transferVerifiedAt: new Date(),
          transferVerifiedBy: new Types.ObjectId(adminId),
          transferStatus: 'verified',
          rejectionReason: undefined,
        },
      });
    } else {
      const currentPaymentStatus =
        (order.paidAmount || 0) <= 0
          ? 'unpaid'
          : (order.paidAmount || 0) >= (order.total || 0)
            ? 'paid'
            : 'partial';

      await this.orderModel.findByIdAndUpdate(orderId, {
        $set: {
          transferStatus: 'rejected',
          rejectionReason,
          paymentStatus: currentPaymentStatus,
        },
        $unset: {
          transferVerifiedAt: 1,
          transferVerifiedBy: 1,
        },
      });
    }

    // Add note
    if (notes) {
      await this.addNote(
        orderId,
        notes,
        verified ? 'payment_verified' : 'payment_rejected',
        adminId,
      );
    }

    // Audit log
    await this.auditService
      .log({
        action: verified ? AuditAction.APPROVE : AuditAction.REJECT,
        resource: AuditResource.PAYMENT,
        resourceId: orderId,
        resourceName: (order as any).orderNumber ?? orderId,
        actorType: 'admin',
        actorId: adminId,
        description: verified
          ? 'Payment verified'
          : `Payment rejected: ${rejectionReason ?? 'No reason'}`,
        descriptionAr: verified
          ? 'تم التحقق من الدفع'
          : `تم رفض الدفع: ${rejectionReason ?? 'بدون سبب'}`,
        severity: verified ? 'info' : 'warning',
        success: true,
      })
      .catch(() => undefined);

    const updatedOrder = await this.orderModel.findById(orderId);
    if (!updatedOrder) throw new NotFoundException('Order not found');
    return updatedOrder;
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
    const order = await this.orderModel.findById(orderId);
    if (!order) throw new NotFoundException('Order not found');

    // Verify order belongs to customer (handle both ObjectId and populated customerId)
    const orderCustomerId = (
      (order.customerId as any)?._id ?? order.customerId
    )?.toString();
    if (orderCustomerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

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

  async getPendingTransferVerificationOrders(): Promise<OrderDocument[]> {
    return this.orderModel
      .find({
        paymentMethod: 'bank_transfer',
        $or: [
          { transferStatus: 'receipt_uploaded' },
          {
            transferStatus: { $exists: false },
            transferReceiptImage: { $exists: true, $ne: null },
            transferVerifiedAt: { $exists: false },
          },
        ],
      })
      .populate('customerId', 'shopName responsiblePersonName phone')
      .sort({ updatedAt: -1 });
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
