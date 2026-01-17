import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Country, CountryDocument } from './schemas/country.schema';
import { City, CityDocument } from './schemas/city.schema';
import { Market, MarketDocument } from './schemas/market.schema';
import { ShippingZone, ShippingZoneDocument } from './schemas/shipping-zone.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🌍 Locations Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class LocationsService {
    constructor(
        @InjectModel(Country.name)
        private countryModel: Model<CountryDocument>,
        @InjectModel(City.name)
        private cityModel: Model<CityDocument>,
        @InjectModel(Market.name)
        private marketModel: Model<MarketDocument>,
        @InjectModel(ShippingZone.name)
        private shippingZoneModel: Model<ShippingZoneDocument>,
    ) { }

    // ═════════════════════════════════════
    // Countries
    // ═════════════════════════════════════

    async findAllCountries(): Promise<CountryDocument[]> {
        return this.countryModel.find({ isActive: true }).sort({ name: 1 });
    }

    async getDefaultCountry(): Promise<CountryDocument | null> {
        return this.countryModel.findOne({ isDefault: true });
    }

    // ═════════════════════════════════════
    // Cities
    // ═════════════════════════════════════

    async findAllCities(countryId?: string): Promise<CityDocument[]> {
        const query: any = { isActive: true };

        if (countryId) {
            // دعم كلا الحقلين للتوافق مع البيانات القديمة والجديدة
            // البيانات الحالية تستخدم 'country' (من settings schema)
            // البيانات القديمة قد تستخدم 'countryId' (من locations schema)
            query.$or = [
                { country: new Types.ObjectId(countryId) },
                { countryId: new Types.ObjectId(countryId) },
            ];
        }

        return this.cityModel
            .find(query)
            .populate('country', 'nameAr nameEn code')
            .sort({ sortOrder: 1, displayOrder: 1, nameEn: 1, name: 1 }); // دعم كلا الحقلين
    }

    async findCityById(id: string): Promise<CityDocument | null> {
        return this.cityModel
            .findById(id)
            .populate('country', 'nameAr nameEn code');
    }

    // ═════════════════════════════════════
    // Markets
    // ═════════════════════════════════════

    async findMarketsByCity(cityId: string): Promise<MarketDocument[]> {
        return this.marketModel
            .find({ cityId, isActive: true })
            .sort({ displayOrder: 1, name: 1 });
    }

    async findMarketById(id: string): Promise<MarketDocument | null> {
        return this.marketModel.findById(id).populate('cityId');
    }

    // ═════════════════════════════════════
    // Shipping Zones
    // ═════════════════════════════════════

    async findAllShippingZones(): Promise<ShippingZoneDocument[]> {
        return this.shippingZoneModel
            .find({ isActive: true })
            .populate('countryId')
            .sort({ name: 1 });
    }

    // ═════════════════════════════════════
    // Seeding
    // ═════════════════════════════════════

    async seedSaudiArabiaData(): Promise<void> {
        const countryCount = await this.countryModel.countDocuments();

        if (countryCount > 0) {
            return; // Already seeded
        }

        console.log('Seeding Saudi Arabia location data...');

        // Create Saudi Arabia
        const saudi = await this.countryModel.create({
            name: 'Saudi Arabia',
            nameAr: 'المملكة العربية السعودية',
            code: 'SA',
            code3: 'SAU',
            phoneCode: '+966',
            currency: 'SAR',
            flag: '🇸🇦',
            isDefault: true,
        });

        // Create shipping zones
        const centralZone = await this.shippingZoneModel.create({
            name: 'Central Region',
            nameAr: 'المنطقة الوسطى',
            countryId: saudi._id,
            baseCost: 20,
            freeShippingThreshold: 500,
            estimatedDeliveryDays: 2,
            minDeliveryDays: 1,
            maxDeliveryDays: 3,
        });

        const westernZone = await this.shippingZoneModel.create({
            name: 'Western Region',
            nameAr: 'المنطقة الغربية',
            countryId: saudi._id,
            baseCost: 25,
            freeShippingThreshold: 500,
            estimatedDeliveryDays: 3,
            minDeliveryDays: 2,
            maxDeliveryDays: 4,
        });

        const easternZone = await this.shippingZoneModel.create({
            name: 'Eastern Region',
            nameAr: 'المنطقة الشرقية',
            countryId: saudi._id,
            baseCost: 25,
            freeShippingThreshold: 500,
            estimatedDeliveryDays: 3,
            minDeliveryDays: 2,
            maxDeliveryDays: 4,
        });

        // Create major cities
        const cities = [
            {
                name: 'Riyadh',
                nameAr: 'الرياض',
                countryId: saudi._id,
                shippingZoneId: centralZone._id,
                isCapital: true,
                timezone: 'Asia/Riyadh',
                latitude: 24.7136,
                longitude: 46.6753,
                region: 'Central',
                regionAr: 'الوسطى',
            },
            {
                name: 'Jeddah',
                nameAr: 'جدة',
                countryId: saudi._id,
                shippingZoneId: westernZone._id,
                timezone: 'Asia/Riyadh',
                latitude: 21.5433,
                longitude: 39.1728,
                region: 'Western',
                regionAr: 'الغربية',
            },
            {
                name: 'Dammam',
                nameAr: 'الدمام',
                countryId: saudi._id,
                shippingZoneId: easternZone._id,
                timezone: 'Asia/Riyadh',
                latitude: 26.4207,
                longitude: 50.0888,
                region: 'Eastern',
                regionAr: 'الشرقية',
            },
        ];

        await this.cityModel.insertMany(cities);

        console.log('✅ Saudi Arabia location data seeded successfully');
    }
}
