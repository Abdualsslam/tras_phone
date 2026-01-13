import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Setting, SettingSchema } from './schemas/setting.schema';
import { Country, CountrySchema } from './schemas/country.schema';
import { City, CitySchema } from './schemas/city.schema';
import { Currency, CurrencySchema } from './schemas/currency.schema';
import { TaxRate, TaxRateSchema } from './schemas/tax-rate.schema';
import {
  ShippingZone,
  ShippingZoneSchema,
} from './schemas/shipping-zone.schema';
import {
  PaymentMethod,
  PaymentMethodSchema,
} from './schemas/payment-method.schema';
import { AppVersion, AppVersionSchema } from './schemas/app-version.schema';
import { SettingsService } from './settings.service';
import { AppVersionService } from './app-version.service';
import { SettingsController } from './settings.controller';
import { AuthModule } from '@modules/auth/auth.module';

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
      { name: AppVersion.name, schema: AppVersionSchema },
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
  controllers: [SettingsController],
  providers: [SettingsService, AppVersionService],
  exports: [SettingsService, AppVersionService],
})
export class SettingsModule implements OnModuleInit {
  constructor(private readonly settingsService: SettingsService) {}

  async onModuleInit() {
    await this.settingsService.seedDefaultSettings();
    await this.settingsService.seedDefaultData();
  }
}
