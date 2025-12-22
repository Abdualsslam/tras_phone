import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionProductDocument = PromotionProduct & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔗 Promotion-Product Mapping
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'promotion_products',
})
export class PromotionProduct {
    @Prop({ type: Types.ObjectId, ref: 'Promotion', required: true, index: true })
    promotionId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Number })
    customDiscountValue?: number; // Override promotion discount

    createdAt: Date;
}

export const PromotionProductSchema = SchemaFactory.createForClass(PromotionProduct);

PromotionProductSchema.index({ promotionId: 1, productId: 1 }, { unique: true });
