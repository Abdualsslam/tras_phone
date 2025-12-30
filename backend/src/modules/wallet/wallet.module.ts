import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { WalletTransaction, WalletTransactionSchema } from './schemas/wallet-transaction.schema';
import { LoyaltyTier, LoyaltyTierSchema } from './schemas/loyalty-tier.schema';
import { LoyaltyTransaction, LoyaltyTransactionSchema } from './schemas/loyalty-transaction.schema';
import { PointsExpiry, PointsExpirySchema } from './schemas/points-expiry.schema';
import { WalletService } from './wallet.service';
import { WalletController } from './wallet.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: WalletTransaction.name, schema: WalletTransactionSchema },
            { name: LoyaltyTier.name, schema: LoyaltyTierSchema },
            { name: LoyaltyTransaction.name, schema: LoyaltyTransactionSchema },
            { name: PointsExpiry.name, schema: PointsExpirySchema },
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
    controllers: [WalletController],
    providers: [WalletService],
    exports: [WalletService],
})
export class WalletModule implements OnModuleInit {
    constructor(private walletService: WalletService) { }

    async onModuleInit() {
        await this.walletService.seedTiers();
    }
}
