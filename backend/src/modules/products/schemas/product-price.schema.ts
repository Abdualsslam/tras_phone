import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductPriceDocument = ProductPrice & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Product Price Schema (Multi-level pricing)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'product_prices',
})
export class ProductPrice {
    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'PriceLevel', required: true, index: true })
    priceLevelId: Types.ObjectId;

    @Prop({ type: Number, required: true })
    price: number;

    @Prop({ type: Number })
    compareAtPrice?: number;

    @Prop({ type: Number })
    minQuantity?: number; // For quantity-based pricing

    @Prop({ type: Number })
    maxQuantity?: number;

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const ProductPriceSchema = SchemaFactory.createForClass(ProductPrice);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ProductPriceSchema.index({ productId: 1, priceLevelId: 1 }, { unique: true });
ProductPriceSchema.index({ productId: 1, isActive: 1 });
