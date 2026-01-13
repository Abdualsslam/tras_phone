import { Injectable, NotFoundException } from '@nestjs/common';
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
  ) {}

  /**
   * Create return request
   */
  async createReturnRequest(data: {
    orderId: string;
    customerId: string;
    returnType: string;
    reasonId: string;
    items: {
      orderItemId: string;
      productId: string;
      quantity: number;
      unitPrice: number;
    }[];
    customerNotes?: string;
    customerImages?: string[];
    pickupAddress?: any;
  }): Promise<ReturnRequestDocument> {
    const returnNumber = await this.generateReturnNumber();

    // Calculate total value
    const totalItemsValue = data.items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0,
    );

    // Create return request
    const returnRequest = await this.returnRequestModel.create({
      returnNumber,
      orderId: data.orderId,
      customerId: data.customerId,
      returnType: data.returnType,
      reasonId: data.reasonId,
      customerNotes: data.customerNotes,
      customerImages: data.customerImages,
      pickupAddress: data.pickupAddress,
      totalItemsValue,
      status: 'pending',
    });

    // Create return items
    const returnItems = data.items.map((item) => ({
      returnRequestId: returnRequest._id,
      orderItemId: item.orderItemId,
      productId: item.productId,
      productSku: '', // Will be populated
      productName: '', // Will be populated
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalValue: item.quantity * item.unitPrice,
    }));

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
  ): Promise<{ data: ReturnRequestDocument[]; total: number }> {
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
    if (orderId) query.orderId = orderId;
    if (status) query.status = status;
    if (returnType) query.returnType = returnType;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const [data, total] = await Promise.all([
      this.returnRequestModel
        .find(query)
        .populate('customerId', 'shopName responsiblePersonName phone')
        .populate('orderId', 'orderNumber')
        .populate('reasonId', 'name nameAr')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ createdAt: -1 }),
      this.returnRequestModel.countDocuments(query),
    ]);

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
      .populate('orderId')
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
   */
  async processRefund(
    returnRequestId: string,
    data: {
      amount: number;
      refundMethod: string;
      bankDetails?: any;
      processedBy: string;
    },
  ): Promise<RefundDocument> {
    const returnRequest =
      await this.returnRequestModel.findById(returnRequestId);
    if (!returnRequest) throw new NotFoundException('Return request not found');

    const refundNumber = await this.generateRefundNumber();

    const refund = await this.refundModel.create({
      refundNumber,
      returnRequestId,
      orderId: returnRequest.orderId,
      customerId: returnRequest.customerId,
      amount: data.amount,
      refundMethod: data.refundMethod,
      status: 'processing',
      processedBy: data.processedBy,
      processedAt: new Date(),
      ...data.bankDetails,
    });

    // Update return request
    await this.returnRequestModel.findByIdAndUpdate(returnRequestId, {
      $set: { refundAmount: data.amount },
    });

    return refund;
  }

  /**
   * Complete refund
   */
  async completeRefund(
    refundId: string,
    transactionId?: string,
  ): Promise<RefundDocument> {
    const refund = await this.refundModel.findByIdAndUpdate(
      refundId,
      {
        $set: {
          status: 'completed',
          completedAt: new Date(),
          transactionId,
        },
      },
      { new: true },
    );

    if (!refund) throw new NotFoundException('Refund not found');

    // Update return request status
    await this.updateStatus(refund.returnRequestId.toString(), 'completed');

    return refund;
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
