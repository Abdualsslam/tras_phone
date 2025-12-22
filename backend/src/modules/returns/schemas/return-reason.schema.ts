import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReturnReasonDocument = ReturnReason & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Return Reason Schema (Configurable reasons)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'return_reasons',
})
export class ReturnReason {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop()
    description?: string;

    @Prop({
        type: String,
        enum: ['defective', 'wrong_item', 'not_as_described', 'changed_mind', 'damaged', 'other'],
        required: true,
    })
    category: string;

    @Prop({ default: true })
    requiresPhoto: boolean;

    @Prop({ default: true })
    eligibleForRefund: boolean;

    @Prop({ default: true })
    eligibleForExchange: boolean;

    @Prop({ type: Number, default: 0 })
    displayOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const ReturnReasonSchema = SchemaFactory.createForClass(ReturnReason);

ReturnReasonSchema.index({ category: 1 });
ReturnReasonSchema.index({ isActive: 1, displayOrder: 1 });
