import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SearchLogDocument = SearchLog & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Search Log Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'search_logs',
})
export class SearchLog {
  @Prop({ required: true, index: true })
  query: string;

  @Prop({ type: Types.ObjectId, ref: 'Customer' })
  customerId?: Types.ObjectId;

  @Prop()
  sessionId?: string;

  @Prop({ type: Number, default: 0 })
  resultsCount: number;

  @Prop({ type: [Types.ObjectId], ref: 'Product' })
  clickedProducts?: Types.ObjectId[];

  @Prop({ type: Types.ObjectId, ref: 'Product' })
  purchasedProduct?: Types.ObjectId;

  // Filters Applied
  @Prop({ type: Object })
  filters?: {
    categoryId?: string;
    brandId?: string;
    minPrice?: number;
    maxPrice?: number;
  };

  // Device Info
  @Prop()
  deviceType?: string;

  @Prop()
  userAgent?: string;

  @Prop()
  ipAddress?: string;

  createdAt: Date;
}

export const SearchLogSchema = SchemaFactory.createForClass(SearchLog);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'query' index is automatically created by index: true
SearchLogSchema.index({ customerId: 1 });
SearchLogSchema.index({ createdAt: -1 });
SearchLogSchema.index({ resultsCount: 1 });
