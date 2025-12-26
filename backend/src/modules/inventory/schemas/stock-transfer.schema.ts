import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type StockTransferDocument = StockTransfer & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔄 Stock Transfer Schema (Between Warehouses)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'stock_transfers',
})
export class StockTransfer {
    @Prop({ required: true, unique: true })
    transferNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    fromWarehouseId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    toWarehouseId: Types.ObjectId;

    @Prop({
        type: String,
        enum: ['draft', 'pending', 'in_transit', 'received', 'completed', 'cancelled'],
        default: 'draft',
    })
    status: string;

    @Prop()
    notes?: string;

    // ═════════════════════════════════════
    // Items (embedded for simplicity)
    // ═════════════════════════════════════
    @Prop({
        type: [{
            productId: { type: Types.ObjectId, ref: 'Product', required: true },
            requestedQuantity: { type: Number, required: true },
            sentQuantity: { type: Number },
            receivedQuantity: { type: Number },
            notes: { type: String },
        }],
        default: [],
    })
    items: {
        productId: Types.ObjectId;
        requestedQuantity: number;
        sentQuantity?: number;
        receivedQuantity?: number;
        notes?: string;
    }[];

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    requestedBy?: Types.ObjectId;

    @Prop({ type: Date })
    requestedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    sentBy?: Types.ObjectId;

    @Prop({ type: Date })
    sentAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    receivedBy?: Types.ObjectId;

    @Prop({ type: Date })
    receivedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const StockTransferSchema = SchemaFactory.createForClass(StockTransfer);

StockTransferSchema.index({ transferNumber: 1 });
StockTransferSchema.index({ fromWarehouseId: 1 });
StockTransferSchema.index({ toWarehouseId: 1 });
StockTransferSchema.index({ status: 1 });
StockTransferSchema.index({ createdAt: -1 });
