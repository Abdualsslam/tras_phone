import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderNoteDocument = OrderNote & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Order Note Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'order_notes',
})
export class OrderNote {
    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ required: true })
    content: string;

    @Prop({
        type: String,
        enum: ['internal', 'customer', 'system'],
        default: 'internal',
    })
    type: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    @Prop()
    createdByName?: string;

    @Prop({ default: false })
    isImportant: boolean;

    createdAt: Date;
}

export const OrderNoteSchema = SchemaFactory.createForClass(OrderNote);

OrderNoteSchema.index({ orderId: 1, createdAt: -1 });
