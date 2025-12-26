import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WalletTransactionDocument = WalletTransaction & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Wallet Transaction Schema (9 Transaction Types)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'wallet_transactions',
})
export class WalletTransaction {
    @Prop({ required: true, unique: true })
    transactionNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({
        required: true,
        type: String,
        enum: [
            'order_payment',     // دفع طلب من المحفظة
            'order_refund',      // استرداد مبلغ طلب
            'wallet_topup',      // شحن المحفظة
            'wallet_withdrawal', // سحب من المحفظة
            'referral_reward',   // مكافأة إحالة
            'loyalty_reward',    // مكافأة ولاء
            'admin_credit',      // إضافة من الإدارة
            'admin_debit',       // خصم من الإدارة
            'expired_balance',   // رصيد منتهي
        ],
    })
    transactionType: string;

    @Prop({ type: Number, required: true })
    amount: number;

    @Prop({
        type: String,
        enum: ['credit', 'debit'],
        required: true,
    })
    direction: string; // credit = إضافة, debit = خصم

    @Prop({ type: Number, required: true })
    balanceBefore: number;

    @Prop({ type: Number, required: true })
    balanceAfter: number;

    // ═════════════════════════════════════
    // Reference
    // ═════════════════════════════════════
    @Prop()
    referenceType?: string; // 'order', 'refund', 'referral'

    @Prop({ type: Types.ObjectId })
    referenceId?: Types.ObjectId;

    @Prop()
    referenceNumber?: string;

    // ═════════════════════════════════════
    // Payment Details (for topup)
    // ═════════════════════════════════════
    @Prop()
    paymentMethod?: string;

    @Prop()
    paymentGateway?: string;

    @Prop()
    gatewayTransactionId?: string;

    // ═════════════════════════════════════
    // Expiry (for promotional credits)
    // ═════════════════════════════════════
    @Prop({ type: Date })
    expiresAt?: Date;

    @Prop({ default: false })
    isExpired: boolean;

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
    failureReason?: string;

    @Prop()
    notes?: string;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const WalletTransactionSchema = SchemaFactory.createForClass(WalletTransaction);

WalletTransactionSchema.index({ transactionNumber: 1 });
WalletTransactionSchema.index({ customerId: 1, createdAt: -1 });
WalletTransactionSchema.index({ transactionType: 1 });
WalletTransactionSchema.index({ referenceType: 1, referenceId: 1 });
WalletTransactionSchema.index({ expiresAt: 1, isExpired: 1 });
WalletTransactionSchema.index({ status: 1 });
