import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CannedResponseDocument = CannedResponse & Document;

@Schema({ timestamps: true })
export class CannedResponse {
    @Prop({ required: true, trim: true })
    title: string;

    @Prop({ required: true, unique: true, lowercase: true })
    shortcut: string; // e.g., "/greeting", "/shipping-info"

    @Prop({ required: true })
    contentAr: string;

    @Prop({ required: true })
    contentEn: string;

    @Prop()
    htmlContentAr?: string;

    @Prop()
    htmlContentEn?: string;

    // Categorization
    @Prop({ type: Types.ObjectId, ref: 'TicketCategory' })
    category?: Types.ObjectId;

    @Prop({ type: [String], default: [] })
    tags: string[];

    // Usage
    @Prop({ default: 0 })
    usageCount: number;

    @Prop()
    lastUsedAt?: Date;

    // Ownership
    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy: Types.ObjectId;

    @Prop({ default: false })
    isPersonal: boolean; // Only visible to creator

    @Prop({ default: true })
    isActive: boolean;

    // Variables support
    @Prop({ type: [String], default: [] })
    variables: string[]; // e.g., ['customerName', 'orderNumber']
}

export const CannedResponseSchema = SchemaFactory.createForClass(CannedResponse);

// Indexes
CannedResponseSchema.index({ shortcut: 1 }, { unique: true });
CannedResponseSchema.index({ category: 1, isActive: 1 });
CannedResponseSchema.index({ createdBy: 1, isPersonal: 1 });
CannedResponseSchema.index({ tags: 1 });
