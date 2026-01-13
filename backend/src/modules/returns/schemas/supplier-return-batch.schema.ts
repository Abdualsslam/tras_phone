import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SupplierReturnBatchDocument = SupplierReturnBatch & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Supplier Return Batch Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'supplier_return_batches',
})
export class SupplierReturnBatch {
  @Prop({ required: true, unique: true })
  batchNumber: string;

  @Prop({ type: Types.ObjectId, ref: 'Supplier', required: true, index: true })
  supplierId: Types.ObjectId;

  @Prop({
    type: String,
    enum: [
      'draft',
      'pending_approval',
      'approved',
      'sent_to_supplier',
      'acknowledged',
      'partial_credit',
      'credited',
      'rejected',
      'closed',
    ],
    default: 'draft',
    index: true,
  })
  status: string;

  // ═════════════════════════════════════
  // Items
  // ═════════════════════════════════════
  @Prop({
    type: [
      {
        returnItemId: { type: Types.ObjectId, ref: 'ReturnItem' },
        productId: { type: Types.ObjectId, ref: 'Product', required: true },
        quantity: { type: Number, required: true },
        unitCost: { type: Number, required: true },
        totalCost: { type: Number, required: true },
        notes: { type: String },
      },
    ],
    default: [],
  })
  items: {
    returnItemId?: Types.ObjectId;
    productId: Types.ObjectId;
    quantity: number;
    unitCost: number;
    totalCost: number;
    notes?: string;
    // Supplier response
    quantityAccepted?: number;
    quantityRejected?: number;
    rejectionReason?: string;
    creditAmount?: number;
  }[];

  // ═════════════════════════════════════
  // Amounts
  // ═════════════════════════════════════
  @Prop({ type: Number, default: 0 })
  totalItems: number;

  @Prop({ type: Number, default: 0 })
  totalQuantity: number;

  @Prop({ type: Number, default: 0 })
  expectedCreditAmount: number;

  @Prop({ type: Number, default: 0 })
  actualCreditAmount: number;

  // ═════════════════════════════════════
  // Dates
  // ═════════════════════════════════════
  @Prop({ type: Date })
  sentDate?: Date;

  @Prop({ type: Date })
  acknowledgedDate?: Date;

  @Prop({ type: Date })
  creditDate?: Date;

  // ═════════════════════════════════════
  // References
  // ═════════════════════════════════════
  @Prop()
  supplierReference?: string;

  @Prop()
  creditNoteNumber?: string;

  // ═════════════════════════════════════
  // Notes
  // ═════════════════════════════════════
  @Prop()
  notes?: string;

  @Prop()
  supplierNotes?: string;

  // ═════════════════════════════════════
  // Workflow
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  createdBy?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  approvedBy?: Types.ObjectId;

  @Prop({ type: Date })
  approvedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const SupplierReturnBatchSchema =
  SchemaFactory.createForClass(SupplierReturnBatch);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
SupplierReturnBatchSchema.index({ batchNumber: 1 });
SupplierReturnBatchSchema.index({ supplierId: 1 });
SupplierReturnBatchSchema.index({ status: 1 });
SupplierReturnBatchSchema.index({ createdAt: -1 });
