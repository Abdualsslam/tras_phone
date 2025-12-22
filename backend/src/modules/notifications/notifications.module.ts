import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { NotificationTemplate, NotificationTemplateSchema } from './schemas/notification-template.schema';
import { Notification, NotificationSchema } from './schemas/notification.schema';
import { NotificationCampaign, NotificationCampaignSchema } from './schemas/notification-campaign.schema';
import { PushToken, PushTokenSchema } from './schemas/push-token.schema';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: NotificationTemplate.name, schema: NotificationTemplateSchema },
            { name: Notification.name, schema: NotificationSchema },
            { name: NotificationCampaign.name, schema: NotificationCampaignSchema },
            { name: PushToken.name, schema: PushTokenSchema },
        ]),
    ],
    controllers: [NotificationsController],
    providers: [NotificationsService],
    exports: [NotificationsService],
})
export class NotificationsModule implements OnModuleInit {
    constructor(private notificationsService: NotificationsService) { }

    async onModuleInit() {
        await this.notificationsService.seedTemplates();
    }
}
