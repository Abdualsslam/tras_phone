import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ScheduleModule } from '@nestjs/schedule';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Customer, CustomerSchema } from '@modules/customers/schemas/customer.schema';
import { TicketCategory, TicketCategorySchema } from './schemas/ticket-category.schema';
import { Ticket, TicketSchema } from './schemas/ticket.schema';
import { TicketMessage, TicketMessageSchema } from './schemas/ticket-message.schema';
import { CannedResponse, CannedResponseSchema } from './schemas/canned-response.schema';
import { ChatSession, ChatSessionSchema } from './schemas/chat-session.schema';
import { ChatMessage, ChatMessageSchema } from './schemas/chat-message.schema';
import { ChatBotRule, ChatBotRuleSchema } from './schemas/chat-bot-rule.schema';
import { SupportAudit, SupportAuditSchema } from './schemas/support-audit.schema';
import { TicketsService } from './tickets.service';
import { ChatService } from './chat.service';
import { SupportController } from './support.controller';
import { TicketsController } from './tickets.controller';
import { ChatController } from './chat.controller';
import { ReportsController } from './controllers/reports.controller';
import { SupportGateway } from './gateways/support.gateway';
import { SupportNotificationsService } from './services/support-notifications.service';
import { SLAMonitorService } from './services/sla-monitor.service';
import { SupportReportsService } from './services/support-reports.service';
import { ChatBotService } from './services/chat-bot.service';
import { AuditLogService } from './services/audit-log.service';
import { AuthModule } from '@modules/auth/auth.module';
import { UploadsModule } from '@modules/uploads/uploads.module';
import { NotificationsModule } from '@modules/notifications/notifications.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Customer.name, schema: CustomerSchema },
            { name: TicketCategory.name, schema: TicketCategorySchema },
            { name: Ticket.name, schema: TicketSchema },
            { name: TicketMessage.name, schema: TicketMessageSchema },
            { name: CannedResponse.name, schema: CannedResponseSchema },
            { name: ChatSession.name, schema: ChatSessionSchema },
            { name: ChatMessage.name, schema: ChatMessageSchema },
            { name: ChatBotRule.name, schema: ChatBotRuleSchema },
            { name: SupportAudit.name, schema: SupportAuditSchema },
        ]),
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => ({
                secret: configService.get<string>('JWT_SECRET'),
                signOptions: {
                    expiresIn: configService.get<string>('JWT_EXPIRATION', '15m'),
                },
            }),
            inject: [ConfigService],
        }),
        ScheduleModule.forRoot(),
        AuthModule,
        UploadsModule,
        NotificationsModule,
    ],
    controllers: [SupportController, TicketsController, ChatController, ReportsController],
    providers: [TicketsService, ChatService, SupportGateway, SupportNotificationsService, SLAMonitorService, SupportReportsService, ChatBotService, AuditLogService],
    exports: [TicketsService, ChatService, SupportGateway, SupportNotificationsService, SLAMonitorService, SupportReportsService, ChatBotService, AuditLogService],
})
export class SupportModule implements OnModuleInit {
    constructor(
        private readonly ticketsService: TicketsService,
        private readonly chatBotService: ChatBotService,
    ) { }

    async onModuleInit() {
        await this.ticketsService.seedCategories();
        await this.chatBotService.seedDefaultRules();
    }
}
