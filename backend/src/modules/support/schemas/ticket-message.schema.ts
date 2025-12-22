import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TicketMessageDocument = TicketMessage & Document;

export enum MessageSenderType {
    CUSTOMER = 'customer',
    AGENT = 'agent',
    SYSTEM = 'system',
}

export enum MessageType {
    TEXT = 'text',
    INTERNAL_NOTE = 'internal_note',
    STATUS_CHANGE = 'status_change',
    ASSIGNMENT = 'assignment',
    ESCALATION = 'escalation',
    CANNED_RESPONSE = 'canned_response',
}

@Schema({ timestamps: true })
export class TicketMessage {
    @Prop({ type: Types.ObjectId, ref: 'Ticket', required: true })
    ticket: Types.ObjectId;

    @Prop({
        type: String,
        enum: Object.values(MessageSenderType),
        required: true
    })
    senderType: MessageSenderType;

    @Prop({ type: Types.ObjectId, refPath: 'senderModel' })
    senderId?: Types.ObjectId;

    @Prop({ type: String, enum: ['Customer', 'Admin'] })
    senderModel?: string;

    @Prop()
    senderName: string;

    @Prop({
        type: String,
        enum: Object.values(MessageType),
        default: MessageType.TEXT
    })
    messageType: MessageType;

    @Prop({ required: true })
    content: string;

    @Prop({ type: String })
    htmlContent?: string; // Rich text version

    // Attachments
    @Prop({ type: [String], default: [] })
    attachments: string[];

    // For internal notes
    @Prop({ default: false })
    isInternal: boolean;

    // For canned responses
    @Prop({ type: Types.ObjectId, ref: 'CannedResponse' })
    cannedResponseId?: Types.ObjectId;

    // Email specific
    @Prop()
    emailMessageId?: string;

    @Prop({ type: [String] })
    emailCc?: string[];

    // Read status
    @Prop({ default: false })
    isRead: boolean;

    @Prop()
    readAt?: Date;

    // Edit tracking
    @Prop({ default: false })
    isEdited: boolean;

    @Prop()
    editedAt?: Date;

    @Prop()
    originalContent?: string;
}

export const TicketMessageSchema = SchemaFactory.createForClass(TicketMessage);

// Indexes
TicketMessageSchema.index({ ticket: 1, createdAt: 1 });
TicketMessageSchema.index({ ticket: 1, isInternal: 1 });
TicketMessageSchema.index({ senderId: 1, senderType: 1 });
