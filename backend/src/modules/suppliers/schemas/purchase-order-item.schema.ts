import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PurchaseOrderItemDocument = PurchaseOrderItem & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Purchase Order Item Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'purchase_order_items',
})
export class PurchaseOrderItem {
    @Prop({ type: Types.ObjectId, ref: 'PurchaseOrder', required: true, index: true })
    purchaseOrderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop()
    productSku?: string;

    @Prop()
    productName?: string;

    // ═════════════════════════════════════
    // Quantities
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    orderedQuantity: number;

    @Prop({ type: Number, default: 0 })
    receivedQuantity: number;

    @Prop({ type: Number, default: 0 })
    damagedQuantity: number;

    @Prop({ type: Number, default: 0 })
    returnedQuantity: number;

    // ═════════════════════════════════════
    // Price
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    unitPrice: number;

    @Prop({ type: Number, default: 0 })
    discount: number;

    @Prop({ type: Number })
    taxRate?: number;

    @Prop({ type: Number, default: 0 })
    taxAmount: number;

    @Prop({ type: Number, required: true })
    totalPrice: number;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['pending', 'partial', 'received', 'cancelled'],
        default: 'pending',
    })
    status: string;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const PurchaseOrderItemSchema = SchemaFactory.createForClass(PurchaseOrderItem);

PurchaseOrderItemSchema.index({ purchaseOrderId: 1 });
PurchaseOrderItemSchema.index({ productId: 1 });

// Virtual for pending quantity
PurchaseOrderItemSchema.virtual('pendingQuantity').get(function () {
    return this.orderedQuantity - this.receivedQuantity;
});
