import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { NotificationTemplate, NotificationTemplateDocument } from './schemas/notification-template.schema';
import { Notification, NotificationDocument } from './schemas/notification.schema';
import { NotificationCampaign, NotificationCampaignDocument } from './schemas/notification-campaign.schema';
import { PushToken, PushTokenDocument } from './schemas/push-token.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔔 Notifications Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class NotificationsService {
    constructor(
        @InjectModel(NotificationTemplate.name) private templateModel: Model<NotificationTemplateDocument>,
        @InjectModel(Notification.name) private notificationModel: Model<NotificationDocument>,
        @InjectModel(NotificationCampaign.name) private campaignModel: Model<NotificationCampaignDocument>,
        @InjectModel(PushToken.name) private pushTokenModel: Model<PushTokenDocument>,
    ) { }

    // ═════════════════════════════════════
    // Send Notifications
    // ═════════════════════════════════════

    /**
     * Send notification using template
     */
    async sendFromTemplate(
        templateCode: string,
        recipientId: string,
        recipientType: 'customer' | 'admin',
        variables: Record<string, string> = {},
        reference?: { type: string; id: string },
    ): Promise<NotificationDocument> {
        const template = await this.templateModel.findOne({ code: templateCode, isActive: true });
        if (!template) throw new NotFoundException(`Template ${templateCode} not found`);

        // Replace variables in content
        const replaceVars = (text: string) => {
            let result = text;
            for (const [key, value] of Object.entries(variables)) {
                result = result.replace(new RegExp(`{{${key}}}`, 'g'), value);
            }
            return result;
        };

        const channels: string[] = [];
        if (template.pushEnabled) channels.push('push');
        if (template.smsEnabled) channels.push('sms');
        if (template.emailEnabled) channels.push('email');

        const notification = await this.notificationModel.create({
            customerId: recipientType === 'customer' ? recipientId : undefined,
            adminUserId: recipientType === 'admin' ? recipientId : undefined,
            templateId: template._id,
            templateCode: template.code,
            category: template.category,
            title: replaceVars(template.pushTitle),
            titleAr: replaceVars(template.pushTitleAr),
            body: replaceVars(template.pushBody),
            bodyAr: replaceVars(template.pushBodyAr),
            image: template.pushImage,
            channels,
            referenceType: reference?.type,
            referenceId: reference?.id ? new Types.ObjectId(reference.id) : undefined,
        });

        // Send through channels
        await this.deliverNotification(notification);

        return notification;
    }

    /**
     * Send custom notification
     */
    async sendCustom(data: {
        customerId?: string;
        adminUserId?: string;
        category: string;
        title: string;
        titleAr: string;
        body: string;
        bodyAr: string;
        image?: string;
        actionType?: string;
        actionId?: string;
        actionUrl?: string;
        channels?: string[];
        scheduledAt?: Date;
    }): Promise<NotificationDocument> {
        const notification = await this.notificationModel.create({
            ...data,
            channels: data.channels || ['push'],
            isSent: !data.scheduledAt,
            sentAt: data.scheduledAt ? undefined : new Date(),
        });

        if (!data.scheduledAt) {
            await this.deliverNotification(notification);
        }

        return notification;
    }

    /**
     * Deliver notification through channels
     */
    private async deliverNotification(notification: NotificationDocument): Promise<void> {
        const channelStatus: any = {};

        for (const channel of notification.channels) {
            try {
                switch (channel) {
                    case 'push':
                        await this.sendPush(notification);
                        channelStatus.push = { sent: true, sentAt: new Date() };
                        break;
                    case 'sms':
                        // TODO: Integrate Unifonic
                        channelStatus.sms = { sent: false, error: 'SMS not configured' };
                        break;
                    case 'email':
                        // TODO: Integrate SendGrid/SMTP
                        channelStatus.email = { sent: false, error: 'Email not configured' };
                        break;
                }
            } catch (error: any) {
                channelStatus[channel] = { sent: false, error: error.message };
            }
        }

        await this.notificationModel.findByIdAndUpdate(notification._id, {
            $set: { channelStatus, isSent: true, sentAt: new Date() },
        });
    }

    /**
     * Send push notification
     */
    private async sendPush(notification: NotificationDocument): Promise<void> {
        const recipientId = notification.customerId || notification.adminUserId;
        const isCustomer = !!notification.customerId;

        const tokens = await this.pushTokenModel.find({
            [isCustomer ? 'customerId' : 'adminUserId']: recipientId,
            isActive: true,
        });

        if (tokens.length === 0) return;

        // TODO: Integrate Firebase Admin SDK
        // const messages = tokens.map(token => ({
        //   token: token.token,
        //   notification: {
        //     title: notification.title,
        //     body: notification.body,
        //     image: notification.image,
        //   },
        //   data: {
        //     category: notification.category,
        //     actionType: notification.actionType,
        //     actionId: notification.actionId,
        //   },
        // }));
        // await admin.messaging().sendEach(messages);

        console.log(`Push notification sent to ${tokens.length} devices`);
    }

    // ═════════════════════════════════════
    // Get Notifications
    // ═════════════════════════════════════

    async getCustomerNotifications(customerId: string, filters?: any): Promise<{ data: NotificationDocument[]; total: number; unreadCount: number }> {
        const query: any = { customerId, isSent: true };
        if (filters?.category) query.category = filters.category;
        if (filters?.isRead !== undefined) query.isRead = filters.isRead;

        const [data, total, unreadCount] = await Promise.all([
            this.notificationModel.find(query).sort({ createdAt: -1 }).limit(filters?.limit || 50),
            this.notificationModel.countDocuments(query),
            this.notificationModel.countDocuments({ customerId, isRead: false, isSent: true }),
        ]);

        return { data, total, unreadCount };
    }

    async markAsRead(notificationId: string): Promise<void> {
        await this.notificationModel.findByIdAndUpdate(notificationId, {
            $set: { isRead: true, readAt: new Date() },
        });
    }

    async markAllAsRead(customerId: string): Promise<void> {
        await this.notificationModel.updateMany(
            { customerId, isRead: false },
            { $set: { isRead: true, readAt: new Date() } },
        );
    }

    // ═════════════════════════════════════
    // Push Tokens
    // ═════════════════════════════════════

    async registerToken(data: {
        customerId?: string;
        adminUserId?: string;
        token: string;
        provider: string;
        platform: string;
        deviceId?: string;
        deviceName?: string;
        appVersion?: string;
    }): Promise<PushTokenDocument> {
        return this.pushTokenModel.findOneAndUpdate(
            { token: data.token },
            {
                $set: {
                    ...data,
                    isActive: true,
                    lastUsedAt: new Date(),
                },
            },
            { upsert: true, new: true },
        );
    }

    async invalidateToken(token: string, reason?: string): Promise<void> {
        await this.pushTokenModel.findOneAndUpdate(
            { token },
            { $set: { isActive: false, invalidatedAt: new Date(), invalidReason: reason } },
        );
    }

    // ═════════════════════════════════════
    // Templates
    // ═════════════════════════════════════

    async getTemplates(): Promise<NotificationTemplateDocument[]> {
        return this.templateModel.find({ isActive: true }).sort({ category: 1, name: 1 });
    }

    async createTemplate(data: any): Promise<NotificationTemplateDocument> {
        return this.templateModel.create(data);
    }

    async updateTemplate(id: string, data: any): Promise<NotificationTemplateDocument> {
        const template = await this.templateModel.findByIdAndUpdate(id, { $set: data }, { new: true });
        if (!template) throw new NotFoundException('Template not found');
        return template;
    }

    // ═════════════════════════════════════
    // Campaigns
    // ═════════════════════════════════════

    async getCampaigns(filters?: any): Promise<NotificationCampaignDocument[]> {
        const query: any = {};
        if (filters?.status) query.status = filters.status;

        return this.campaignModel.find(query).sort({ createdAt: -1 });
    }

    async createCampaign(data: any): Promise<NotificationCampaignDocument> {
        return this.campaignModel.create(data);
    }

    async launchCampaign(campaignId: string): Promise<void> {
        const campaign = await this.campaignModel.findById(campaignId);
        if (!campaign) throw new NotFoundException('Campaign not found');

        // TODO: Implement campaign sending logic
        // 1. Get target customers based on filters
        // 2. Create notifications for each
        // 3. Send in batches

        await this.campaignModel.findByIdAndUpdate(campaignId, {
            $set: { status: 'sending', startedAt: new Date() },
        });

        console.log(`Campaign ${campaign.name} launched`);
    }

    // ═════════════════════════════════════
    // Seed Templates
    // ═════════════════════════════════════

    async seedTemplates(): Promise<void> {
        const count = await this.templateModel.countDocuments();
        if (count > 0) return;

        console.log('Seeding notification templates...');

        const templates = [
            {
                code: 'order_confirmed',
                name: 'Order Confirmed',
                nameAr: 'تأكيد الطلب',
                category: 'order',
                pushTitle: 'Order Confirmed ✅',
                pushTitleAr: 'تم تأكيد طلبك ✅',
                pushBody: 'Your order #{{orderNumber}} has been confirmed',
                pushBodyAr: 'تم تأكيد طلبك رقم #{{orderNumber}}',
                variables: ['orderNumber', 'customerName'],
            },
            {
                code: 'order_shipped',
                name: 'Order Shipped',
                nameAr: 'تم شحن الطلب',
                category: 'order',
                pushTitle: 'Order Shipped 🚚',
                pushTitleAr: 'تم شحن طلبك 🚚',
                pushBody: 'Your order #{{orderNumber}} is on its way',
                pushBodyAr: 'طلبك رقم #{{orderNumber}} في الطريق إليك',
                variables: ['orderNumber'],
            },
            {
                code: 'order_delivered',
                name: 'Order Delivered',
                nameAr: 'تم التوصيل',
                category: 'order',
                pushTitle: 'Order Delivered 📦',
                pushTitleAr: 'تم توصيل طلبك 📦',
                pushBody: 'Your order #{{orderNumber}} has been delivered',
                pushBodyAr: 'تم توصيل طلبك رقم #{{orderNumber}}',
                variables: ['orderNumber'],
            },
            {
                code: 'payment_received',
                name: 'Payment Received',
                nameAr: 'تم استلام الدفعة',
                category: 'payment',
                pushTitle: 'Payment Received 💰',
                pushTitleAr: 'تم استلام الدفعة 💰',
                pushBody: 'We received your payment of {{amount}} SAR',
                pushBodyAr: 'تم استلام مبلغ {{amount}} ريال',
                variables: ['amount'],
            },
        ];

        await this.templateModel.insertMany(templates);
        console.log('✅ Notification templates seeded');
    }
}
