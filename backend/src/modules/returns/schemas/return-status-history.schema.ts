import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReturnStatusHistoryDocument = ReturnStatusHistory & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Return Status History Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'return_status_history',
})
export class ReturnStatusHistory {
    @Prop({ type: Types.ObjectId, ref: 'ReturnRequest', required: true, index: true })
    returnRequestId: Types.ObjectId;

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

export const ReturnStatusHistorySchema = SchemaFactory.createForClass(ReturnStatusHistory);

ReturnStatusHistorySchema.index({ returnRequestId: 1, createdAt: 1 });
