import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SupplierPaymentDocument = SupplierPayment & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Supplier Payment Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'supplier_payments',
})
export class SupplierPayment {
    @Prop({ required: true, unique: true })
    paymentNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Supplier', required: true, index: true })
    supplierId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'PurchaseOrder', index: true })
    purchaseOrderId?: Types.ObjectId;

    @Prop({ type: Number, required: true })
    amount: number;

    @Prop({
        type: String,
        enum: ['cash', 'bank_transfer', 'cheque', 'credit'],
        required: true,
    })
    paymentMethod: string;

    @Prop({ type: Date, required: true })
    paymentDate: Date;

    // ═════════════════════════════════════
    // Bank/Cheque Details
    // ═════════════════════════════════════
    @Prop()
    bankName?: string;

    @Prop()
    transactionReference?: string;

    @Prop()
    chequeNumber?: string;

    @Prop({ type: Date })
    chequeDate?: Date;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['pending', 'completed', 'failed', 'cancelled'],
        default: 'completed',
    })
    status: string;

    @Prop()
    notes?: string;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const SupplierPaymentSchema = SchemaFactory.createForClass(SupplierPayment);

SupplierPaymentSchema.index({ paymentNumber: 1 });
SupplierPaymentSchema.index({ supplierId: 1 });
SupplierPaymentSchema.index({ purchaseOrderId: 1 });
SupplierPaymentSchema.index({ paymentDate: -1 });
SupplierPaymentSchema.index({ status: 1 });
