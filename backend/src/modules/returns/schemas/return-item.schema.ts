import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReturnItemDocument = ReturnItem & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Return Item Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'return_items',
})
export class ReturnItem {
  @Prop({
    type: Types.ObjectId,
    ref: 'ReturnRequest',
    required: true,
    index: true,
  })
  returnRequestId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'OrderItem', required: true })
  orderItemId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  // ═════════════════════════════════════
  // Product Snapshot
  // ═════════════════════════════════════
  @Prop({ required: true })
  productSku: string;

  @Prop({ required: true })
  productName: string;

  @Prop()
  productImage?: string;

  // ═════════════════════════════════════
  // Quantity
  // ═════════════════════════════════════
  @Prop({ type: Number, required: true })
  quantity: number;

  @Prop({ type: Number, required: true })
  unitPrice: number;

  @Prop({ type: Number, required: true })
  totalValue: number;

  // ═════════════════════════════════════
  // Inspection
  // ═════════════════════════════════════
  @Prop({
    type: String,
    enum: ['pending', 'inspected', 'approved', 'rejected'],
    default: 'pending',
  })
  inspectionStatus: string;

  @Prop({
    type: String,
    enum: ['good', 'damaged', 'used', 'missing_parts', 'not_original'],
  })
  condition?: string;

  @Prop({ type: Number, default: 0 })
  approvedQuantity: number;

  @Prop({ type: Number, default: 0 })
  rejectedQuantity: number;

  @Prop()
  inspectionNotes?: string;

  @Prop({ type: [String] })
  inspectionImages?: string[];

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  inspectedBy?: Types.ObjectId;

  @Prop({ type: Date })
  inspectedAt?: Date;

  // ═════════════════════════════════════
  // Restock
  // ═════════════════════════════════════
  @Prop({ default: false })
  isRestocked: boolean;

  @Prop({ type: Types.ObjectId, ref: 'Warehouse' })
  restockedToWarehouse?: Types.ObjectId;

  @Prop({ type: Date })
  restockedAt?: Date;

  // ═════════════════════════════════════
  // Supplier Return
  // ═════════════════════════════════════
  @Prop({ default: false })
  linkedToSupplierBatch: boolean;

  @Prop({ type: Types.ObjectId, ref: 'SupplierReturnBatch' })
  supplierReturnBatchId?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const ReturnItemSchema = SchemaFactory.createForClass(ReturnItem);

ReturnItemSchema.index({ returnRequestId: 1 });
ReturnItemSchema.index({ productId: 1 });
ReturnItemSchema.index({ inspectionStatus: 1 });
