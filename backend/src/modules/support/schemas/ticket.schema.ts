import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TicketDocument = Ticket & Document;

export enum TicketStatus {
    OPEN = 'open',
    AWAITING_RESPONSE = 'awaiting_response',
    IN_PROGRESS = 'in_progress',
    ON_HOLD = 'on_hold',
    ESCALATED = 'escalated',
    RESOLVED = 'resolved',
    CLOSED = 'closed',
    REOPENED = 'reopened',
}

export enum TicketPriority {
    LOW = 'low',
    MEDIUM = 'medium',
    HIGH = 'high',
    URGENT = 'urgent',
}

export enum TicketSource {
    WEB = 'web',
    MOBILE_APP = 'mobile_app',
    EMAIL = 'email',
    PHONE = 'phone',
    LIVE_CHAT = 'live_chat',
    SOCIAL_MEDIA = 'social_media',
}

@Schema({ _id: false })
export class TicketCustomerInfo {
    @Prop({ type: Types.ObjectId, ref: 'Customer' })
    customerId?: Types.ObjectId;

    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    email: string;

    @Prop()
    phone?: string;
}

@Schema({ _id: false })
export class TicketSLA {
    @Prop()
    firstResponseDue?: Date;

    @Prop()
    resolutionDue?: Date;

    @Prop()
    firstRespondedAt?: Date;

    @Prop()
    resolvedAt?: Date;

    @Prop({ default: false })
    firstResponseBreached: boolean;

    @Prop({ default: false })
    resolutionBreached: boolean;
}

@Schema({ _id: false })
export class TicketResolution {
    @Prop({ type: String })
    summary?: string;

    @Prop({
        type: String,
        enum: ['solved', 'wont_fix', 'duplicate', 'invalid', 'customer_abandoned']
    })
    type?: string;

    @Prop({ type: Types.ObjectId, ref: 'Ticket' })
    duplicateOf?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    resolvedBy?: Types.ObjectId;

    @Prop()
    resolvedAt?: Date;
}

@Schema({ timestamps: true })
export class Ticket {
    @Prop({ required: true, unique: true })
    ticketNumber: string; // TKT-2024-000001

    @Prop({ type: TicketCustomerInfo, required: true })
    customer: TicketCustomerInfo;

    @Prop({ type: Types.ObjectId, ref: 'TicketCategory', required: true })
    category: Types.ObjectId;

    @Prop({ required: true, trim: true })
    subject: string;

    @Prop({ required: true })
    description: string;

    @Prop({
        type: String,
        enum: Object.values(TicketStatus),
        default: TicketStatus.OPEN
    })
    status: TicketStatus;

    @Prop({
        type: String,
        enum: Object.values(TicketPriority),
        default: TicketPriority.MEDIUM
    })
    priority: TicketPriority;

    @Prop({
        type: String,
        enum: Object.values(TicketSource),
        default: TicketSource.WEB
    })
    source: TicketSource;

    // Assignment
    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    assignedTo?: Types.ObjectId;

    @Prop()
    assignedAt?: Date;

    // Related entities
    @Prop({ type: Types.ObjectId, ref: 'Order' })
    orderId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product' })
    productId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'ReturnRequest' })
    returnRequestId?: Types.ObjectId;

    // Attachments
    @Prop({ type: [String], default: [] })
    attachments: string[];

    // Tags & Labels
    @Prop({ type: [String], default: [] })
    tags: string[];

    // SLA Tracking
    @Prop({ type: TicketSLA, default: {} })
    sla: TicketSLA;

    // Resolution
    @Prop({ type: TicketResolution })
    resolution?: TicketResolution;

    // Escalation
    @Prop({ default: 0 })
    escalationLevel: number;

    @Prop()
    escalatedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    escalatedBy?: Types.ObjectId;

    @Prop()
    escalationReason?: string;

    // Counters
    @Prop({ default: 0 })
    messageCount: number;

    @Prop({ default: 0 })
    internalNoteCount: number;

    // Activity tracking
    @Prop()
    lastCustomerReplyAt?: Date;

    @Prop()
    lastAgentReplyAt?: Date;

    // Satisfaction
    @Prop({ type: Number, min: 1, max: 5 })
    satisfactionRating?: number;

    @Prop()
    satisfactionFeedback?: string;

    @Prop()
    satisfactionRatedAt?: Date;

    // Merging
    @Prop({ type: Types.ObjectId, ref: 'Ticket' })
    mergedInto?: Types.ObjectId;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Ticket' }] })
    mergedTickets?: Types.ObjectId[];

    // Metadata
    @Prop({ type: Object })
    metadata?: Record<string, any>;
}

export const TicketSchema = SchemaFactory.createForClass(Ticket);

// Indexes
TicketSchema.index({ ticketNumber: 1 }, { unique: true });
TicketSchema.index({ 'customer.customerId': 1 });
TicketSchema.index({ 'customer.email': 1 });
TicketSchema.index({ status: 1, priority: 1 });
TicketSchema.index({ assignedTo: 1, status: 1 });
TicketSchema.index({ category: 1, status: 1 });
TicketSchema.index({ createdAt: -1 });
TicketSchema.index({ 'sla.firstResponseDue': 1, 'sla.firstResponseBreached': 1 });
TicketSchema.index({ 'sla.resolutionDue': 1, 'sla.resolutionBreached': 1 });
TicketSchema.index({ orderId: 1 });
TicketSchema.index({ tags: 1 });
