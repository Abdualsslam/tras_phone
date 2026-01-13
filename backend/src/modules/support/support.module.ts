import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TicketCategory, TicketCategorySchema } from './schemas/ticket-category.schema';
import { Ticket, TicketSchema } from './schemas/ticket.schema';
import { TicketMessage, TicketMessageSchema } from './schemas/ticket-message.schema';
import { CannedResponse, CannedResponseSchema } from './schemas/canned-response.schema';
import { ChatSession, ChatSessionSchema } from './schemas/chat-session.schema';
import { ChatMessage, ChatMessageSchema } from './schemas/chat-message.schema';
import { TicketsService } from './tickets.service';
import { ChatService } from './chat.service';
import { TicketsController } from './tickets.controller';
import { ChatController } from './chat.controller';
import { AuthModule } from '@modules/auth/auth.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: TicketCategory.name, schema: TicketCategorySchema },
            { name: Ticket.name, schema: TicketSchema },
            { name: TicketMessage.name, schema: TicketMessageSchema },
            { name: CannedResponse.name, schema: CannedResponseSchema },
            { name: ChatSession.name, schema: ChatSessionSchema },
            { name: ChatMessage.name, schema: ChatMessageSchema },
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
        AuthModule,
    ],
    controllers: [TicketsController, ChatController],
    providers: [TicketsService, ChatService],
    exports: [TicketsService, ChatService],
})
export class SupportModule implements OnModuleInit {
    constructor(private readonly ticketsService: TicketsService) { }

    async onModuleInit() {
        await this.ticketsService.seedCategories();
    }
}
