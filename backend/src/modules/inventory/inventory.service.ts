import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  ProductStock,
  ProductStockDocument,
} from './schemas/product-stock.schema';
import {
  StockMovement,
  StockMovementDocument,
} from './schemas/stock-movement.schema';
import {
  StockReservation,
  StockReservationDocument,
} from './schemas/stock-reservation.schema';
import {
  LowStockAlert,
  LowStockAlertDocument,
} from './schemas/low-stock-alert.schema';
import { Warehouse, WarehouseDocument } from './schemas/warehouse.schema';
import {
  InventoryCount,
  InventoryCountDocument,
} from './schemas/inventory-count.schema';
import {
  StockTransfer,
  StockTransferDocument,
} from './schemas/stock-transfer.schema';
import { AuditService } from '@modules/audit/audit.service';
import { AuditAction, AuditResource } from '@modules/audit/schemas/audit-log.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Inventory Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class InventoryService {
  constructor(
    @InjectModel(ProductStock.name)
    private productStockModel: Model<ProductStockDocument>,
    @InjectModel(StockMovement.name)
    private stockMovementModel: Model<StockMovementDocument>,
    @InjectModel(StockReservation.name)
    private stockReservationModel: Model<StockReservationDocument>,
    @InjectModel(LowStockAlert.name)
    private lowStockAlertModel: Model<LowStockAlertDocument>,
    @InjectModel(Warehouse.name)
    private warehouseModel: Model<WarehouseDocument>,
    @InjectModel(InventoryCount.name)
    private inventoryCountModel: Model<InventoryCountDocument>,
    @InjectModel(StockTransfer.name)
    private stockTransferModel: Model<StockTransferDocument>,
    private auditService: AuditService,
  ) {}

  /**
   * Get inventory stats for dashboard (totalWarehouses, totalStock, low/out of stock, alerts, today movements).
   */
  async getInventoryStats(): Promise<{
    totalWarehouses: number;
    totalProducts: number;
    totalStock: number;
    lowStockItems: number;
    outOfStockItems: number;
    pendingAlerts: number;
    todayMovements: number;
  }> {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    const [
      totalWarehouses,
      pendingAlerts,
      todayMovements,
      stockAgg,
    ] = await Promise.all([
      this.warehouseModel.countDocuments(),
      this.lowStockAlertModel.countDocuments({ status: 'pending' }),
      this.stockMovementModel.countDocuments({
        createdAt: { $gte: todayStart, $lte: todayEnd },
      }),
      this.productStockModel.aggregate([
        {
          $group: {
            _id: null,
            totalStock: { $sum: '$quantity' },
            totalProducts: { $addToSet: '$productId' },
            lowStockItems: {
              $sum: {
                $cond: [
                  {
                    $and: [
                      { $gt: ['$quantity', 0] },
                      { $lte: ['$quantity', '$lowStockThreshold'] },
                    ],
                  },
                  1,
                  0,
                ],
              },
            },
            outOfStockItems: {
              $sum: { $cond: [{ $eq: ['$quantity', 0] }, 1, 0] },
            },
          },
        },
      ]),
    ]);

    const aggResult = stockAgg[0];
    const totalProducts = aggResult?.totalProducts?.length ?? 0;
    const totalStock = aggResult?.totalStock ?? 0;
    const lowStockItems = aggResult?.lowStockItems ?? 0;
    const outOfStockItems = aggResult?.outOfStockItems ?? 0;

    return {
      totalWarehouses,
      totalProducts,
      totalStock,
      lowStockItems,
      outOfStockItems,
      pendingAlerts,
      todayMovements,
    };
  }

  /**
   * Get all stock records with optional warehouseId and status filter.
   */
  async getAllStock(query?: {
    warehouseId?: string;
    status?: string;
  }): Promise<any[]> {
    const filter: any = {};
    if (query?.warehouseId) filter.warehouseId = query.warehouseId;

    const stocks = await this.productStockModel
      .find(filter)
      .populate('productId', 'name nameAr sku mainImage')
      .populate('warehouseId', 'name code')
      .lean();

    let list = stocks.map((s: any) => {
      const quantity = s.quantity ?? 0;
      const reservedQuantity = s.reservedQuantity ?? 0;
      const availableQuantity = quantity - reservedQuantity;
      const lowThreshold = s.lowStockThreshold ?? 0;
      const status =
        quantity === 0
          ? 'out_of_stock'
          : quantity <= lowThreshold
            ? 'low_stock'
            : 'in_stock';
      return {
        _id: s._id,
        productId: s.productId?._id ?? s.productId,
        product: s.productId
          ? {
              name: s.productId.name || s.productId.nameAr,
              sku: s.productId.sku,
              image: s.productId.mainImage,
            }
          : undefined,
        warehouseId: s.warehouseId?._id ?? s.warehouseId,
        warehouse: s.warehouseId
          ? { name: s.warehouseId.name }
          : undefined,
        locationId: s.defaultLocationId,
        quantity,
        reservedQuantity,
        availableQuantity,
        minStockLevel: lowThreshold,
        maxStockLevel: s.reorderQuantity,
        status,
      };
    });

    if (query?.status && query.status !== 'all') {
      list = list.filter((s) => s.status === query.status);
    }

    return list;
  }

  /**
   * Get all active (confirmed) reservations with optional filters.
   */
  async getReservations(query?: any): Promise<any[]> {
    const filter: any = { status: 'confirmed' };
    if (query?.productId) filter.productId = query.productId;
    if (query?.warehouseId) filter.warehouseId = query.warehouseId;
    if (query?.referenceId) filter.referenceId = query.referenceId;

    const reservations = await this.stockReservationModel
      .find(filter)
      .populate('productId', 'name nameAr sku')
      .populate('warehouseId', 'name code')
      .sort({ createdAt: -1 })
      .lean();

    return reservations.map((r: any) => ({
      _id: r._id,
      productId: r.productId?._id ?? r.productId,
      product: r.productId
        ? {
            name: r.productId.name || r.productId.nameAr,
            sku: r.productId.sku,
          }
        : undefined,
      warehouseId: r.warehouseId?._id ?? r.warehouseId,
      warehouse: r.warehouseId ? { name: r.warehouseId.name } : undefined,
      quantity: r.quantity,
      reservationType: r.reservationType,
      referenceId: r.referenceId,
      referenceNumber: r.referenceNumber,
      orderId: r.reservationType === 'order' ? r.referenceId : undefined,
      orderNumber: r.referenceNumber,
      status: 'active',
      expiresAt: r.expiresAt,
      createdAt: r.createdAt,
    }));
  }

  /**
   * Get stock for product across all warehouses
   */
  async getProductStock(productId: string): Promise<ProductStockDocument[]> {
    return this.productStockModel
      .find({ productId })
      .populate('warehouseId', 'name code');
  }

  /**
   * Get stock for product in specific warehouse
   */
  async getStock(
    productId: string,
    warehouseId: string,
  ): Promise<ProductStockDocument> {
    let stock = await this.productStockModel.findOne({
      productId,
      warehouseId,
    });

    if (!stock) {
      // Create stock record if doesn't exist
      stock = await this.productStockModel.create({
        productId,
        warehouseId,
        quantity: 0,
        reservedQuantity: 0,
      });
    }

    return stock;
  }

  /**
   * Get available quantity (quantity - reserved)
   */
  async getAvailableQuantity(
    productId: string,
    warehouseId?: string,
  ): Promise<number> {
    const query: any = { productId };
    if (warehouseId) query.warehouseId = warehouseId;

    const stocks = await this.productStockModel.find(query);
    return stocks.reduce((total, stock) => {
      return total + (stock.quantity - stock.reservedQuantity);
    }, 0);
  }

  /**
   * Check if product has any stock records (inventory set up).
   * Used to distinguish "no inventory set up" (allow in cart) from "out of stock" (block).
   */
  async hasStockRecords(productId: string): Promise<boolean> {
    const count = await this.productStockModel.countDocuments({ productId });
    return count > 0;
  }

  /**
   * Adjust stock (create movement)
   */
  async adjustStock(data: {
    productId: string;
    warehouseId: string;
    quantity: number;
    movementType: string;
    referenceType?: string;
    referenceId?: string;
    referenceNumber?: string;
    notes?: string;
    createdBy?: string;
  }): Promise<StockMovementDocument> {
    const stock = await this.getStock(data.productId, data.warehouseId);
    const quantityBefore = stock.quantity;

    // Determine if adding or removing
    const isInbound = [
      'purchase_in',
      'sale_return',
      'transfer_in',
      'adjustment_in',
      'assembly_in',
    ].includes(data.movementType);

    const quantityChange = isInbound
      ? Math.abs(data.quantity)
      : -Math.abs(data.quantity);
    const quantityAfter = quantityBefore + quantityChange;

    // Check if going negative
    if (quantityAfter < 0) {
      const warehouse = await this.warehouseModel.findById(data.warehouseId);
      if (!warehouse?.allowNegativeStock) {
        throw new BadRequestException('Insufficient stock quantity');
      }
    }

    // Generate movement number
    const movementNumber = await this.generateMovementNumber();

    // Create movement
    const movement = await this.stockMovementModel.create({
      movementNumber,
      movementType: data.movementType,
      warehouseId: data.warehouseId,
      productId: data.productId,
      quantity: Math.abs(data.quantity),
      quantityBefore,
      quantityAfter,
      referenceType: data.referenceType,
      referenceId: data.referenceId,
      referenceNumber: data.referenceNumber,
      notes: data.notes,
      createdBy: data.createdBy,
    });

    // Update stock
    await this.productStockModel.findByIdAndUpdate(stock._id, {
      $set: { quantity: quantityAfter },
      $currentDate: isInbound ? { lastReceivedAt: true } : { lastSoldAt: true },
    });

    // Check low stock
    await this.checkLowStock(data.productId, data.warehouseId);

    // Audit log (when performed by admin)
    if (data.createdBy) {
      await this.auditService.log({
        action: AuditAction.UPDATE,
        resource: AuditResource.INVENTORY,
        resourceId: movement._id.toString(),
        resourceName: movement.movementNumber,
        actorType: 'admin',
        actorId: data.createdBy,
        description: `Stock adjusted: ${data.movementType} qty ${data.quantity} (${movement.movementNumber})`,
        descriptionAr: `تم تعديل المخزون: ${data.movementType} كمية ${data.quantity}`,
        severity: 'info',
        success: true,
      }).catch(() => undefined);
    }

    return movement;
  }

  /**
   * Reserve stock for order
   */
  async reserveStock(data: {
    productId: string;
    warehouseId: string;
    quantity: number;
    reservationType: string;
    referenceId: string;
    referenceNumber?: string;
    expiresAt?: Date;
  }): Promise<StockReservationDocument> {
    const available = await this.getAvailableQuantity(
      data.productId,
      data.warehouseId,
    );

    if (available < data.quantity) {
      throw new BadRequestException(
        `Insufficient stock. Available: ${available}`,
      );
    }

    // Create reservation
    const reservation = await this.stockReservationModel.create({
      ...data,
      status: 'confirmed',
    });

    // Update reserved quantity
    await this.productStockModel.findOneAndUpdate(
      { productId: data.productId, warehouseId: data.warehouseId },
      { $inc: { reservedQuantity: data.quantity } },
    );

    return reservation;
  }

  /**
   * Release reservation
   */
  async releaseReservation(
    reservationId: string,
    reason?: string,
  ): Promise<void> {
    const reservation =
      await this.stockReservationModel.findById(reservationId);

    if (!reservation || reservation.status !== 'confirmed') {
      return;
    }

    await this.stockReservationModel.findByIdAndUpdate(reservationId, {
      $set: {
        status: 'cancelled',
        cancelledAt: new Date(),
        cancellationReason: reason,
      },
    });

    await this.productStockModel.findOneAndUpdate(
      {
        productId: reservation.productId,
        warehouseId: reservation.warehouseId,
      },
      { $inc: { reservedQuantity: -reservation.quantity } },
    );
  }

  /**
   * Fulfill reservation (convert to movement)
   */
  async fulfillReservation(reservationId: string): Promise<void> {
    const reservation =
      await this.stockReservationModel.findById(reservationId);

    if (!reservation || reservation.status !== 'confirmed') {
      throw new BadRequestException('Reservation not found or not confirmed');
    }

    // Create outbound movement
    await this.adjustStock({
      productId: reservation.productId.toString(),
      warehouseId: reservation.warehouseId.toString(),
      quantity: reservation.quantity,
      movementType: 'sale_out',
      referenceType: reservation.reservationType,
      referenceId: reservation.referenceId.toString(),
      referenceNumber: reservation.referenceNumber,
    });

    // Update reservation
    await this.stockReservationModel.findByIdAndUpdate(reservationId, {
      $set: { status: 'fulfilled', fulfilledAt: new Date() },
    });

    // Decrease reserved quantity
    await this.productStockModel.findOneAndUpdate(
      {
        productId: reservation.productId,
        warehouseId: reservation.warehouseId,
      },
      { $inc: { reservedQuantity: -reservation.quantity } },
    );
  }

  /**
   * Check and create low stock alert
   */
  async checkLowStock(productId: string, warehouseId: string): Promise<void> {
    const stock = await this.productStockModel.findOne({
      productId,
      warehouseId,
    });

    if (!stock) return;

    let alertLevel: string | null = null;

    if (stock.quantity === 0) {
      alertLevel = 'out_of_stock';
    } else if (stock.quantity <= stock.criticalStockThreshold) {
      alertLevel = 'critical';
    } else if (stock.quantity <= stock.lowStockThreshold) {
      alertLevel = 'low';
    }

    if (alertLevel) {
      // Create or update alert
      await this.lowStockAlertModel.findOneAndUpdate(
        { productId, warehouseId, status: 'pending' },
        {
          $set: {
            currentQuantity: stock.quantity,
            threshold: stock.lowStockThreshold,
            alertLevel,
          },
        },
        { upsert: true },
      );
    } else {
      // Resolve any existing alerts
      await this.lowStockAlertModel.updateMany(
        { productId, warehouseId, status: 'pending' },
        { $set: { status: 'resolved', resolvedAt: new Date() } },
      );
    }
  }

  /**
   * Get stock movements
   */
  async getMovements(
    filters: any,
  ): Promise<{ data: StockMovementDocument[]; total: number }> {
    const {
      page = 1,
      limit = 50,
      productId,
      warehouseId,
      movementType,
      startDate,
      endDate,
    } = filters;

    const query: any = {};
    if (productId) query.productId = productId;
    if (warehouseId) query.warehouseId = warehouseId;
    if (movementType) query.movementType = movementType;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const [data, total] = await Promise.all([
      this.stockMovementModel
        .find(query)
        .populate('productId', 'name nameAr sku')
        .populate('warehouseId', 'name code')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ createdAt: -1 }),
      this.stockMovementModel.countDocuments(query),
    ]);

    return { data, total };
  }

  /**
   * Get low stock alerts
   */
  async getLowStockAlerts(status?: string): Promise<LowStockAlertDocument[]> {
    const query: any = {};
    if (status) query.status = status;

    return this.lowStockAlertModel
      .find(query)
      .populate('productId', 'name nameAr sku mainImage')
      .populate('warehouseId', 'name code')
      .sort({ alertLevel: -1, createdAt: -1 });
  }

  /**
   * Generate movement number
   */
  private async generateMovementNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'MOV';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.stockMovementModel.countDocuments({
      createdAt: {
        $gte: new Date(date.setHours(0, 0, 0, 0)),
        $lt: new Date(date.setHours(23, 59, 59, 999)),
      },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
  }

  // ═════════════════════════════════════
  // Inventory Counts
  // ═════════════════════════════════════

  /**
   * Create inventory count
   */
  async createInventoryCount(data: {
    warehouseId: string;
    countType: 'full' | 'partial' | 'cycle';
    categories?: string[];
    brands?: string[];
    locations?: string[];
    notes?: string;
    createdBy?: string;
  }): Promise<InventoryCountDocument> {
    const countNumber = await this.generateCountNumber();

    const count = await this.inventoryCountModel.create({
      countNumber,
      warehouseId: new Types.ObjectId(data.warehouseId),
      countType: data.countType,
      status: 'draft',
      categories: data.categories?.map((id) => new Types.ObjectId(id)),
      brands: data.brands?.map((id) => new Types.ObjectId(id)),
      locations: data.locations?.map((id) => new Types.ObjectId(id)),
      notes: data.notes,
      createdBy: data.createdBy
        ? new Types.ObjectId(data.createdBy)
        : undefined,
    });

    return count;
  }

  /**
   * Complete inventory count
   */
  async completeInventoryCount(
    countId: string,
    items: Array<{
      productId: string;
      countedQuantity: number;
      notes?: string;
    }>,
    userId: string,
  ): Promise<InventoryCountDocument> {
    const count = await this.inventoryCountModel.findById(countId);
    if (!count) throw new NotFoundException('Inventory count not found');

    if (count.status !== 'in_progress' && count.status !== 'draft') {
      throw new BadRequestException(
        `Cannot complete count with status: ${count.status}`,
      );
    }

    const totalVarianceValue = 0;
    let varianceItemsCount = 0;

    // Update items with counted quantities
    for (const item of items) {
      const countItem = count.items.find(
        (i) => i.productId.toString() === item.productId,
      );

      if (countItem) {
        countItem.countedQuantity = item.countedQuantity;
        countItem.variance = item.countedQuantity - countItem.expectedQuantity;
        countItem.notes = item.notes;
        countItem.countedBy = new Types.ObjectId(userId);
        countItem.countedAt = new Date();

        if (countItem.variance !== 0) {
          varianceItemsCount++;
          // TODO: Calculate variance value based on product cost
        }
      }
    }

    // Update statistics
    count.countedItems = items.length;
    count.varianceItems = varianceItemsCount;
    count.totalVarianceValue = totalVarianceValue;
    count.status = 'pending_review';
    count.completedAt = new Date();

    await count.save();

    return count;
  }

  /**
   * Approve inventory count and apply adjustments
   */
  async approveInventoryCount(
    countId: string,
    approvedBy: string,
  ): Promise<InventoryCountDocument> {
    const count = await this.inventoryCountModel.findById(countId);
    if (!count) throw new NotFoundException('Inventory count not found');

    if (count.status !== 'pending_review') {
      throw new BadRequestException(
        `Cannot approve count with status: ${count.status}`,
      );
    }

    // Apply adjustments
    for (const item of count.items) {
      if (item.variance && item.variance !== 0) {
        await this.adjustStock({
          productId: item.productId.toString(),
          warehouseId: count.warehouseId.toString(),
          quantity: Math.abs(item.variance),
          movementType: item.variance > 0 ? 'adjustment_in' : 'adjustment_out',
          referenceType: 'inventory_count',
          referenceId: countId,
          referenceNumber: count.countNumber,
          notes: item.notes || `Inventory count adjustment`,
          createdBy: approvedBy,
        });
      }
    }

    // Update count status
    count.status = 'approved';
    count.approvedBy = new Types.ObjectId(approvedBy);
    count.approvedAt = new Date();

    await count.save();

    return count;
  }

  /**
   * Get inventory counts
   */
  async getInventoryCounts(filters?: any): Promise<InventoryCountDocument[]> {
    const { warehouseId, status, countType } = filters || {};
    const query: any = {};

    if (warehouseId) query.warehouseId = warehouseId;
    if (status) query.status = status;
    if (countType) query.countType = countType;

    return this.inventoryCountModel
      .find(query)
      .populate('warehouseId', 'name code')
      .populate('createdBy', 'fullName')
      .populate('approvedBy', 'fullName')
      .sort({ createdAt: -1 });
  }

  /**
   * Generate count number
   */
  private async generateCountNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'CNT';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.inventoryCountModel.countDocuments({
      createdAt: {
        $gte: new Date(date.setHours(0, 0, 0, 0)),
      },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
  }

  // ═════════════════════════════════════
  // Stock Transfers
  // ═════════════════════════════════════

  async createStockTransfer(data: {
    fromWarehouseId: string;
    toWarehouseId: string;
    items: Array<{ productId: string; quantity?: number; requestedQuantity?: number }>;
    note?: string;
    requestedBy?: string;
  }): Promise<StockTransferDocument> {
    if (data.fromWarehouseId === data.toWarehouseId) {
      throw new BadRequestException(
        'Source and destination warehouses must be different',
      );
    }

    if (!Array.isArray(data.items) || data.items.length === 0) {
      throw new BadRequestException('Transfer must include at least one item');
    }

    const transferNumber = await this.generateTransferNumber();
    const normalizedItems = data.items
      .map((item) => {
        const requestedQuantity = Number(
          item.requestedQuantity ?? item.quantity ?? 0,
        );
        return {
          productId: new Types.ObjectId(item.productId),
          requestedQuantity,
        };
      })
      .filter((item) => item.requestedQuantity > 0);

    if (normalizedItems.length === 0) {
      throw new BadRequestException('Transfer items must have valid quantities');
    }

    const transfer = await this.stockTransferModel.create({
      transferNumber,
      fromWarehouseId: new Types.ObjectId(data.fromWarehouseId),
      toWarehouseId: new Types.ObjectId(data.toWarehouseId),
      status: 'pending',
      items: normalizedItems,
      notes: data.note,
      requestedBy: data.requestedBy
        ? new Types.ObjectId(data.requestedBy)
        : undefined,
      requestedAt: new Date(),
    });

    return transfer;
  }

  /**
   * Approve stock transfer
   */
  async approveStockTransfer(
    transferId: string,
    approvedBy: string,
  ): Promise<StockTransferDocument> {
    const transfer = await this.stockTransferModel.findById(transferId);
    if (!transfer) throw new NotFoundException('Stock transfer not found');

    if (transfer.status !== 'pending' && transfer.status !== 'draft') {
      throw new BadRequestException(
        `Cannot approve transfer with status: ${transfer.status}`,
      );
    }

    // Check stock availability in source warehouse
    for (const item of transfer.items) {
      const available = await this.getAvailableQuantity(
        item.productId.toString(),
        transfer.fromWarehouseId.toString(),
      );

      if (available < item.requestedQuantity) {
        throw new BadRequestException(
          `Insufficient stock for product ${item.productId} in source warehouse`,
        );
      }
    }

    transfer.status = 'pending'; // Move to pending for shipping
    transfer.approvedBy = new Types.ObjectId(approvedBy);
    transfer.approvedAt = new Date();

    await transfer.save();

    return transfer;
  }

  /**
   * Ship stock transfer
   */
  async shipStockTransfer(
    transferId: string,
    shippedBy: string,
    sentQuantities?: Array<{ productId: string; sentQuantity: number }>,
  ): Promise<StockTransferDocument> {
    const transfer = await this.stockTransferModel.findById(transferId);
    if (!transfer) throw new NotFoundException('Stock transfer not found');

    if (transfer.status !== 'pending') {
      throw new BadRequestException(
        `Cannot ship transfer with status: ${transfer.status}`,
      );
    }

    // Update sent quantities if provided
    if (sentQuantities) {
      for (const sent of sentQuantities) {
        const item = transfer.items.find(
          (i) => i.productId.toString() === sent.productId,
        );
        if (item) {
          item.sentQuantity = sent.sentQuantity;
        }
      }
    } else {
      // Use requested quantities as sent
      transfer.items.forEach((item) => {
        item.sentQuantity = item.requestedQuantity;
      });
    }

    // Deduct stock from source warehouse
    for (const item of transfer.items) {
      if (item.sentQuantity && item.sentQuantity > 0) {
        await this.adjustStock({
          productId: item.productId.toString(),
          warehouseId: transfer.fromWarehouseId.toString(),
          quantity: item.sentQuantity,
          movementType: 'transfer_out',
          referenceType: 'stock_transfer',
          referenceId: transferId,
          referenceNumber: transfer.transferNumber,
          notes: `Transfer to warehouse ${transfer.toWarehouseId}`,
          createdBy: shippedBy,
        });
      }
    }

    transfer.status = 'in_transit';
    transfer.sentBy = new Types.ObjectId(shippedBy);
    transfer.sentAt = new Date();

    await transfer.save();

    return transfer;
  }

  /**
   * Receive stock transfer
   */
  async receiveStockTransfer(
    transferId: string,
    receivedBy: string,
    receivedQuantities?: Array<{ productId: string; receivedQuantity: number }>,
  ): Promise<StockTransferDocument> {
    const transfer = await this.stockTransferModel.findById(transferId);
    if (!transfer) throw new NotFoundException('Stock transfer not found');

    if (transfer.status !== 'in_transit') {
      throw new BadRequestException(
        `Cannot receive transfer with status: ${transfer.status}`,
      );
    }

    // Update received quantities if provided
    if (receivedQuantities) {
      for (const received of receivedQuantities) {
        const item = transfer.items.find(
          (i) => i.productId.toString() === received.productId,
        );
        if (item) {
          item.receivedQuantity = received.receivedQuantity;
        }
      }
    } else {
      // Use sent quantities as received
      transfer.items.forEach((item) => {
        item.receivedQuantity = item.sentQuantity || item.requestedQuantity;
      });
    }

    // Add stock to destination warehouse
    for (const item of transfer.items) {
      if (item.receivedQuantity && item.receivedQuantity > 0) {
        await this.adjustStock({
          productId: item.productId.toString(),
          warehouseId: transfer.toWarehouseId.toString(),
          quantity: item.receivedQuantity,
          movementType: 'transfer_in',
          referenceType: 'stock_transfer',
          referenceId: transferId,
          referenceNumber: transfer.transferNumber,
          notes: `Transfer from warehouse ${transfer.fromWarehouseId}`,
          createdBy: receivedBy,
        });
      }
    }

    transfer.status = 'completed';
    transfer.receivedBy = new Types.ObjectId(receivedBy);
    transfer.receivedAt = new Date();

    await transfer.save();

    return transfer;
  }

  /**
   * Get stock transfers
   */
  async getStockTransfers(filters?: any): Promise<StockTransferDocument[]> {
    const { warehouseId, status, fromWarehouseId, toWarehouseId } =
      filters || {};
    const query: any = {};

    if (warehouseId) {
      query.$or = [
        { fromWarehouseId: warehouseId },
        { toWarehouseId: warehouseId },
      ];
    }
    if (fromWarehouseId) query.fromWarehouseId = fromWarehouseId;
    if (toWarehouseId) query.toWarehouseId = toWarehouseId;
    if (status) query.status = status;

    return this.stockTransferModel
      .find(query)
      .populate('fromWarehouseId', 'name code')
      .populate('toWarehouseId', 'name code')
      .populate('requestedBy', 'fullName')
      .populate('approvedBy', 'fullName')
      .populate('sentBy', 'fullName')
      .populate('receivedBy', 'fullName')
      .sort({ createdAt: -1 });
  }

  private async generateTransferNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'TRF';
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

    const count = await this.stockTransferModel.countDocuments({
      createdAt: {
        $gte: new Date(date.setHours(0, 0, 0, 0)),
        $lt: new Date(date.setHours(23, 59, 59, 999)),
      },
    });

    return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
  }
}
