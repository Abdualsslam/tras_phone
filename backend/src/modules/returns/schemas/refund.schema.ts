import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type RefundDocument = Refund & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Refund Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'refunds',
})
export class Refund {
    @Prop({ required: true, unique: true })
    refundNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'ReturnRequest', required: true, index: true })
    returnRequestId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Payment' })
    originalPaymentId?: Types.ObjectId;

    @Prop({ type: Number, required: true })
    amount: number;

    @Prop({ type: Number, default: 0 })
    amountToCreditSettlement: number;

    @Prop({ type: Number, default: 0 })
    amountToWallet: number;

    @Prop({
        required: true,
        type: String,
        enum: ['original_payment', 'wallet', 'bank_transfer', 'store_credit'],
    })
    refundMethod: string;

    @Prop({
        type: String,
        enum: ['pending', 'processing', 'completed', 'failed'],
        default: 'pending',
    })
    status: string;

    // ═════════════════════════════════════
    // Bank Details (if bank_transfer)
    // ═════════════════════════════════════
    @Prop()
    bankName?: string;

    @Prop()
    accountNumber?: string;

    @Prop()
    iban?: string;

    @Prop()
    accountHolderName?: string;

    // ═════════════════════════════════════
    // Transaction
    // ═════════════════════════════════════
    @Prop()
    transactionId?: string;

    @Prop()
    gatewayResponse?: string;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    processedBy?: Types.ObjectId;

    @Prop({ type: Date })
    processedAt?: Date;

    @Prop({ type: Date })
    completedAt?: Date;

    @Prop()
    failureReason?: string;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const RefundSchema = SchemaFactory.createForClass(Refund);

RefundSchema.index({ refundNumber: 1 });
RefundSchema.index({ returnRequestId: 1 });
RefundSchema.index({ orderId: 1 });
RefundSchema.index({ customerId: 1 });
RefundSchema.index({ status: 1 });
RefundSchema.index({ createdAt: -1 });
