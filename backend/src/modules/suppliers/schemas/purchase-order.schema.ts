import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PurchaseOrderDocument = PurchaseOrder & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Purchase Order Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'purchase_orders',
})
export class PurchaseOrder {
    @Prop({ required: true, unique: true })
    orderNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Supplier', required: true, index: true })
    supplierId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true })
    warehouseId: Types.ObjectId;

    @Prop({
        type: String,
        enum: ['draft', 'pending', 'approved', 'ordered', 'partial_received', 'received', 'cancelled'],
        default: 'draft',
    })
    status: string;

    // ═════════════════════════════════════
    // Dates
    // ═════════════════════════════════════
    @Prop({ type: Date })
    orderDate?: Date;

    @Prop({ type: Date })
    expectedDeliveryDate?: Date;

    @Prop({ type: Date })
    actualDeliveryDate?: Date;

    // ═════════════════════════════════════
    // Amounts
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    subtotal: number;

    @Prop({ type: Number, default: 0 })
    taxAmount: number;

    @Prop({ type: Number, default: 0 })
    shippingCost: number;

    @Prop({ type: Number, default: 0 })
    discount: number;

    @Prop({ type: Number, default: 0 })
    total: number;

    @Prop({ type: Number, default: 0 })
    paidAmount: number;

    // ═════════════════════════════════════
    // Payment
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['unpaid', 'partial', 'paid'],
        default: 'unpaid',
    })
    paymentStatus: string;

    @Prop({ type: Date })
    paymentDueDate?: Date;

    // ═════════════════════════════════════
    // References
    // ═════════════════════════════════════
    @Prop()
    supplierInvoiceNumber?: string;

    @Prop()
    supplierQuoteNumber?: string;

    @Prop()
    notes?: string;

    @Prop()
    internalNotes?: string;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    receivedBy?: Types.ObjectId;

    @Prop({ type: Date })
    receivedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const PurchaseOrderSchema = SchemaFactory.createForClass(PurchaseOrder);

PurchaseOrderSchema.index({ orderNumber: 1 });
PurchaseOrderSchema.index({ supplierId: 1 });
PurchaseOrderSchema.index({ status: 1 });
PurchaseOrderSchema.index({ paymentStatus: 1 });
PurchaseOrderSchema.index({ createdAt: -1 });

// Virtual for remaining amount
PurchaseOrderSchema.virtual('remainingAmount').get(function () {
    return this.total - this.paidAmount;
});
