import { Module, OnModuleInit, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import {
  ReturnRequest,
  ReturnRequestSchema,
} from './schemas/return-request.schema';
import { ReturnItem, ReturnItemSchema } from './schemas/return-item.schema';
import {
  ReturnStatusHistory,
  ReturnStatusHistorySchema,
} from './schemas/return-status-history.schema';
import { Refund, RefundSchema } from './schemas/refund.schema';
import {
  ReturnReason,
  ReturnReasonSchema,
} from './schemas/return-reason.schema';
import {
  SupplierReturnBatch,
  SupplierReturnBatchSchema,
} from './schemas/supplier-return-batch.schema';
import { ReturnsService } from './returns.service';
import { ReturnsController } from './returns.controller';
import { AuthModule } from '@modules/auth/auth.module';
import { OrderItem, OrderItemSchema } from '@modules/orders/schemas/order-item.schema';
import { WalletModule } from '@modules/wallet/wallet.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: ReturnRequest.name, schema: ReturnRequestSchema },
      { name: ReturnItem.name, schema: ReturnItemSchema },
      { name: ReturnStatusHistory.name, schema: ReturnStatusHistorySchema },
      { name: Refund.name, schema: RefundSchema },
      { name: ReturnReason.name, schema: ReturnReasonSchema },
      { name: SupplierReturnBatch.name, schema: SupplierReturnBatchSchema },
      { name: OrderItem.name, schema: OrderItemSchema },
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
    forwardRef(() => WalletModule),
  ],
  controllers: [ReturnsController],
  providers: [ReturnsService],
  exports: [ReturnsService],
})
export class ReturnsModule implements OnModuleInit {
  constructor(private returnsService: ReturnsService) {}

  async onModuleInit() {
    await this.returnsService.seedReturnReasons();
  }
}
