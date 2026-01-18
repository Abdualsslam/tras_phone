import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Customer, CustomerSchema } from './schemas/customer.schema';
import {
    CustomerAddress,
    CustomerAddressSchema,
} from './schemas/customer-address.schema';
import {
    CustomerPriceLevelHistory,
    CustomerPriceLevelHistorySchema,
} from './schemas/customer-price-level-history.schema';
import { Referral, ReferralSchema } from './schemas/referral.schema';
import { CustomersService } from './customers.service';
import { ReferralsService } from './referrals.service';
import { CustomersController } from './customers.controller';
import { CustomerProfileController } from './customer-profile.controller';
import { UsersModule } from '@modules/users/users.module';
import { AuthModule } from '@modules/auth/auth.module';
import { User, UserSchema } from '@modules/users/schemas/user.schema';

@Module({
    imports: [
        UsersModule,
        MongooseModule.forFeature([
            { name: Customer.name, schema: CustomerSchema },
            { name: CustomerAddress.name, schema: CustomerAddressSchema },
            {
                name: CustomerPriceLevelHistory.name,
                schema: CustomerPriceLevelHistorySchema,
            },
            { name: Referral.name, schema: ReferralSchema },
            { name: User.name, schema: UserSchema },
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
    controllers: [CustomersController, CustomerProfileController],
    providers: [CustomersService, ReferralsService],
    exports: [CustomersService, ReferralsService],
})
export class CustomersModule { }
