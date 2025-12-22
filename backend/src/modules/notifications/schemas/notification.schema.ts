import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type NotificationDocument = Notification & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔔 Notification Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'notifications',
})
export class Notification {
    @Prop({ type: Types.ObjectId, ref: 'Customer', index: true })
    customerId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser', index: true })
    adminUserId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'NotificationTemplate' })
    templateId?: Types.ObjectId;

    @Prop()
    templateCode?: string;

    @Prop({
        required: true,
        type: String,
        enum: ['order', 'payment', 'promotion', 'system', 'account', 'support', 'marketing'],
    })
    category: string;

    // ═════════════════════════════════════
    // Content
    // ═════════════════════════════════════
    @Prop({ required: true })
    title: string;

    @Prop({ required: true })
    titleAr: string;

    @Prop({ required: true })
    body: string;

    @Prop({ required: true })
    bodyAr: string;

    @Prop()
    image?: string;

    // ═════════════════════════════════════
    // Action
    // ═════════════════════════════════════
    @Prop()
    actionType?: string; // 'order', 'product', 'promotion', 'url'

    @Prop()
    actionId?: string;

    @Prop()
    actionUrl?: string;

    // ═════════════════════════════════════
    // Reference
    // ═════════════════════════════════════
    @Prop()
    referenceType?: string;

    @Prop({ type: Types.ObjectId })
    referenceId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Channels & Status
    // ═════════════════════════════════════
    @Prop({ type: [String], default: ['push'] })
    channels: string[]; // ['push', 'sms', 'email']

    @Prop({
        type: Object,
        default: {},
    })
    channelStatus: {
        push?: { sent: boolean; sentAt?: Date; error?: string };
        sms?: { sent: boolean; sentAt?: Date; error?: string };
        email?: { sent: boolean; sentAt?: Date; error?: string };
    };

    @Prop({ default: false })
    isRead: boolean;

    @Prop({ type: Date })
    readAt?: Date;

    // ═════════════════════════════════════
    // Campaign
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'NotificationCampaign' })
    campaignId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Scheduling
    // ═════════════════════════════════════
    @Prop({ type: Date })
    scheduledAt?: Date;

    @Prop({ default: false })
    isSent: boolean;

    @Prop({ type: Date })
    sentAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);

NotificationSchema.index({ customerId: 1, createdAt: -1 });
NotificationSchema.index({ adminUserId: 1, createdAt: -1 });
NotificationSchema.index({ category: 1 });
NotificationSchema.index({ isRead: 1 });
NotificationSchema.index({ isSent: 1, scheduledAt: 1 });
NotificationSchema.index({ campaignId: 1 });
