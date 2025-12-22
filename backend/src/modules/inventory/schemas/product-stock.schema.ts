import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductStockDocument = ProductStock & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Product Stock Schema (Stock per Warehouse)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'product_stocks',
})
export class ProductStock {
    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    warehouseId: Types.ObjectId;

    // ═════════════════════════════════════
    // Quantities
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    quantity: number; // Total physical quantity

    @Prop({ type: Number, default: 0 })
    reservedQuantity: number; // Reserved for orders

    @Prop({ type: Number, default: 0 })
    damagedQuantity: number;

    // ═════════════════════════════════════
    // Thresholds
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 5 })
    lowStockThreshold: number;

    @Prop({ type: Number, default: 2 })
    criticalStockThreshold: number;

    @Prop({ type: Number })
    reorderPoint?: number;

    @Prop({ type: Number })
    reorderQuantity?: number;

    // ═════════════════════════════════════
    // Location
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'StockLocation' })
    defaultLocationId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Last Activity
    // ═════════════════════════════════════
    @Prop({ type: Date })
    lastReceivedAt?: Date;

    @Prop({ type: Date })
    lastSoldAt?: Date;

    @Prop({ type: Date })
    lastCountedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const ProductStockSchema = SchemaFactory.createForClass(ProductStock);

ProductStockSchema.index({ productId: 1, warehouseId: 1 }, { unique: true });
ProductStockSchema.index({ quantity: 1 });
ProductStockSchema.index({ warehouseId: 1, quantity: 1 });

// ═════════════════════════════════════
// Virtuals
// ═════════════════════════════════════
ProductStockSchema.virtual('availableQuantity').get(function () {
    return this.quantity - this.reservedQuantity;
});

ProductStockSchema.virtual('isLowStock').get(function () {
    return this.quantity <= this.lowStockThreshold;
});

ProductStockSchema.virtual('isCritical').get(function () {
    return this.quantity <= this.criticalStockThreshold;
});

ProductStockSchema.virtual('isOutOfStock').get(function () {
    return this.quantity === 0;
});
