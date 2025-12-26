import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
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

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Customer.name, schema: CustomerSchema },
            { name: CustomerAddress.name, schema: CustomerAddressSchema },
            {
                name: CustomerPriceLevelHistory.name,
                schema: CustomerPriceLevelHistorySchema,
            },
            { name: Referral.name, schema: ReferralSchema },
        ]),
    ],
    controllers: [CustomersController],
    providers: [CustomersService, ReferralsService],
    exports: [CustomersService, ReferralsService],
})
export class CustomersModule { }
