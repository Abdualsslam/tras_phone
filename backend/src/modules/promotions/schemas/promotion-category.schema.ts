import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionCategoryDocument = PromotionCategory & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔗 Promotion-Category Mapping
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'promotion_categories',
})
export class PromotionCategory {
    @Prop({ type: Types.ObjectId, ref: 'Promotion', required: true, index: true })
    promotionId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Category', required: true, index: true })
    categoryId: Types.ObjectId;

    @Prop({ default: false })
    includeSubcategories: boolean;

    createdAt: Date;
}

export const PromotionCategorySchema = SchemaFactory.createForClass(PromotionCategory);

PromotionCategorySchema.index({ promotionId: 1, categoryId: 1 }, { unique: true });
