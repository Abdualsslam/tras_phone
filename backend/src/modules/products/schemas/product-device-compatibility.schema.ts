import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductDeviceCompatibilityDocument = ProductDeviceCompatibility &
  Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 Product Device Compatibility Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'product_device_compatibility',
})
export class ProductDeviceCompatibility {
  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Device', required: true, index: true })
  deviceId: Types.ObjectId;

  @Prop()
  compatibilityNotes?: string;

  @Prop({ default: false })
  isVerified: boolean;

  createdAt: Date;
}

export const ProductDeviceCompatibilitySchema = SchemaFactory.createForClass(
  ProductDeviceCompatibility,
);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ProductDeviceCompatibilitySchema.index(
  { productId: 1, deviceId: 1 },
  { unique: true },
);
ProductDeviceCompatibilitySchema.index({ deviceId: 1 });
ProductDeviceCompatibilitySchema.index({ productId: 1 });
