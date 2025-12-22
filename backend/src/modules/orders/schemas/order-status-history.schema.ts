import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderStatusHistoryDocument = OrderStatusHistory & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Order Status History Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'order_status_history',
})
export class OrderStatusHistory {
    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ required: true })
    fromStatus: string;

    @Prop({ required: true })
    toStatus: string;

    @Prop()
    notes?: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    changedBy?: Types.ObjectId;

    @Prop()
    changedByName?: string;

    @Prop({ default: false })
    isSystemGenerated: boolean;

    createdAt: Date;
}

export const OrderStatusHistorySchema = SchemaFactory.createForClass(OrderStatusHistory);

OrderStatusHistorySchema.index({ orderId: 1, createdAt: 1 });
