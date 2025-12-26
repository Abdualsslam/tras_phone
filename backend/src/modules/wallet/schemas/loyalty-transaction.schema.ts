import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type LoyaltyTransactionDocument = LoyaltyTransaction & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ⭐ Loyalty Transaction Schema (Points Movement)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'loyalty_transactions',
})
export class LoyaltyTransaction {
    @Prop({ required: true, unique: true })
    transactionNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({
        required: true,
        type: String,
        enum: [
            'order_earn',       // كسب من طلب
            'order_redeem',     // استخدام في طلب
            'order_cancel',     // إلغاء نقاط طلب
            'signup_bonus',     // مكافأة التسجيل
            'referral_earn',    // كسب من إحالة
            'birthday_bonus',   // مكافأة عيد الميلاد
            'tier_upgrade',     // مكافأة ترقية المستوى
            'admin_grant',      // إضافة من الإدارة
            'admin_deduct',     // خصم من الإدارة
            'points_expiry',    // انتهاء صلاحية النقاط
            'transfer_out',     // تحويل لعميل آخر
            'transfer_in',      // استلام تحويل
        ],
    })
    transactionType: string;

    @Prop({ type: Number, required: true })
    points: number;

    @Prop({
        type: String,
        enum: ['earn', 'redeem', 'expire', 'adjust'],
        required: true,
    })
    direction: string;

    @Prop({ type: Number, required: true })
    pointsBefore: number;

    @Prop({ type: Number, required: true })
    pointsAfter: number;

    // ═════════════════════════════════════
    // Reference
    // ═════════════════════════════════════
    @Prop()
    referenceType?: string;

    @Prop({ type: Types.ObjectId })
    referenceId?: Types.ObjectId;

    @Prop()
    referenceNumber?: string;

    // ═════════════════════════════════════
    // Earning Details
    // ═════════════════════════════════════
    @Prop({ type: Number })
    orderAmount?: number;

    @Prop({ type: Number })
    pointsRate?: number; // e.g., 1 point per 10 SAR

    @Prop({ type: Number })
    multiplier?: number; // Tier multiplier applied

    // ═════════════════════════════════════
    // Redemption Details
    // ═════════════════════════════════════
    @Prop({ type: Number })
    redeemedValue?: number; // SAR value of redeemed points

    // ═════════════════════════════════════
    // Expiry
    // ═════════════════════════════════════
    @Prop({ type: Date })
    expiresAt?: Date;

    @Prop({ default: false })
    isExpired: boolean;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    createdAt: Date;
}

export const LoyaltyTransactionSchema = SchemaFactory.createForClass(LoyaltyTransaction);

LoyaltyTransactionSchema.index({ transactionNumber: 1 });
LoyaltyTransactionSchema.index({ customerId: 1, createdAt: -1 });
LoyaltyTransactionSchema.index({ transactionType: 1 });
LoyaltyTransactionSchema.index({ expiresAt: 1, isExpired: 1 });
