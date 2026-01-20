import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ChatBotRuleDocument = ChatBotRule & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🤖 Chat Bot Rule Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({ timestamps: true })
export class ChatBotRule {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop()
    descriptionAr?: string;

    @Prop()
    descriptionEn?: string;

    // Trigger patterns (regex or keywords)
    @Prop({ type: [String], required: true })
    triggerPatterns: string[];

    // Response
    @Prop({ required: true })
    responseAr: string;

    @Prop({ required: true })
    responseEn: string;

    // Category
    @Prop({ type: Types.ObjectId, ref: 'TicketCategory' })
    category?: Types.ObjectId;

    // Priority
    @Prop({ default: 0 })
    priority: number; // Higher priority rules are checked first

    // Quick replies
    @Prop({
        type: [{
            labelAr: String,
            labelEn: String,
            value: String,
            action: String, // 'reply', 'transfer', 'create_ticket'
        }],
        default: [],
    })
    quickReplies: Array<{
        labelAr: string;
        labelEn: string;
        value: string;
        action: string;
    }>;

    // Settings
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    usageCount: number;

    @Prop()
    lastUsedAt?: Date;

    // Metadata
    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;
}

export const ChatBotRuleSchema = SchemaFactory.createForClass(ChatBotRule);

// Indexes
ChatBotRuleSchema.index({ isActive: 1, priority: -1 });
ChatBotRuleSchema.index({ category: 1 });
