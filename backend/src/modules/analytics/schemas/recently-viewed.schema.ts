import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type RecentlyViewedDocument = RecentlyViewed & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 👁️ Recently Viewed Products Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'recently_viewed_products',
})
export class RecentlyViewed {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  @Prop({ type: Number, default: 1 })
  viewCount: number;

  @Prop({ type: Date, default: Date.now })
  lastViewedAt: Date;

  createdAt: Date;
}

export const RecentlyViewedSchema =
  SchemaFactory.createForClass(RecentlyViewed);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
RecentlyViewedSchema.index({ customerId: 1, productId: 1 }, { unique: true });
RecentlyViewedSchema.index({ customerId: 1, lastViewedAt: -1 });
