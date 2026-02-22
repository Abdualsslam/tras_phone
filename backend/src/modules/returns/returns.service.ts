import { Injectable, NotFoundException, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  ReturnRequest,
  ReturnRequestDocument,
} from './schemas/return-request.schema';
import { ReturnItem, ReturnItemDocument } from './schemas/return-item.schema';
import {
  ReturnStatusHistory,
  ReturnStatusHistoryDocument,
} from './schemas/return-status-history.schema';
import { Refund, RefundDocument } from './schemas/refund.schema';
import {
  ReturnReason,
  ReturnReasonDocument,
} from './schemas/return-reason.schema';
import {
  SupplierReturnBatch,
  SupplierReturnBatchDocument,
} from './schemas/supplier-return-batch.schema';
import {
  OrderItem,
  OrderItemDocument,
} from '@modules/orders/schemas/order-item.schema';
import { Order, OrderDocument } from '@modules/orders/schemas/order.schema';
import { WalletService } from '@modules/wallet/wallet.service';
import { CustomersService } from '@modules/customers/customers.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔄 Returns Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ReturnsService {
  constructor(
    @InjectModel(ReturnRequest.name)
    private returnRequestModel: Model<ReturnRequestDocument>,
    @InjectModel(ReturnItem.name)
    private returnItemModel: Model<ReturnItemDocument>,
    @InjectModel(ReturnStatusHistory.name)
    private statusHistoryModel: Model<ReturnStatusHistoryDocument>,
    @InjectModel(Refund.name) private refundModel: Model<RefundDocument>,
    @InjectModel(ReturnReason.name)
    private returnReasonModel: Model<ReturnReasonDocument>,
    @InjectModel(SupplierReturnBatch.name)
    private supplierReturnBatchModel: Model<SupplierReturnBatchDocument>,
    @InjectModel(OrderItem.name)
    private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(Order.name)
    private orderModel: Model<OrderDocument>,
    @Inject(forwardRef(() => WalletService))
    private walletService: WalletService,
    private customersService: CustomersService,
  ) { }

  /**
   * Get reserved quantity per order item from active return requests
   * (all statuses except cancelled and rejected)
   */
  async getReservedQuantitiesByOrderItemIds(
    orderItemIds: Types.ObjectId[],
  ): Promise<Map<string, number>> {
    const activeStatuses = [
      'pending',
      'approved',
      'pickup_scheduled',
      'picked_up',
      'inspecting',
      'completed',
    ];
    const result = await this.returnItemModel.aggregate<{
      _id: Types.ObjectId;
      reservedQty: number;
    }>([
      {
        $lookup: {
          from: 'return_requests',
          localField: 'returnRequestId',
          foreignField: '_id',
          as: 'request',
        },
      },
      { $unwind: '$request' },
      {
        $match: {
          'request.status': { $in: activeStatuses },
          orderItemId: { $in: orderItemIds },
        },
      },
      {
        $group: {
          _id: '$orderItemId',
          reservedQty: { $sum: '$quantity' },
        },
      },
    ]);
    const map = new Map<string, number>();
    for (const row of result) {
      map.set(row._id.toString(), row.reservedQty);
    }
    return map;
  }

  /**
   * Create return request
   */
  async createReturnRequest(data: {
    customerId: string;
    returnType: string;
    reasonId: string;
    items: {
      orderItemId: string;
      quantity: number;
    }[];
    customerNotes?: string;
    customerImages?: string[];
  }): Promise<ReturnRequestDocument> {
    const returnNumber = await this.generateReturnNumber();

    // 1. Fetch OrderItems from database
    const orderItemIds = data.items.map((i) => new Types.ObjectId(i.orderItemId));
    const orderItems = await this.orderItemModel
      .find({
        _id: { $in: orderItemIds },
      })
      .populate('orderId');

    if (orderItems.length !== data.items.length) {
      throw new BadRequestException('Some order items not found');
    }

    // 2. Verify all items belong to the same customer
    const orderIds = [...new Set(orderItems.map((i) => i.orderId._id.toString()))];

    // 2b. Get quantity already reserved in other active return requests (pending, approved, etc.)
    const activeStatuses = [
      'pending',
      'approved',
      'pickup_scheduled',
      'picked_up',
      'inspecting',
    ];
    const pendingByOrderItem = await this.returnItemModel.aggregate([
      {
        $lookup: {
          from: 'return_requests',
          localField: 'returnRequestId',
          foreignField: '_id',
          as: 'request',
        },
      },
      { $unwind: '$request' },
      {
        $match: {
          'request.status': { $in: activeStatuses },
          orderItemId: { $in: orderItemIds },
        },
      },
      {
        $group: {
          _id: '$orderItemId',
          reservedQty: { $sum: '$quantity' },
        },
      },
    ]);
    const reservedMap = new Map<string, number>();
    for (const row of pendingByOrderItem) {
      reservedMap.set(
        row._id.toString(),
        (reservedMap.get(row._id.toString()) || 0) + row.reservedQty,
      );
    }

    // 3. Aggregate requested quantity per orderItemId (in case same item appears twice)
    const requestedByOrderItem = new Map<string, number>();
    for (const item of data.items) {
      const key = item.orderItemId;
      requestedByOrderItem.set(
        key,
        (requestedByOrderItem.get(key) || 0) + item.quantity,
      );
    }

    // 4. Calculate total value and validate
    const totalItemsValue = data.items.reduce((sum, item) => {
      const orderItem = orderItems.find(
        (oi) => oi._id.toString() === item.orderItemId,
      );
      if (!orderItem) {
        throw new BadRequestException(
          `Order item ${item.orderItemId} not found`,
        );
      }
      const orderItemIdStr = (orderItem._id as Types.ObjectId).toString();
      const baseReturnable =
        orderItem.quantity - (orderItem.returnedQuantity || 0);
      const reservedQty = reservedMap.get(orderItemIdStr) || 0;
      const returnableQty = Math.max(0, baseReturnable - reservedQty);
      const totalRequested = requestedByOrderItem.get(orderItemIdStr) || 0;
      if (totalRequested > returnableQty) {
        throw new BadRequestException(
          `Return quantity exceeds returnable quantity (${returnableQty} of ${orderItem.quantity}${reservedQty > 0 ? `, ${reservedQty} already in other return requests` : ''}) for item ${item.orderItemId}`,
        );
      }
      return sum + item.quantity * orderItem.unitPrice;
    }, 0);

    // 5. Create return request with orderIds array
    const returnRequest = await this.returnRequestModel.create({
      returnNumber,
      orderIds: orderIds.map(id => new Types.ObjectId(id)),
      customerId: data.customerId,
      returnType: data.returnType,
      reasonId: data.reasonId,
      customerNotes: data.customerNotes,
      customerImages: data.customerImages,
      totalItemsValue,
      status: 'pending',
    });

    // 6. Create return items using data from invoice
    const returnItems = data.items.map((item) => {
      const orderItem = orderItems.find(
        (oi) => oi._id.toString() === item.orderItemId,
      );
      if (!orderItem) {
        throw new BadRequestException(`Order item ${item.orderItemId} not found`);
      }
      return {
        returnRequestId: returnRequest._id,
        orderItemId: new Types.ObjectId(item.orderItemId),
        productId: orderItem.productId,
        productSku: orderItem.productSku,
        productName: orderItem.productName,
        productImage: orderItem.productImage,
        quantity: item.quantity,
        unitPrice: orderItem.unitPrice,
        totalValue: item.quantity * orderItem.unitPrice,
      };
    });

    await this.returnItemModel.insertMany(returnItems);

    // Record status history
    await this.recordStatusChange(
      returnRequest._id.toString(),
      '',
      'pending',
      'Return request created',
      undefined,
      true,
    );

    return returnRequest;
  }

  /**
   * Find all return requests
   */
  async findAll(
    filters?: any,
  ): Promise<{ data: any[]; total: number }> {
    const {
      page = 1,
      limit = 20,
      customerId,
      orderId,
      status,
      returnType,
      startDate,
      endDate,
    } = filters || {};

    const query: any = {};
    if (customerId) query.customerId = customerId;
    if (orderId) query.orderIds = orderId; // Support filtering by single orderId
    if (status) query.status = status;
    if (returnType) query.returnType = returnType;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const [returnRequests, total] = await Promise.all([
      this.returnRequestModel
        .find(query)
        .populate('customerId', 'shopName responsiblePersonName phone')
        .populate('orderIds', 'orderNumber')
        .populate('reasonId', 'name nameAr')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ createdAt: -1 })
        .lean(),
      this.returnRequestModel.countDocuments(query),
    ]);

    if (returnRequests.length === 0) {
      return { data: [], total };
    }

    const returnIds = returnRequests.map((r) => r._id);
    const items = await this.returnItemModel
      .find({ returnRequestId: { $in: returnIds } })
      .populate('productId', 'name nameAr mainImage')
      .lean();

    const itemsByReturnId = new Map<string, any[]>();
    for (const item of items) {
      const rid = String(item.returnRequestId);
      const list = itemsByReturnId.get(rid) || [];
      list.push(item);
      itemsByReturnId.set(rid, list);
    }

    const data = returnRequests.map((r) => ({
      ...r,
      items: itemsByReturnId.get(String(r._id)) || [],
    }));

    return { data, total };
  }

  /**
   * Find return request by ID
   */
  async findById(id: string): Promise<{
    returnRequest: ReturnRequestDocument;
    items: ReturnItemDocument[];
    history: ReturnStatusHistoryDocument[];
  }> {
    const returnRequest = await this.returnRequestModel
      .findById(id)
      .populate('customerId')
      .populate('orderIds')
      .populate('reasonId');

    if (!returnRequest) throw new NotFoundException('Return request not found');

    const [items, history] = await Promise.all([
      this.returnItemModel
        .find({ returnRequestId: id })
        .populate('productId', 'name nameAr mainImage'),
      this.statusHistoryModel
        .find({ returnRequestId: id })
        .sort({ createdAt: 1 }),
    ]);

    return { returnRequest, items, history };
  }

  /**
   * Cancel return request (customer-initiated, pending only)
   */
  async cancelReturnRequest(
    id: string,
    customerId: string,
  ): Promise<ReturnRequestDocument> {
    const returnRequest = await this.returnRequestModel.findById(id);
    if (!returnRequest)
      throw new NotFoundException('Return request not found');

    if (returnRequest.status !== 'pending')
      throw new BadRequestException(
        'Only pending return requests can be cancelled',
      );

    const requestCustomerId = returnRequest.customerId?.toString?.();
    if (requestCustomerId !== customerId)
      throw new BadRequestException('You can only cancel your own return');

    return this.updateStatus(id, 'cancelled', undefined, 'Cancelled by customer');
  }

  /**
   * Update return status
   */
  async updateStatus(
    id: string,
    newStatus: string,
    userId?: string,
    notes?: string,
  ): Promise<ReturnRequestDocument> {
    const returnRequest = await this.returnRequestModel.findById(id);
    if (!returnRequest) throw new NotFoundException('Return request not found');

    const oldStatus = returnRequest.status;
    const updateData: any = { status: newStatus };

    switch (newStatus) {
      case 'approved':
        updateData.approvedAt = new Date();
        updateData.processedBy = userId;

        // Automatically process wallet refund on approval
        try {
          const refundAmount = returnRequest.totalItemsValue || 0;
          if (refundAmount > 0) {
            await this.processRefund(id, {
              amount: refundAmount,
              refundMethod: 'wallet',
              processedBy: userId || 'system',
            });
          }
        } catch (err) {
          // Log but don't block approval if refund fails
          console.error(`Auto-refund failed for return ${id}:`, err);
        }
        break;
      case 'rejected':
        updateData.rejectedAt = new Date();
        updateData.rejectionReason = notes;
        updateData.processedBy = userId;
        break;
      case 'completed':
        updateData.completedAt = new Date();
        break;
    }

    const updated = await this.returnRequestModel.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true },
    );

    if (!updated) throw new NotFoundException('Return request not found');

    await this.recordStatusChange(
      id,
      oldStatus,
      newStatus,
      notes,
      userId,
      false,
    );

    return updated;
  }

  /**
   * Inspect return item
   */
  async inspectItem(
    itemId: string,
    data: {
      condition: string;
      approvedQuantity: number;
      rejectedQuantity: number;
      inspectionNotes?: string;
      inspectionImages?: string[];
      inspectedBy: string;
    },
  ): Promise<ReturnItemDocument> {
    const item = await this.returnItemModel.findByIdAndUpdate(
      itemId,
      {
        $set: {
          inspectionStatus: 'inspected',
          condition: data.condition,
          approvedQuantity: data.approvedQuantity,
          rejectedQuantity: data.rejectedQuantity,
          inspectionNotes: data.inspectionNotes,
          inspectionImages: data.inspectionImages,
          inspectedBy: data.inspectedBy,
          inspectedAt: new Date(),
        },
      },
      { new: true },
    );

    if (!item) throw new NotFoundException('Return item not found');
    return item;
  }

  /**
   * Process refund
   * Priority: Credit settlement first (pay off debt), then wallet
   */
  async processRefund(
    returnRequestId: string,
    data: {
      amount: number;
      refundMethod?: string;
      bankDetails?: any;
      processedBy: string;
    },
  ): Promise<RefundDocument> {
    const returnRequest =
      await this.returnRequestModel.findById(returnRequestId);
    if (!returnRequest) throw new NotFoundException('Return request not found');

    // Check customer's cash refund permission
    let refundMethod = data.refundMethod || 'wallet';
    const customer = await this.customersService.findById(
      returnRequest.customerId.toString(),
    );

    // If customer is not allowed to have cash refund, force wallet refund
    if (
      (refundMethod === 'original_payment' || refundMethod === 'bank_transfer') &&
      !customer.canCashRefund
    ) {
      console.log(
        `[ReturnsService] Customer ${returnRequest.customerId} not allowed cash refund, forcing wallet refund`,
      );
      refundMethod = 'wallet';
    }

    const refundNumber = await this.generateRefundNumber();

    // Use first orderId from orderIds array for refund reference
    const primaryOrderId = returnRequest.orderIds && returnRequest.orderIds.length > 0
      ? returnRequest.orderIds[0]
      : null;

    // ═══════════════════════════════════════════════════════════════
    // NEW LOGIC: Credit settlement priority
    // 1. First, settle any outstanding credit debt (creditUsed)
    // 2. Remaining amount goes to wallet
    // ═══════════════════════════════════════════════════════════════
    
    const creditUsed = customer.creditUsed || 0;
    const refundAmount = data.amount;
    
    // Calculate amounts for credit settlement and wallet
    let amountToCreditSettlement = 0;
    let amountToWallet = 0;
    
    if (creditUsed > 0) {
      // Customer has debt - settle credit first
      if (refundAmount <= creditUsed) {
        // Full refund amount goes to settling debt
        amountToCreditSettlement = refundAmount;
        amountToWallet = 0;
      } else {
        // Partial settlement, remainder to wallet
        amountToCreditSettlement = creditUsed;
        amountToWallet = refundAmount - creditUsed;
      }
    } else {
      // No debt - full amount to wallet
      amountToCreditSettlement = 0;
      amountToWallet = refundAmount;
    }

    console.log(
      `[ReturnsService] Refund allocation for customer ${returnRequest.customerId}:`,
      {
        totalRefund: refundAmount,
        creditUsed: creditUsed,
        amountToCreditSettlement,
        amountToWallet,
      },
    );

    const refund = await this.refundModel.create({
      refundNumber,
      returnRequestId,
      orderId: primaryOrderId,
      customerId: returnRequest.customerId,
      amount: data.amount,
      amountToCreditSettlement,
      amountToWallet,
      refundMethod: refundMethod,
      status: 'processing',
      processedBy: data.processedBy,
      processedAt: new Date(),
      ...data.bankDetails,
    });

    // Update return request
    await this.returnRequestModel.findByIdAndUpdate(returnRequestId, {
      $set: { refundAmount: data.amount },
    });

    // ═══════════════════════════════════════════════════════════════
    // 1. Settle credit debt first (if any)
    // ═══════════════════════════════════════════════════════════════
    if (amountToCreditSettlement > 0) {
      await this.customersService.decrementCreditUsed(
        returnRequest.customerId.toString(),
        amountToCreditSettlement,
      );
      console.log(
        `[ReturnsService] Credit settled: ${amountToCreditSettlement} for customer ${returnRequest.customerId}`,
      );
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. Add remaining amount to wallet (if any)
    // ═══════════════════════════════════════════════════════════════
    if (amountToWallet > 0) {
      await this.walletService.credit({
        customerId: returnRequest.customerId.toString(),
        amount: amountToWallet,
        transactionType: 'order_refund',
        referenceType: 'refund',
        referenceId: refund._id.toString(),
        referenceNumber: refund.refundNumber,
        description: 'Refund for return request',
        descriptionAr: `استرداد مبلغ المرتجع ${returnRequest.returnNumber}`,
        idempotencyKey: `refund:${refund._id.toString()}:wallet_credit`,
      });
      console.log(
        `[ReturnsService] Wallet credited: ${amountToWallet} for customer ${returnRequest.customerId}`,
      );
    }

    return refund;
  }

  /**
   * Complete refund
   */
  async completeRefund(
    refundId: string,
    transactionId?: string,
  ): Promise<RefundDocument> {
    const refund = await this.refundModel
      .findByIdAndUpdate(
        refundId,
        {
          $set: {
            status: 'completed',
            completedAt: new Date(),
            transactionId,
          },
        },
        { new: true },
      )
      .populate('returnRequestId');

    if (!refund) throw new NotFoundException('Refund not found');

    // Credit settlement and wallet credit are done in processRefund - no double processing here
    // The new logic in processRefund handles:
    // 1. Credit settlement (decrementing creditUsed) - up to the refund amount
    // 2. Wallet credit - remaining amount after credit settlement

    // Update return request status
    const returnRequestId = (refund.returnRequestId as any)._id.toString();
    await this.updateStatus(returnRequestId, 'completed');

    // Update OrderItem.returnedQuantity for each return item
    const returnItems = await this.returnItemModel.find({
      returnRequestId: new Types.ObjectId(returnRequestId),
    });
    for (const ri of returnItems) {
      const result = await this.orderItemModel.findByIdAndUpdate(
        ri.orderItemId,
        { $inc: { returnedQuantity: ri.quantity } },
        { new: true },
      );
      if (result && result.returnedQuantity >= result.quantity) {
        await this.orderItemModel.findByIdAndUpdate(ri.orderItemId, {
          $set: { status: 'returned' },
        });
      }
    }

    return refund;
  }

  async completeRefundByReturnId(
    returnRequestId: string,
    transactionId?: string,
  ): Promise<RefundDocument> {
    const refund = await this.refundModel
      .findOne({
        returnRequestId: new Types.ObjectId(returnRequestId),
        status: { $in: ['pending', 'processing'] },
      })
      .sort({ createdAt: -1 })
      .select('_id')
      .lean();

    if (!refund?._id) {
      throw new NotFoundException('Refund not found');
    }

    return this.completeRefund(refund._id.toString(), transactionId);
  }

  // ═════════════════════════════════════
  // Return Reasons
  // ═════════════════════════════════════

  async getReturnReasons(): Promise<ReturnReasonDocument[]> {
    return this.returnReasonModel
      .find({ isActive: true })
      .sort({ displayOrder: 1 });
  }

  async createReturnReason(data: any): Promise<ReturnReasonDocument> {
    return this.returnReasonModel.create(data);
  }

  /**
   * Seed default return reasons
   */
  async seedReturnReasons(): Promise<void> {
    const count = await this.returnReasonModel.countDocuments();
    if (count > 0) return;

    console.log('Seeding return reasons...');

    const reasons = [
      {
        name: 'Defective Product',
        nameAr: 'منتج معيب',
        category: 'defective',
        displayOrder: 1,
      },
      {
        name: 'Wrong Item Received',
        nameAr: 'استلمت منتج خاطئ',
        category: 'wrong_item',
        displayOrder: 2,
      },
      {
        name: 'Not as Described',
        nameAr: 'المنتج لا يطابق الوصف',
        category: 'not_as_described',
        displayOrder: 3,
      },
      {
        name: 'Damaged in Shipping',
        nameAr: 'تلف أثناء الشحن',
        category: 'damaged',
        displayOrder: 4,
      },
      {
        name: 'Changed Mind',
        nameAr: 'غيرت رأيي',
        category: 'changed_mind',
        displayOrder: 5,
        eligibleForRefund: true,
        requiresPhoto: false,
      },
      { name: 'Other', nameAr: 'سبب آخر', category: 'other', displayOrder: 6 },
    ];

    await this.returnReasonModel.insertMany(reasons);
    console.log('✅ Return reasons seeded');
  }

  // ═════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════

  private async recordStatusChange(
    returnRequestId: string,
    fromStatus: string,
    toStatus: string,
    notes?: string,
    changedBy?: string,
    isSystem: boolean = false,
  ): Promise<void> {
    await this.statusHistoryModel.create({
      returnRequestId,
      fromStatus: fromStatus || 'new',
      toStatus,
      notes,
      changedBy,
      isSystemGenerated: isSystem,
    });
  }

  private async generateReturnNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'RET';
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');

    const count = await this.returnRequestModel.countDocuments({
      createdAt: { $gte: new Date(date.getFullYear(), date.getMonth(), 1) },
    });

    return `${prefix}${year}${month}${(count + 1).toString().padStart(4, '0')}`;
  }

  private async generateRefundNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'REF';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.refundModel.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(3, '0')}`;
  }

  // ═════════════════════════════════════
  // Supplier Return Batches
  // ═════════════════════════════════════

  /**
   * Create supplier return batch
   */
  async createSupplierReturnBatch(data: {
    supplierId: string;
    returnItemIds?: string[];
    items?: Array<{
      returnItemId?: string;
      productId: string;
      quantity: number;
      unitCost: number;
      notes?: string;
    }>;
    notes?: string;
    createdBy?: string;
  }): Promise<SupplierReturnBatchDocument> {
    const batchNumber = await this.generateBatchNumber();

    // If returnItemIds provided, fetch items and calculate costs
    let items: any[] = [];
    if (data.returnItemIds && data.returnItemIds.length > 0) {
      const returnItems = await this.returnItemModel
        .find({
          _id: { $in: data.returnItemIds.map((id) => new Types.ObjectId(id)) },
        })
        .populate('productId');

      items = returnItems.map((item) => ({
        returnItemId: item._id,
        productId: item.productId,
        quantity: item.approvedQuantity || item.quantity,
        unitCost: 0, // TODO: Get from product or order
        totalCost: 0, // TODO: Calculate
        notes: item.inspectionNotes,
      }));
    } else if (data.items) {
      items = data.items.map((item) => ({
        returnItemId: item.returnItemId
          ? new Types.ObjectId(item.returnItemId)
          : undefined,
        productId: new Types.ObjectId(item.productId),
        quantity: item.quantity,
        unitCost: item.unitCost,
        totalCost: item.quantity * item.unitCost,
        notes: item.notes,
      }));
    }

    // Calculate totals
    const totalItems = items.length;
    const totalQuantity = items.reduce((sum, item) => sum + item.quantity, 0);
    const expectedCreditAmount = items.reduce(
      (sum, item) => sum + item.totalCost,
      0,
    );

    const batch = await this.supplierReturnBatchModel.create({
      batchNumber,
      supplierId: new Types.ObjectId(data.supplierId),
      status: 'draft',
      items,
      totalItems,
      totalQuantity,
      expectedCreditAmount,
      notes: data.notes,
      createdBy: data.createdBy
        ? new Types.ObjectId(data.createdBy)
        : undefined,
    });

    return batch;
  }

  /**
   * Link return item to supplier batch
   */
  async linkReturnToSupplierBatch(
    returnItemId: string,
    batchId: string,
  ): Promise<ReturnItemDocument> {
    const returnItem = await this.returnItemModel.findById(returnItemId);
    if (!returnItem) throw new NotFoundException('Return item not found');

    const batch = await this.supplierReturnBatchModel.findById(batchId);
    if (!batch) throw new NotFoundException('Supplier return batch not found');

    // Update return item
    returnItem.linkedToSupplierBatch = true;
    returnItem.supplierReturnBatchId = new Types.ObjectId(batchId);
    await returnItem.save();

    // Add to batch if not already there
    const existsInBatch = batch.items.some(
      (item) => item.returnItemId?.toString() === returnItemId,
    );

    if (!existsInBatch) {
      batch.items.push({
        returnItemId: new Types.ObjectId(returnItemId),
        productId: returnItem.productId,
        quantity: returnItem.approvedQuantity || returnItem.quantity,
        unitCost: 0, // TODO: Get from product
        totalCost: 0, // TODO: Calculate
      });

      // Recalculate totals
      batch.totalItems = batch.items.length;
      batch.totalQuantity = batch.items.reduce(
        (sum, item) => sum + item.quantity,
        0,
      );
      batch.expectedCreditAmount = batch.items.reduce(
        (sum, item) => sum + item.totalCost,
        0,
      );

      await batch.save();
    }

    return returnItem;
  }

  /**
   * Get supplier return batches
   */
  async getSupplierReturnBatches(
    filters?: any,
  ): Promise<SupplierReturnBatchDocument[]> {
    const { supplierId, status } = filters || {};
    const query: any = {};

    if (supplierId) query.supplierId = supplierId;
    if (status) query.status = status;

    return this.supplierReturnBatchModel
      .find(query)
      .populate('supplierId', 'name code')
      .populate('createdBy', 'fullName')
      .populate('approvedBy', 'fullName')
      .populate('items.productId', 'name nameAr sku')
      .sort({ createdAt: -1 });
  }

  /**
   * Update supplier batch status
   */
  async updateSupplierBatchStatus(
    batchId: string,
    status: string,
    userId?: string,
    data?: any,
  ): Promise<SupplierReturnBatchDocument> {
    const batch = await this.supplierReturnBatchModel.findById(batchId);
    if (!batch) throw new NotFoundException('Supplier return batch not found');

    const updateData: any = { status };

    switch (status) {
      case 'approved':
        updateData.approvedBy = userId ? new Types.ObjectId(userId) : undefined;
        updateData.approvedAt = new Date();
        break;
      case 'sent_to_supplier':
        updateData.sentDate = new Date();
        break;
      case 'acknowledged':
        updateData.acknowledgedDate = data?.acknowledgedDate
          ? new Date(data.acknowledgedDate)
          : new Date();
        updateData.supplierReference = data?.supplierReference;
        break;
      case 'credited':
      case 'partial_credit':
        updateData.creditDate = data?.creditDate
          ? new Date(data.creditDate)
          : new Date();
        updateData.creditNoteNumber = data?.creditNoteNumber;
        updateData.actualCreditAmount =
          data?.actualCreditAmount || batch.expectedCreditAmount;
        break;
    }

    if (data?.supplierNotes) updateData.supplierNotes = data.supplierNotes;

    const updated = await this.supplierReturnBatchModel.findByIdAndUpdate(
      batchId,
      { $set: updateData },
      { new: true },
    );

    if (!updated) {
      throw new NotFoundException(
        'Supplier return batch not found after update',
      );
    }

    return updated;
  }

  /**
   * Generate batch number
   */
  private async generateBatchNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'SRB';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.supplierReturnBatchModel.countDocuments({
      createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
  }
}
