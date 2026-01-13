import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type StockAlertDocument = StockAlert & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔔 Stock Alert Schema (Customer Alerts)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'stock_alerts',
})
export class StockAlert {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  // Alert Type
  @Prop({
    type: String,
    enum: ['back_in_stock', 'low_stock', 'price_drop'],
    required: true,
    index: true,
  })
  alertType: 'back_in_stock' | 'low_stock' | 'price_drop';

  // For price drop
  @Prop({ type: Number })
  targetPrice?: number;

  @Prop({ type: Number })
  originalPrice?: number;

  // Status
  @Prop({ default: true })
  isActive: boolean;

  @Prop({ type: Date })
  notifiedAt?: Date;

  createdAt: Date;
}

export const StockAlertSchema = SchemaFactory.createForClass(StockAlert);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
StockAlertSchema.index(
  { customerId: 1, productId: 1, alertType: 1 },
  { unique: true },
);
StockAlertSchema.index({ productId: 1, isActive: 1 });
StockAlertSchema.index({ customerId: 1 });
