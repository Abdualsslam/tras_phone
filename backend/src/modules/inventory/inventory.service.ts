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
  ) {}

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
}
