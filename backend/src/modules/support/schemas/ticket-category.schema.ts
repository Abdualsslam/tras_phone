import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TicketCategoryDocument = TicketCategory & Document;

@Schema({ timestamps: true })
export class TicketCategory {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ trim: true })
    descriptionAr?: string;

    @Prop({ trim: true })
    descriptionEn?: string;

    @Prop({ type: String })
    icon?: string;

    @Prop({ type: Types.ObjectId, ref: 'TicketCategory' })
    parent?: Types.ObjectId;

    @Prop({ default: 0 })
    sortOrder: number;

    // SLA Settings
    @Prop({ default: 24 })
    responseTimeHours: number; // Target response time

    @Prop({ default: 72 })
    resolutionTimeHours: number; // Target resolution time

    @Prop({
        type: String,
        enum: ['low', 'medium', 'high', 'urgent'],
        default: 'medium'
    })
    defaultPriority: string;

    // Auto-assignment
    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    defaultAssignee?: Types.ObjectId;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Admin' }] })
    assignmentPool?: Types.ObjectId[]; // Pool of agents for round-robin

    // Settings
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    requiresOrderId: boolean;

    @Prop({ default: false })
    requiresProductId: boolean;

    @Prop({ type: [String], default: [] })
    quickReplies: string[]; // Canned responses for this category

    // Statistics
    @Prop({ default: 0 })
    totalTickets: number;

    @Prop({ default: 0 })
    openTickets: number;

    @Prop({ default: 0 })
    avgResolutionTime: number; // in minutes
}

export const TicketCategorySchema = SchemaFactory.createForClass(TicketCategory);

// Indexes
TicketCategorySchema.index({ parent: 1 });
TicketCategorySchema.index({ isActive: 1, sortOrder: 1 });
