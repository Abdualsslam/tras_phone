import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SupportAuditDocument = SupportAudit & Document;

export enum AuditAction {
    TICKET_CREATED = 'ticket_created',
    TICKET_UPDATED = 'ticket_updated',
    TICKET_STATUS_CHANGED = 'ticket_status_changed',
    TICKET_ASSIGNED = 'ticket_assigned',
    TICKET_ESCALATED = 'ticket_escalated',
    TICKET_MERGED = 'ticket_merged',
    TICKET_MESSAGE_ADDED = 'ticket_message_added',
    TICKET_RATED = 'ticket_rated',
    CHAT_SESSION_CREATED = 'chat_session_created',
    CHAT_SESSION_ACCEPTED = 'chat_session_accepted',
    CHAT_SESSION_TRANSFERRED = 'chat_session_transferred',
    CHAT_SESSION_ENDED = 'chat_session_ended',
    CHAT_MESSAGE_SENT = 'chat_message_sent',
    CATEGORY_CREATED = 'category_created',
    CATEGORY_UPDATED = 'category_updated',
    CANNED_RESPONSE_CREATED = 'canned_response_created',
    CANNED_RESPONSE_UPDATED = 'canned_response_updated',
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Support Audit Log Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({ timestamps: true })
export class SupportAudit {
    @Prop({
        type: String,
        enum: Object.values(AuditAction),
        required: true,
        index: true,
    })
    action: AuditAction;

    @Prop({ required: true, index: true })
    entityType: string; // 'ticket', 'chat_session', 'category', 'canned_response'

    @Prop({ type: Types.ObjectId, required: true, index: true })
    entityId: Types.ObjectId;

    @Prop()
    entityName?: string; // Ticket number, session ID, etc.

    // Actor (who performed the action)
    @Prop({ type: Types.ObjectId, refPath: 'actorModel' })
    actorId?: Types.ObjectId;

    @Prop({ type: String, enum: ['Customer', 'Admin', 'System'] })
    actorModel?: string;

    @Prop()
    actorName?: string;

    // Changes
    @Prop({ type: Object })
    oldValues?: Record<string, any>;

    @Prop({ type: Object })
    newValues?: Record<string, any>;

    // Additional context
    @Prop({ type: Object })
    metadata?: Record<string, any>;

    // IP and User Agent
    @Prop()
    ipAddress?: string;

    @Prop()
    userAgent?: string;
}

export const SupportAuditSchema = SchemaFactory.createForClass(SupportAudit);

// Indexes
SupportAuditSchema.index({ entityType: 1, entityId: 1, createdAt: -1 });
SupportAuditSchema.index({ actorId: 1, createdAt: -1 });
SupportAuditSchema.index({ action: 1, createdAt: -1 });
