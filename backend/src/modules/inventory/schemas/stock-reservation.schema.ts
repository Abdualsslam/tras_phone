import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type StockReservationDocument = StockReservation & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔒 Stock Reservation Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'stock_reservations',
})
export class StockReservation {
    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    warehouseId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Number, required: true })
    quantity: number;

    // ═════════════════════════════════════
    // Reference
    // ═════════════════════════════════════
    @Prop({ required: true })
    reservationType: string; // 'order', 'cart', 'transfer'

    @Prop({ type: Types.ObjectId, required: true })
    referenceId: Types.ObjectId;

    @Prop()
    referenceNumber?: string;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['pending', 'confirmed', 'fulfilled', 'cancelled', 'expired'],
        default: 'pending',
    })
    status: string;

    @Prop({ type: Date })
    expiresAt?: Date; // Auto-expire after X minutes for cart reservations

    @Prop({ type: Date })
    fulfilledAt?: Date;

    @Prop({ type: Date })
    cancelledAt?: Date;

    @Prop()
    cancellationReason?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const StockReservationSchema = SchemaFactory.createForClass(StockReservation);

StockReservationSchema.index({ warehouseId: 1, productId: 1, status: 1 });
StockReservationSchema.index({ referenceType: 1, referenceId: 1 });
StockReservationSchema.index({ status: 1, expiresAt: 1 });
