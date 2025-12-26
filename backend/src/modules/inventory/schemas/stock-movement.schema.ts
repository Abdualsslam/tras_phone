import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type StockMovementDocument = StockMovement & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Stock Movement Schema (12 Movement Types)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'stock_movements',
})
export class StockMovement {
    @Prop({ required: true, unique: true })
    movementNumber: string;

    @Prop({
        required: true,
        type: String,
        enum: [
            'purchase_in',      // استلام من مورد
            'purchase_return',  // مرتجع للمورد
            'sale_out',         // بيع للعميل
            'sale_return',      // مرتجع من العميل
            'transfer_in',      // استلام تحويل
            'transfer_out',     // إرسال تحويل
            'adjustment_in',    // تعديل بالزيادة
            'adjustment_out',   // تعديل بالنقص
            'damage',           // تالف
            'expired',          // منتهي الصلاحية
            'assembly_in',      // ناتج تجميع
            'assembly_out',     // مكون للتجميع
        ],
    })
    movementType: string;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    warehouseId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'StockLocation' })
    locationId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Quantity
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    quantity: number;

    @Prop({ type: Number, required: true })
    quantityBefore: number;

    @Prop({ type: Number, required: true })
    quantityAfter: number;

    // ═════════════════════════════════════
    // Cost
    // ═════════════════════════════════════
    @Prop({ type: Number })
    unitCost?: number;

    @Prop({ type: Number })
    totalCost?: number;

    // ═════════════════════════════════════
    // Reference
    // ═════════════════════════════════════
    @Prop()
    referenceType?: string; // 'order', 'purchase', 'transfer', 'count'

    @Prop({ type: Types.ObjectId })
    referenceId?: Types.ObjectId;

    @Prop()
    referenceNumber?: string;

    // ═════════════════════════════════════
    // Details
    // ═════════════════════════════════════
    @Prop()
    notes?: string;

    @Prop()
    reason?: string;

    @Prop({ type: [String] })
    serialNumbers?: string[];

    @Prop()
    batchNumber?: string;

    @Prop({ type: Date })
    expiryDate?: Date;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    createdAt: Date;
}

export const StockMovementSchema = SchemaFactory.createForClass(StockMovement);

StockMovementSchema.index({ movementNumber: 1 });
StockMovementSchema.index({ movementType: 1 });
StockMovementSchema.index({ warehouseId: 1, productId: 1 });
StockMovementSchema.index({ referenceType: 1, referenceId: 1 });
StockMovementSchema.index({ createdAt: -1 });
