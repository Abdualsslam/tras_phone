import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type InventoryCountDocument = InventoryCount & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Inventory Count Schema (Full/Partial/Cycle Count)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'inventory_counts',
})
export class InventoryCount {
    @Prop({ required: true, unique: true })
    countNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    warehouseId: Types.ObjectId;

    @Prop({
        required: true,
        type: String,
        enum: ['full', 'partial', 'cycle'],
    })
    countType: string;

    @Prop({
        type: String,
        enum: ['draft', 'in_progress', 'pending_review', 'approved', 'completed', 'cancelled'],
        default: 'draft',
    })
    status: string;

    @Prop()
    notes?: string;

    // ═════════════════════════════════════
    // Filter (for partial counts)
    // ═════════════════════════════════════
    @Prop({ type: [Types.ObjectId], ref: 'Category' })
    categories?: Types.ObjectId[];

    @Prop({ type: [Types.ObjectId], ref: 'Brand' })
    brands?: Types.ObjectId[];

    @Prop({ type: [Types.ObjectId], ref: 'StockLocation' })
    locations?: Types.ObjectId[];

    // ═════════════════════════════════════
    // Items
    // ═════════════════════════════════════
    @Prop({
        type: [{
            productId: { type: Types.ObjectId, ref: 'Product', required: true },
            locationId: { type: Types.ObjectId, ref: 'StockLocation' },
            expectedQuantity: { type: Number, required: true },
            countedQuantity: { type: Number },
            variance: { type: Number },
            notes: { type: String },
            countedBy: { type: Types.ObjectId, ref: 'AdminUser' },
            countedAt: { type: Date },
        }],
        default: [],
    })
    items: {
        productId: Types.ObjectId;
        locationId?: Types.ObjectId;
        expectedQuantity: number;
        countedQuantity?: number;
        variance?: number;
        notes?: string;
        countedBy?: Types.ObjectId;
        countedAt?: Date;
    }[];

    // ═════════════════════════════════════
    // Statistics
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalItems: number;

    @Prop({ type: Number, default: 0 })
    countedItems: number;

    @Prop({ type: Number, default: 0 })
    varianceItems: number;

    @Prop({ type: Number, default: 0 })
    totalVarianceValue: number;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    @Prop({ type: Date })
    completedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const InventoryCountSchema = SchemaFactory.createForClass(InventoryCount);

InventoryCountSchema.index({ countNumber: 1 });
InventoryCountSchema.index({ warehouseId: 1 });
InventoryCountSchema.index({ status: 1 });
InventoryCountSchema.index({ countType: 1 });
InventoryCountSchema.index({ createdAt: -1 });
