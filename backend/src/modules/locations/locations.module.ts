import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Country, CountrySchema } from './schemas/country.schema';
import { City, CitySchema } from './schemas/city.schema';
import { Market, MarketSchema } from './schemas/market.schema';
import { ShippingZone, ShippingZoneSchema } from './schemas/shipping-zone.schema';
import { LocationsService } from './locations.service';
import { ShippingService } from './shipping.service';
import { LocationsController } from './locations.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Country.name, schema: CountrySchema },
            { name: City.name, schema: CitySchema },
            { name: Market.name, schema: MarketSchema },
            { name: ShippingZone.name, schema: ShippingZoneSchema },
        ]),
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
