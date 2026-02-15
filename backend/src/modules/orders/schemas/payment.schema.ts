import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PaymentDocument = Payment & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 💳 Payment Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'payments',
})
export class Payment {
    @Prop({ required: true, unique: true })
    paymentNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Invoice' })
    invoiceId?: Types.ObjectId;

    @Prop({ type: Number, required: true })
    amount: number;

    @Prop({
        required: true,
        type: String,
        enum: [
            'cash_on_delivery',
            'credit_card',
            'mada',
            'apple_pay',
            'stc_pay',
            'bank_transfer',
            'wallet',
            'credit',
        ],
    })
    paymentMethod: string;

    @Prop({
        type: String,
        enum: ['pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled'],
        default: 'pending',
    })
    status: string;

    // ═════════════════════════════════════
    // Gateway Info
    // ═════════════════════════════════════
    @Prop()
    gateway?: string; // HyperPay, Mada, etc.

    @Prop()
    transactionId?: string;

    @Prop()
    gatewayResponse?: string;

    @Prop()
    gatewayReference?: string;

    // ═════════════════════════════════════
    // Card Info (masked)
    // ═════════════════════════════════════
    @Prop()
    cardBrand?: string; // Visa, Mastercard, Mada

    @Prop()
    cardLast4?: string;

    // ═════════════════════════════════════
    // Dates
    // ═════════════════════════════════════
    @Prop({ type: Date })
    paidAt?: Date;

    @Prop({ type: Date })
    failedAt?: Date;

    @Prop()
    failureReason?: string;

    // ═════════════════════════════════════
    // Refund
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    refundedAmount: number;

    @Prop({ type: Date })
    refundedAt?: Date;

    @Prop()
    refundReason?: string;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const PaymentSchema = SchemaFactory.createForClass(Payment);

PaymentSchema.index({ paymentNumber: 1 });
PaymentSchema.index({ orderId: 1 });
PaymentSchema.index({ customerId: 1 });
PaymentSchema.index({ transactionId: 1 });
PaymentSchema.index({ status: 1 });
PaymentSchema.index({ createdAt: -1 });
