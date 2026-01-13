import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductTagDocument = ProductTag & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏷️ Product Tag Schema (Many-to-Many)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'product_tags',
})
export class ProductTag {
  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Tag', required: true, index: true })
  tagId: Types.ObjectId;

  createdAt: Date;
}

export const ProductTagSchema = SchemaFactory.createForClass(ProductTag);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ProductTagSchema.index({ productId: 1, tagId: 1 }, { unique: true });
ProductTagSchema.index({ productId: 1 });
ProductTagSchema.index({ tagId: 1 });
