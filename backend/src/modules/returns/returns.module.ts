import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ReturnRequest, ReturnRequestSchema } from './schemas/return-request.schema';
import { ReturnItem, ReturnItemSchema } from './schemas/return-item.schema';
import { ReturnStatusHistory, ReturnStatusHistorySchema } from './schemas/return-status-history.schema';
import { Refund, RefundSchema } from './schemas/refund.schema';
import { ReturnReason, ReturnReasonSchema } from './schemas/return-reason.schema';
import { ReturnsService } from './returns.service';
import { ReturnsController } from './returns.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: ReturnRequest.name, schema: ReturnRequestSchema },
            { name: ReturnItem.name, schema: ReturnItemSchema },
            { name: ReturnStatusHistory.name, schema: ReturnStatusHistorySchema },
            { name: Refund.name, schema: RefundSchema },
            { name: ReturnReason.name, schema: ReturnReasonSchema },
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
    ],
    controllers: [ReturnsController],
    providers: [ReturnsService],
    exports: [ReturnsService],
})
export class ReturnsModule implements OnModuleInit {
    constructor(private returnsService: ReturnsService) { }

    async onModuleInit() {
        await this.returnsService.seedReturnReasons();
    }
}
