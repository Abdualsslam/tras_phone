import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionBrandDocument = PromotionBrand & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔗 Promotion-Brand Mapping
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'promotion_brands',
})
export class PromotionBrand {
    @Prop({ type: Types.ObjectId, ref: 'Promotion', required: true, index: true })
    promotionId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Brand', required: true, index: true })
    brandId: Types.ObjectId;

    createdAt: Date;
}

export const PromotionBrandSchema = SchemaFactory.createForClass(PromotionBrand);

PromotionBrandSchema.index({ promotionId: 1, brandId: 1 }, { unique: true });
