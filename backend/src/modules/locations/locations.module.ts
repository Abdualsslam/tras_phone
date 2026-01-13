import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Country, CountrySchema } from './schemas/country.schema';
import { City, CitySchema } from './schemas/city.schema';
import { Market, MarketSchema } from './schemas/market.schema';
import { ShippingZone, ShippingZoneSchema } from './schemas/shipping-zone.schema';
import { LocationsService } from './locations.service';
import { ShippingService } from './shipping.service';
import { LocationsController } from './locations.controller';
import { AuthModule } from '@modules/auth/auth.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Country.name, schema: CountrySchema },
            { name: City.name, schema: CitySchema },
            { name: Market.name, schema: MarketSchema },
            { name: ShippingZone.name, schema: ShippingZoneSchema },
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
    controllers: [LocationsController],
    providers: [LocationsService, ShippingService],
    exports: [LocationsService, ShippingService],
})
export class LocationsModule implements OnModuleInit {
    constructor(private locationsService: LocationsService) { }

    /**
     * Seed Saudi Arabia data on module initialization
     */
    async onModuleInit() {
        await this.locationsService.seedSaudiArabiaData();
    }
}
