import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type NotificationTemplateDocument = NotificationTemplate & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Notification Template Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'notification_templates',
})
export class NotificationTemplate {
    @Prop({ required: true, unique: true })
    code: string; // 'order_confirmed', 'order_shipped', etc.

    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop()
    description?: string;

    @Prop({
        required: true,
        type: String,
        enum: ['order', 'payment', 'promotion', 'system', 'account', 'support'],
    })
    category: string;

    // ═════════════════════════════════════
    // Push Notification
    // ═════════════════════════════════════
    @Prop({ required: true })
    pushTitle: string;

    @Prop({ required: true })
    pushTitleAr: string;

    @Prop({ required: true })
    pushBody: string;

    @Prop({ required: true })
    pushBodyAr: string;

    @Prop()
    pushImage?: string;

    // ═════════════════════════════════════
    // SMS (optional)
    // ═════════════════════════════════════
    @Prop()
    smsBody?: string;

    @Prop()
    smsBodyAr?: string;

    // ═════════════════════════════════════
    // Email (optional)
    // ═════════════════════════════════════
    @Prop()
    emailSubject?: string;

    @Prop()
    emailSubjectAr?: string;

    @Prop()
    emailBody?: string; // HTML

    @Prop()
    emailBodyAr?: string;

    // ═════════════════════════════════════
    // Variables
    // ═════════════════════════════════════
    @Prop({ type: [String] })
    variables?: string[]; // ['{{customerName}}', '{{orderNumber}}']

    // ═════════════════════════════════════
    // Channels
    // ═════════════════════════════════════
    @Prop({ default: true })
    pushEnabled: boolean;

    @Prop({ default: false })
    smsEnabled: boolean;

    @Prop({ default: false })
    emailEnabled: boolean;

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const NotificationTemplateSchema = SchemaFactory.createForClass(NotificationTemplate);

NotificationTemplateSchema.index({ code: 1 });
NotificationTemplateSchema.index({ category: 1 });
NotificationTemplateSchema.index({ isActive: 1 });
