import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type NotificationCampaignDocument = NotificationCampaign & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📢 Notification Campaign Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'notification_campaigns',
})
export class NotificationCampaign {
    @Prop({ required: true })
    name: string;

    @Prop()
    description?: string;

    @Prop({
        required: true,
        type: String,
        enum: ['promotion', 'announcement', 'reminder', 're_engagement', 'custom'],
    })
    type: string;

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

    @Prop()
    actionType?: string;

    @Prop()
    actionId?: string;

    @Prop()
    actionUrl?: string;

    // ═════════════════════════════════════
    // Channels
    // ═════════════════════════════════════
    @Prop({ type: [String], default: ['push'] })
    channels: string[];

    // ═════════════════════════════════════
    // Targeting
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['all', 'segment', 'specific'],
        default: 'all',
    })
    targetType: string;

    @Prop({ type: [Types.ObjectId], ref: 'Customer' })
    targetCustomers?: Types.ObjectId[];

    @Prop({ type: Object })
    targetFilters?: {
        priceLevelIds?: string[];
        loyaltyTierIds?: string[];
        cities?: string[];
        lastOrderDaysAgo?: number;
        hasNoOrders?: boolean;
    };

    // ═════════════════════════════════════
    // Scheduling
    // ═════════════════════════════════════
    @Prop({ type: Date })
    scheduledAt?: Date;

    @Prop({ default: false })
    isRecurring: boolean;

    @Prop()
    recurringPattern?: string; // Cron expression

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['draft', 'scheduled', 'sending', 'sent', 'cancelled'],
        default: 'draft',
    })
    status: string;

    // ═════════════════════════════════════
    // Statistics
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalRecipients: number;

    @Prop({ type: Number, default: 0 })
    sentCount: number;

    @Prop({ type: Number, default: 0 })
    deliveredCount: number;

    @Prop({ type: Number, default: 0 })
    openedCount: number;

    @Prop({ type: Number, default: 0 })
    clickedCount: number;

    @Prop({ type: Number, default: 0 })
    failedCount: number;

    @Prop({ type: Date })
    startedAt?: Date;

    @Prop({ type: Date })
    completedAt?: Date;

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    createdBy?: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const NotificationCampaignSchema = SchemaFactory.createForClass(NotificationCampaign);

NotificationCampaignSchema.index({ status: 1 });
NotificationCampaignSchema.index({ type: 1 });
NotificationCampaignSchema.index({ scheduledAt: 1 });
NotificationCampaignSchema.index({ createdAt: -1 });
