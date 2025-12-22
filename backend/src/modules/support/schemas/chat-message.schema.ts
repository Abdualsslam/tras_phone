import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ChatMessageDocument = ChatMessage & Document;

export enum ChatMessageType {
    TEXT = 'text',
    IMAGE = 'image',
    FILE = 'file',
    SYSTEM = 'system',
    BOT = 'bot',
    QUICK_REPLY = 'quick_reply',
}

export enum ChatSenderType {
    VISITOR = 'visitor',
    AGENT = 'agent',
    SYSTEM = 'system',
    BOT = 'bot',
}

@Schema({ timestamps: true })
export class ChatMessage {
    @Prop({ type: Types.ObjectId, ref: 'ChatSession', required: true })
    session: Types.ObjectId;

    @Prop({
        type: String,
        enum: Object.values(ChatSenderType),
        required: true
    })
    senderType: ChatSenderType;

    @Prop({ type: Types.ObjectId, refPath: 'senderModel' })
    senderId?: Types.ObjectId;

    @Prop({ type: String, enum: ['Customer', 'Admin'] })
    senderModel?: string;

    @Prop()
    senderName?: string;

    @Prop({
        type: String,
        enum: Object.values(ChatMessageType),
        default: ChatMessageType.TEXT
    })
    messageType: ChatMessageType;

    @Prop({ required: true })
    content: string;

    // For files/images
    @Prop()
    fileUrl?: string;

    @Prop()
    fileName?: string;

    @Prop()
    fileSize?: number;

    @Prop()
    mimeType?: string;

    // Quick replies (bot)
    @Prop({
        type: [{
            label: String,
            value: String
        }]
    })
    quickReplies?: Array<{
        label: string;
        value: string;
    }>;

    // Delivery status
    @Prop({ default: false })
    isDelivered: boolean;

    @Prop()
    deliveredAt?: Date;

    @Prop({ default: false })
    isRead: boolean;

    @Prop()
    readAt?: Date;

    // Typing indicator (transient, not persisted usually)
    @Prop({ default: false })
    isTyping: boolean;

    // For internal notes (agent only)
    @Prop({ default: false })
    isInternal: boolean;

    // Metadata
    @Prop({ type: Object })
    metadata?: Record<string, any>;
}

export const ChatMessageSchema = SchemaFactory.createForClass(ChatMessage);

// Indexes
ChatMessageSchema.index({ session: 1, createdAt: 1 });
ChatMessageSchema.index({ session: 1, isInternal: 1 });
ChatMessageSchema.index({ senderId: 1, senderType: 1 });
