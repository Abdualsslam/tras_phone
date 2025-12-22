import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReferralDocument = Referral & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Referral Schema
 * ═══════════════════════════════════════════════════════════════
 * Referral program for customer acquisition
 */
@Schema({
    timestamps: true,
    collection: 'referrals',
})
export class Referral {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    referrerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    referredId: Types.ObjectId;

    @Prop({ required: true })
    referralCode: string;

    @Prop({
        type: String,
        enum: ['pending', 'completed', 'expired', 'cancelled'],
        default: 'pending',
    })
    status: string;

    // ═════════════════════════════════════
    // Rewards
    // ═════════════════════════════════════
    @Prop({ type: Number })
    referrerRewardAmount?: number;

    @Prop({ type: Number })
    referredRewardAmount?: number;

    @Prop({ type: Date })
    referrerRewardedAt?: Date;

    @Prop({ type: Date })
    referredRewardedAt?: Date;

    // ═════════════════════════════════════
    // Conditions
    // ═════════════════════════════════════
    @Prop({ type: Number })
    minOrderAmount?: number;

    @Prop({ type: Types.ObjectId, ref: 'Order' })
    qualifyingOrderId?: Types.ObjectId;

    @Prop({ type: Date })
    expiresAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const ReferralSchema = SchemaFactory.createForClass(Referral);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ReferralSchema.index({ referrerId: 1 });
ReferralSchema.index({ referredId: 1 });
ReferralSchema.index({ referralCode: 1 });
ReferralSchema.index({ status: 1 });
