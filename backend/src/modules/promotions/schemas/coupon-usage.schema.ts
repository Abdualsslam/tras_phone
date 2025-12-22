import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CouponUsageDocument = CouponUsage & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Coupon Usage Tracking
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'coupon_usages',
})
export class CouponUsage {
    @Prop({ type: Types.ObjectId, ref: 'Coupon', required: true, index: true })
    couponId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Order', required: true })
    orderId: Types.ObjectId;

    @Prop({ type: Number, required: true })
    discountAmount: number;

    @Prop({ type: Number, required: true })
    orderAmount: number;

    createdAt: Date;
}

export const CouponUsageSchema = SchemaFactory.createForClass(CouponUsage);

CouponUsageSchema.index({ couponId: 1, customerId: 1 });
CouponUsageSchema.index({ orderId: 1 });
