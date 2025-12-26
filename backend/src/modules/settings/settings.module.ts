import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Setting, SettingSchema } from './schemas/setting.schema';
import { Country, CountrySchema } from './schemas/country.schema';
import { City, CitySchema } from './schemas/city.schema';
import { Currency, CurrencySchema } from './schemas/currency.schema';
import { TaxRate, TaxRateSchema } from './schemas/tax-rate.schema';
import { ShippingZone, ShippingZoneSchema } from './schemas/shipping-zone.schema';
import { PaymentMethod, PaymentMethodSchema } from './schemas/payment-method.schema';
import { SettingsService } from './settings.service';
import { SettingsController } from './settings.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Setting.name, schema: SettingSchema },
            { name: Country.name, schema: CountrySchema },
            { name: City.name, schema: CitySchema },
            { name: Currency.name, schema: CurrencySchema },
            { name: TaxRate.name, schema: TaxRateSchema },
            { name: ShippingZone.name, schema: ShippingZoneSchema },
            { name: PaymentMethod.name, schema: PaymentMethodSchema },
        ]),
    ],
    controllers: [SettingsController],
    providers: [SettingsService],
    exports: [SettingsService],
})
export class SettingsModule implements OnModuleInit {
    constructor(private readonly settingsService: SettingsService) { }

    async onModuleInit() {
        await this.settingsService.seedDefaultSettings();
        await this.settingsService.seedDefaultData();
    }
}
