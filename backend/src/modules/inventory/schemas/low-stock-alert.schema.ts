import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type LowStockAlertDocument = LowStockAlert & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ⚠️ Low Stock Alert Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'low_stock_alerts',
})
export class LowStockAlert {
    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', index: true })
    warehouseId?: Types.ObjectId;

    @Prop({ type: Number, required: true })
    currentQuantity: number;

    @Prop({ type: Number, required: true })
    threshold: number;

    @Prop({
        type: String,
        enum: ['low', 'critical', 'out_of_stock'],
        default: 'low',
    })
    alertLevel: string;

    @Prop({
        type: String,
        enum: ['pending', 'acknowledged', 'resolved', 'dismissed'],
        default: 'pending',
    })
    status: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    acknowledgedBy?: Types.ObjectId;

    @Prop({ type: Date })
    acknowledgedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    resolvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    resolvedAt?: Date;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const LowStockAlertSchema = SchemaFactory.createForClass(LowStockAlert);

LowStockAlertSchema.index({ productId: 1, warehouseId: 1, status: 1 });
LowStockAlertSchema.index({ alertLevel: 1 });
LowStockAlertSchema.index({ status: 1 });
LowStockAlertSchema.index({ createdAt: -1 });
