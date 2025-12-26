import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionUsageDocument = PromotionUsage & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Promotion Usage Tracking
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'promotion_usages',
})
export class PromotionUsage {
    @Prop({ type: Types.ObjectId, ref: 'Promotion', required: true, index: true })
    promotionId: Types.ObjectId;

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

export const PromotionUsageSchema = SchemaFactory.createForClass(PromotionUsage);

PromotionUsageSchema.index({ promotionId: 1, customerId: 1 });
PromotionUsageSchema.index({ orderId: 1 });
PromotionUsageSchema.index({ createdAt: -1 });
