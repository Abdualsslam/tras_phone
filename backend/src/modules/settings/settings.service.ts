import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Setting, SettingDocument, SettingGroup, SettingType } from './schemas/setting.schema';
import { Country, CountryDocument } from './schemas/country.schema';
import { City, CityDocument } from './schemas/city.schema';
import { Currency, CurrencyDocument } from './schemas/currency.schema';
import { TaxRate, TaxRateDocument } from './schemas/tax-rate.schema';
import { ShippingZone, ShippingZoneDocument } from './schemas/shipping-zone.schema';
import { PaymentMethod, PaymentMethodDocument, PaymentMethodType } from './schemas/payment-method.schema';

@Injectable()
export class SettingsService {
    constructor(
        @InjectModel(Setting.name) private settingModel: Model<SettingDocument>,
        @InjectModel(Country.name) private countryModel: Model<CountryDocument>,
        @InjectModel(City.name) private cityModel: Model<CityDocument>,
        @InjectModel(Currency.name) private currencyModel: Model<CurrencyDocument>,
        @InjectModel(TaxRate.name) private taxRateModel: Model<TaxRateDocument>,
        @InjectModel(ShippingZone.name) private shippingZoneModel: Model<ShippingZoneDocument>,
        @InjectModel(PaymentMethod.name) private paymentMethodModel: Model<PaymentMethodDocument>,
    ) { }

    // ==================== Settings ====================

    async getSetting(key: string): Promise<any> {
        const setting = await this.settingModel.findOne({ key });
        return setting?.value ?? setting?.defaultValue ?? null;
    }

    async getSettings(group?: SettingGroup): Promise<Setting[]> {
        const query = group ? { group } : {};
        return this.settingModel.find(query).sort({ group: 1, sortOrder: 1 }).exec();
    }

    async getPublicSettings(): Promise<Record<string, any>> {
        const settings = await this.settingModel.find({
            isVisible: true,
            isEncrypted: { $ne: true }
        });

        return settings.reduce((acc, s) => {
            acc[s.key] = s.value ?? s.defaultValue;
            return acc;
        }, {} as Record<string, any>);
    }

    async getStoreSettings(): Promise<Record<string, any>> {
        const settings = await this.settingModel.find({
            group: SettingGroup.GENERAL
        });

        const result: Record<string, any> = {
            storeName: '',
            storeEmail: '',
            storePhone: '',
            storeAddress: '',
            storeDescription: '',
            logo: '',
            favicon: '',
        };

        settings.forEach(setting => {
            if (setting.key === 'store_name_ar') result.storeName = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_email') result.storeEmail = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_phone') result.storePhone = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_address_ar') result.storeAddress = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_description') result.storeDescription = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_logo') result.logo = setting.value ?? setting.defaultValue ?? '';
            if (setting.key === 'store_favicon') result.favicon = setting.value ?? setting.defaultValue ?? '';
        });

        return result;
    }

    async updateStoreSettings(data: Record<string, any>, updatedBy?: string): Promise<Record<string, any>> {
        const keyMap: Record<string, string> = {
            storeName: 'store_name_ar',
            storeEmail: 'store_email',
            storePhone: 'store_phone',
            storeAddress: 'store_address_ar',
            storeDescription: 'store_description',
            logo: 'store_logo',
            favicon: 'store_favicon',
        };

        for (const [field, value] of Object.entries(data)) {
            const settingKey = keyMap[field];
            if (settingKey && value !== undefined) {
                await this.settingModel.findOneAndUpdate(
                    { key: settingKey },
                    { 
                        value,
                        lastUpdatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined 
                    },
                    { upsert: true, new: true }
                );
            }
        }

        return this.getStoreSettings();
    }

    async getNotificationSettings(): Promise<Record<string, any>> {
        const settings = await this.settingModel.find({
            group: SettingGroup.NOTIFICATION
        });

        const result: Record<string, any> = {
            newOrder: false,
            newCustomer: false,
            lowStock: false,
            supportTicket: false,
            emailEnabled: false,
            pushEnabled: false,
        };

        settings.forEach(setting => {
            const key = setting.key.replace('notification_', '').replace(/_/g, '');
            result[key] = setting.value ?? setting.defaultValue ?? false;
        });

        return result;
    }

    async updateNotificationSettings(data: Record<string, any>): Promise<Record<string, any>> {
        for (const [key, value] of Object.entries(data)) {
            const settingKey = `notification_${key}`;
            await this.settingModel.findOneAndUpdate(
                { key: settingKey },
                { value },
                { upsert: true, new: true }
            );
        }
        return this.getNotificationSettings();
    }

    async updateSetting(key: string, value: any, updatedBy?: string): Promise<Setting> {
        const setting = await this.settingModel.findOne({ key });
        if (!setting) throw new NotFoundException('Setting not found');
        if (!setting.isEditable) throw new BadRequestException('Setting is not editable');

        // Validate value based on type
        this.validateSettingValue(setting, value);

        setting.value = value;
        setting.lastUpdatedBy = updatedBy ? new Types.ObjectId(updatedBy) : undefined;
        return setting.save();
    }

    async updateMultipleSettings(
        settings: { key: string; value: any }[],
        updatedBy?: string
    ): Promise<void> {
        for (const { key, value } of settings) {
            await this.updateSetting(key, value, updatedBy);
        }
    }

    private validateSettingValue(setting: Setting, value: any): void {
        switch (setting.type) {
            case SettingType.NUMBER:
                if (typeof value !== 'number') throw new BadRequestException('Value must be a number');
                if (setting.minValue !== undefined && value < setting.minValue) {
                    throw new BadRequestException(`Value must be at least ${setting.minValue}`);
                }
                if (setting.maxValue !== undefined && value > setting.maxValue) {
                    throw new BadRequestException(`Value must be at most ${setting.maxValue}`);
                }
                break;
            case SettingType.BOOLEAN:
                if (typeof value !== 'boolean') throw new BadRequestException('Value must be a boolean');
                break;
            case SettingType.EMAIL:
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(value)) throw new BadRequestException('Invalid email format');
                break;
            case SettingType.URL:
                try { new URL(value); } catch { throw new BadRequestException('Invalid URL format'); }
                break;
        }
    }

    // ==================== Countries ====================

    async createCountry(data: Partial<Country> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const createData: any = { ...data };
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const country = await this.countryModel.create(createData);
        
        // Transform to match frontend expectations
        return {
            _id: country._id,
            name: country.nameEn,
            nameAr: country.nameAr,
            code: country.code,
            phoneCode: country.phoneCode,
            isActive: country.isActive,
            isDefault: country.isDefault,
            allowShipping: country.allowShipping,
            allowBilling: country.allowBilling,
            sortOrder: country.sortOrder,
            currency: country.currency,
            flagEmoji: country.flagEmoji,
            flagUrl: country.flagUrl,
        };
    }

    async findAllCountries(activeOnly: boolean = true): Promise<any[]> {
        const query = activeOnly ? { isActive: true } : {};
        const countries = await this.countryModel.find(query).sort({ sortOrder: 1, nameEn: 1 }).exec();
        
        // Transform to match frontend expectations
        return countries.map(country => ({
            _id: country._id,
            name: country.nameEn,
            nameAr: country.nameAr,
            code: country.code,
            phoneCode: country.phoneCode,
            isActive: country.isActive,
            isDefault: country.isDefault,
            allowShipping: country.allowShipping,
            allowBilling: country.allowBilling,
            sortOrder: country.sortOrder,
            currency: country.currency,
            flagEmoji: country.flagEmoji,
            flagUrl: country.flagUrl,
        }));
    }

    async findShippingCountries(): Promise<Country[]> {
        return this.countryModel.find({ isActive: true, allowShipping: true }).sort({ sortOrder: 1 }).exec();
    }

    async updateCountry(id: string, data: Partial<Country> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const updateData: any = { ...data };
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const country = await this.countryModel.findByIdAndUpdate(id, updateData, { new: true });
        if (!country) throw new NotFoundException('Country not found');
        
        // Transform to match frontend expectations
        return {
            _id: country._id,
            name: country.nameEn,
            nameAr: country.nameAr,
            code: country.code,
            phoneCode: country.phoneCode,
            isActive: country.isActive,
            isDefault: country.isDefault,
            allowShipping: country.allowShipping,
            allowBilling: country.allowBilling,
            sortOrder: country.sortOrder,
            currency: country.currency,
            flagEmoji: country.flagEmoji,
            flagUrl: country.flagUrl,
        };
    }

    // ==================== Cities ====================

    async createCity(data: Partial<City>): Promise<any> {
        // Convert countryId to country if provided
        const createData: any = { ...data };
        if (createData.countryId) {
            createData.country = new Types.ObjectId(createData.countryId);
            delete createData.countryId;
        }
        // Convert name to nameEn if provided
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const city = await this.cityModel.create(createData);
        await city.populate('country', 'nameAr nameEn code');
        
        // Transform to match frontend expectations
        return {
            _id: city._id,
            name: city.nameEn,
            nameAr: city.nameAr,
            countryId: typeof city.country === 'object' && city.country?._id ? city.country._id.toString() : city.country?.toString() || city.country,
            country: city.country,
            isActive: city.isActive,
            allowDelivery: city.allowDelivery,
            shippingFee: city.shippingFee,
            estimatedDeliveryDays: city.estimatedDeliveryDays,
            sortOrder: city.sortOrder,
            code: city.code,
            postalCode: city.postalCode,
            latitude: city.latitude,
            longitude: city.longitude,
        };
    }

    async findAllCities(countryId?: string, activeOnly: boolean = false): Promise<any[]> {
        const query: any = {};
        if (countryId) {
            query.country = new Types.ObjectId(countryId);
        }
        if (activeOnly) {
            query.isActive = true;
        }
        const cities = await this.cityModel.find(query).populate('country', 'nameAr nameEn code').sort({ sortOrder: 1, nameEn: 1 }).exec();
        
        // Transform to match frontend expectations
        return cities.map(city => ({
            _id: city._id,
            name: city.nameEn,
            nameAr: city.nameAr,
            countryId: typeof city.country === 'object' && city.country?._id ? city.country._id.toString() : city.country?.toString() || city.country,
            country: city.country,
            isActive: city.isActive,
            allowDelivery: city.allowDelivery,
            shippingFee: city.shippingFee,
            estimatedDeliveryDays: city.estimatedDeliveryDays,
            sortOrder: city.sortOrder,
            code: city.code,
            postalCode: city.postalCode,
            latitude: city.latitude,
            longitude: city.longitude,
        }));
    }

    async findCitiesByCountry(countryId: string, activeOnly: boolean = true): Promise<City[]> {
        const query: any = { country: new Types.ObjectId(countryId) };
        if (activeOnly) query.isActive = true;
        return this.cityModel.find(query).sort({ sortOrder: 1, nameEn: 1 }).exec();
    }

    async findDeliveryCities(countryId: string): Promise<City[]> {
        return this.cityModel.find({
            country: new Types.ObjectId(countryId),
            isActive: true,
            allowDelivery: true,
        }).sort({ sortOrder: 1 }).exec();
    }

    async updateCity(id: string, data: Partial<City>): Promise<any> {
        // Convert countryId to country if provided
        const updateData: any = { ...data };
        if (updateData.countryId) {
            updateData.country = new Types.ObjectId(updateData.countryId);
            delete updateData.countryId;
        }
        // Convert name to nameEn if provided
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const city = await this.cityModel.findByIdAndUpdate(id, updateData, { new: true }).populate('country', 'nameAr nameEn code');
        if (!city) throw new NotFoundException('City not found');
        
        // Transform to match frontend expectations
        return {
            _id: city._id,
            name: city.nameEn,
            nameAr: city.nameAr,
            countryId: typeof city.country === 'object' && city.country?._id ? city.country._id.toString() : city.country?.toString() || city.country,
            country: city.country,
            isActive: city.isActive,
            allowDelivery: city.allowDelivery,
            shippingFee: city.shippingFee,
            estimatedDeliveryDays: city.estimatedDeliveryDays,
            sortOrder: city.sortOrder,
            code: city.code,
            postalCode: city.postalCode,
            latitude: city.latitude,
            longitude: city.longitude,
        };
    }

    // ==================== Currencies ====================

    async createCurrency(data: Partial<Currency> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const createData: any = { ...data };
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const currency = await this.currencyModel.create(createData);
        
        // Transform to match frontend expectations
        return {
            _id: currency._id,
            name: currency.nameEn,
            nameAr: currency.nameAr,
            code: currency.code,
            symbol: currency.symbol,
            symbolNative: currency.symbolNative,
            decimalDigits: currency.decimalDigits,
            exchangeRate: currency.exchangeRate,
            isDefault: currency.isDefault,
            isActive: currency.isActive,
            symbolPosition: currency.symbolPosition,
            thousandsSeparator: currency.thousandsSeparator,
            decimalSeparator: currency.decimalSeparator,
            sortOrder: currency.sortOrder,
        };
    }

    async findAllCurrencies(activeOnly: boolean = true): Promise<any[]> {
        const query = activeOnly ? { isActive: true } : {};
        const currencies = await this.currencyModel.find(query).sort({ sortOrder: 1 }).exec();
        
        // Transform to match frontend expectations
        return currencies.map(currency => ({
            _id: currency._id,
            name: currency.nameEn,
            nameAr: currency.nameAr,
            code: currency.code,
            symbol: currency.symbol,
            symbolNative: currency.symbolNative,
            decimalDigits: currency.decimalDigits,
            exchangeRate: currency.exchangeRate,
            isDefault: currency.isDefault,
            isActive: currency.isActive,
            symbolPosition: currency.symbolPosition,
            thousandsSeparator: currency.thousandsSeparator,
            decimalSeparator: currency.decimalSeparator,
            sortOrder: currency.sortOrder,
        }));
    }

    async getDefaultCurrency(): Promise<Currency> {
        const currency = await this.currencyModel.findOne({ isDefault: true });
        if (!currency) throw new NotFoundException('Default currency not set');
        return currency;
    }

    async updateCurrency(id: string, data: Partial<Currency> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const updateData: any = { ...data };
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const currency = await this.currencyModel.findByIdAndUpdate(id, updateData, { new: true });
        if (!currency) throw new NotFoundException('Currency not found');
        
        // Transform to match frontend expectations
        return {
            _id: currency._id,
            name: currency.nameEn,
            nameAr: currency.nameAr,
            code: currency.code,
            symbol: currency.symbol,
            symbolNative: currency.symbolNative,
            decimalDigits: currency.decimalDigits,
            exchangeRate: currency.exchangeRate,
            isDefault: currency.isDefault,
            isActive: currency.isActive,
            symbolPosition: currency.symbolPosition,
            thousandsSeparator: currency.thousandsSeparator,
            decimalSeparator: currency.decimalSeparator,
            sortOrder: currency.sortOrder,
        };
    }

    async updateExchangeRate(code: string, rate: number): Promise<Currency> {
        const currency = await this.currencyModel.findOneAndUpdate(
            { code },
            { exchangeRate: rate, lastRateUpdate: new Date() },
            { new: true }
        );
        if (!currency) throw new NotFoundException('Currency not found');
        return currency;
    }

    // ==================== Tax Rates ====================

    async createTaxRate(data: Partial<TaxRate> & { name?: string }, createdBy?: string): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const createData: any = { ...data };
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const rate = await this.taxRateModel.create({
            ...createData,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });
        
        // Transform to match frontend expectations
        return {
            _id: rate._id,
            name: rate.nameEn,
            nameAr: rate.nameAr,
            code: rate.code,
            rate: rate.rate,
            type: rate.type,
            isActive: rate.isActive,
            isDefault: rate.isDefault,
            isCompound: rate.isCompound,
            includeInPrice: rate.includeInPrice,
            countries: rate.countries,
            categories: rate.categories,
            productTypes: rate.productTypes,
            priority: rate.priority,
        };
    }

    async findAllTaxRates(activeOnly: boolean = true): Promise<any[]> {
        const query = activeOnly ? { isActive: true } : {};
        const rates = await this.taxRateModel.find(query).sort({ priority: -1 }).exec();
        
        // Transform to match frontend expectations
        return rates.map(rate => ({
            _id: rate._id,
            name: rate.nameEn,
            nameAr: rate.nameAr,
            code: rate.code,
            rate: rate.rate,
            type: rate.type,
            isActive: rate.isActive,
            isDefault: rate.isDefault,
            isCompound: rate.isCompound,
            includeInPrice: rate.includeInPrice,
            countries: rate.countries,
            categories: rate.categories,
            productTypes: rate.productTypes,
            priority: rate.priority,
        }));
    }

    async getDefaultTaxRate(): Promise<TaxRate | null> {
        return this.taxRateModel.findOne({ isDefault: true, isActive: true });
    }

    async calculateTax(amount: number, countryId?: string, categoryId?: string): Promise<number> {
        const query: any = { isActive: true };

        if (countryId) {
            query.$or = [
                { countries: { $size: 0 } },
                { countries: new Types.ObjectId(countryId) },
            ];
        }

        const taxRate = await this.taxRateModel.findOne(query).sort({ priority: -1 });
        if (!taxRate) return 0;

        return taxRate.type === 'percentage'
            ? (amount * taxRate.rate) / 100
            : taxRate.rate;
    }

    async updateTaxRate(id: string, data: Partial<TaxRate> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const updateData: any = { ...data };
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const rate = await this.taxRateModel.findByIdAndUpdate(id, updateData, { new: true });
        if (!rate) throw new NotFoundException('Tax rate not found');
        
        // Transform to match frontend expectations
        return {
            _id: rate._id,
            name: rate.nameEn,
            nameAr: rate.nameAr,
            code: rate.code,
            rate: rate.rate,
            type: rate.type,
            isActive: rate.isActive,
            isDefault: rate.isDefault,
            isCompound: rate.isCompound,
            includeInPrice: rate.includeInPrice,
            countries: rate.countries,
            categories: rate.categories,
            productTypes: rate.productTypes,
            priority: rate.priority,
        };
    }

    // ==================== Shipping Zones ====================

    async createShippingZone(data: Partial<ShippingZone> & { name?: string }, createdBy?: string): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const createData: any = { ...data };
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const zone = await this.shippingZoneModel.create({
            ...createData,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });
        
        // Transform to match frontend expectations
        return {
            _id: zone._id,
            name: zone.nameEn,
            nameAr: zone.nameAr,
            code: zone.code,
            countries: zone.countries,
            cities: zone.cities,
            postalCodes: zone.postalCodes,
            rates: zone.rates,
            isActive: zone.isActive,
            sortOrder: zone.sortOrder,
            restrictedProducts: zone.restrictedProducts,
            excludedCategories: zone.excludedCategories,
            maxWeight: zone.maxWeight,
        };
    }

    async findAllShippingZones(activeOnly: boolean = true): Promise<any[]> {
        const query = activeOnly ? { isActive: true } : {};
        const zones = await this.shippingZoneModel
            .find(query)
            .populate('countries', 'nameAr nameEn code')
            .sort({ sortOrder: 1 })
            .exec();
        
        // Transform to match frontend expectations
        return zones.map(zone => ({
            _id: zone._id,
            name: zone.nameEn,
            nameAr: zone.nameAr,
            code: zone.code,
            countries: zone.countries,
            cities: zone.cities,
            postalCodes: zone.postalCodes,
            rates: zone.rates,
            isActive: zone.isActive,
            sortOrder: zone.sortOrder,
            restrictedProducts: zone.restrictedProducts,
            excludedCategories: zone.excludedCategories,
            maxWeight: zone.maxWeight,
        }));
    }

    async findShippingZoneForCity(cityId: string): Promise<ShippingZone | null> {
        const city = await this.cityModel.findById(cityId);
        if (!city) return null;

        // Try to find zone by city first
        let zone = await this.shippingZoneModel.findOne({
            isActive: true,
            cities: new Types.ObjectId(cityId),
        });

        // Fallback to country zone
        if (!zone) {
            zone = await this.shippingZoneModel.findOne({
                isActive: true,
                countries: city.country,
                cities: { $size: 0 },
            });
        }

        return zone;
    }

    async calculateShipping(cityId: string, weight: number, orderAmount: number): Promise<any> {
        const zone = await this.findShippingZoneForCity(cityId);
        if (!zone) throw new BadRequestException('Shipping not available for this location');

        const availableRates = zone.rates.filter(r => {
            if (!r.isActive) return false;
            if (r.minWeight && weight < r.minWeight) return false;
            if (r.maxWeight && weight > r.maxWeight) return false;
            return true;
        });

        return availableRates.map(rate => {
            let cost = rate.cost;

            if (rate.type === 'free' && orderAmount >= rate.minOrderAmount) {
                cost = 0;
            } else if (rate.type === 'weight') {
                cost = rate.cost + (weight * (rate.weightRate || 0));
            }

            return {
                name: { ar: rate.nameAr, en: rate.nameEn },
                cost,
                estimatedDays: rate.estimatedDays,
                type: rate.type,
            };
        });
    }

    async updateShippingZone(id: string, data: Partial<ShippingZone> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const updateData: any = { ...data };
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const zone = await this.shippingZoneModel.findByIdAndUpdate(id, updateData, { new: true });
        if (!zone) throw new NotFoundException('Shipping zone not found');
        
        // Transform to match frontend expectations
        return {
            _id: zone._id,
            name: zone.nameEn,
            nameAr: zone.nameAr,
            code: zone.code,
            countries: zone.countries,
            cities: zone.cities,
            postalCodes: zone.postalCodes,
            rates: zone.rates,
            isActive: zone.isActive,
            sortOrder: zone.sortOrder,
            restrictedProducts: zone.restrictedProducts,
            excludedCategories: zone.excludedCategories,
            maxWeight: zone.maxWeight,
        };
    }

    // ==================== Payment Methods ====================

    async createPaymentMethod(data: Partial<PaymentMethod> & { name?: string }): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const createData: any = { ...data };
        if (createData.name && !createData.nameEn) {
            createData.nameEn = createData.name;
            delete createData.name;
        }
        const method = await this.paymentMethodModel.create(createData);
        
        // Transform to match frontend expectations
        return {
            _id: method._id,
            name: method.nameEn,
            nameAr: method.nameAr,
            type: method.type,
            descriptionAr: method.descriptionAr,
            descriptionEn: method.descriptionEn,
            icon: method.icon,
            logo: method.logo,
            gateway: method.gateway,
            gatewayConfig: method.gatewayConfig,
            fixedFee: method.fixedFee,
            percentageFee: method.percentageFee,
            minAmount: method.minAmount,
            maxAmount: method.maxAmount,
            isActive: method.isActive,
            countries: method.countries,
            platforms: method.platforms,
            sortOrder: method.sortOrder,
            instructionsAr: method.instructionsAr,
            instructionsEn: method.instructionsEn,
            bankDetails: method.bankDetails,
        };
    }

    async findActivePaymentMethods(platform?: string): Promise<PaymentMethod[]> {
        const query: any = { isActive: true };
        if (platform) {
            // Normalize android/ios -> mobile; DB uses "web" | "mobile" only
            const normalized =
                platform === 'android' || platform === 'ios' ? 'mobile' : platform;
            query.platforms = normalized;
        }

        return this.paymentMethodModel
            .find(query)
            .select('-gatewayConfig') // Don't expose sensitive config
            .sort({ sortOrder: 1 })
            .exec();
    }

    async findAllPaymentMethods(): Promise<any[]> {
        const methods = await this.paymentMethodModel.find().sort({ sortOrder: 1 }).exec();
        
        // Transform to match frontend expectations
        return methods.map(method => ({
            _id: method._id,
            name: method.nameEn,
            nameAr: method.nameAr,
            type: method.type,
            descriptionAr: method.descriptionAr,
            descriptionEn: method.descriptionEn,
            icon: method.icon,
            logo: method.logo,
            gateway: method.gateway,
            gatewayConfig: method.gatewayConfig,
            fixedFee: method.fixedFee,
            percentageFee: method.percentageFee,
            minAmount: method.minAmount,
            maxAmount: method.maxAmount,
            isActive: method.isActive,
            countries: method.countries,
            platforms: method.platforms,
            sortOrder: method.sortOrder,
            instructionsAr: method.instructionsAr,
            instructionsEn: method.instructionsEn,
            bankDetails: method.bankDetails,
        }));
    }

    async getPaymentMethodConfig(type: PaymentMethodType): Promise<PaymentMethod> {
        const method = await this.paymentMethodModel.findOne({ type });
        if (!method) throw new NotFoundException('Payment method not found');
        return method;
    }

    async updatePaymentMethod(id: string, data: Partial<PaymentMethod> & { name?: string }, updatedBy?: string): Promise<any> {
        // Convert name to nameEn if provided (for frontend compatibility)
        const updateData: any = { ...data };
        if (updateData.name && !updateData.nameEn) {
            updateData.nameEn = updateData.name;
            delete updateData.name;
        }
        const method = await this.paymentMethodModel.findByIdAndUpdate(
            id,
            { ...updateData, lastUpdatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined },
            { new: true }
        );
        if (!method) throw new NotFoundException('Payment method not found');
        
        // Transform to match frontend expectations
        return {
            _id: method._id,
            name: method.nameEn,
            nameAr: method.nameAr,
            type: method.type,
            descriptionAr: method.descriptionAr,
            descriptionEn: method.descriptionEn,
            icon: method.icon,
            logo: method.logo,
            gateway: method.gateway,
            gatewayConfig: method.gatewayConfig,
            fixedFee: method.fixedFee,
            percentageFee: method.percentageFee,
            minAmount: method.minAmount,
            maxAmount: method.maxAmount,
            isActive: method.isActive,
            countries: method.countries,
            platforms: method.platforms,
            sortOrder: method.sortOrder,
            instructionsAr: method.instructionsAr,
            instructionsEn: method.instructionsEn,
            bankDetails: method.bankDetails,
        };
    }

    // ==================== Seeding ====================

    async seedDefaultSettings(): Promise<void> {
        const count = await this.settingModel.countDocuments();
        if (count > 0) return;

        const settings = [
            // General
            { key: 'store_name_ar', labelAr: 'اسم المتجر', labelEn: 'Store Name', value: 'متجر تراس فون', type: SettingType.STRING, group: SettingGroup.GENERAL, isProtected: true, sortOrder: 1 },
            { key: 'store_name_en', labelAr: 'اسم المتجر (انجليزي)', labelEn: 'Store Name (English)', value: 'Tras Phone Store', type: SettingType.STRING, group: SettingGroup.GENERAL, isProtected: true, sortOrder: 2 },
            { key: 'store_email', labelAr: 'البريد الإلكتروني', labelEn: 'Store Email', value: 'info@trasphone.com', type: SettingType.EMAIL, group: SettingGroup.GENERAL, sortOrder: 3 },
            { key: 'store_phone', labelAr: 'رقم الهاتف', labelEn: 'Store Phone', value: '+966500000000', type: SettingType.STRING, group: SettingGroup.GENERAL, sortOrder: 4 },
            { key: 'store_address_ar', labelAr: 'العنوان', labelEn: 'Store Address', value: 'الرياض، المملكة العربية السعودية', type: SettingType.TEXTAREA, group: SettingGroup.GENERAL, sortOrder: 5 },
            { key: 'store_logo', labelAr: 'شعار المتجر', labelEn: 'Store Logo', type: SettingType.IMAGE, group: SettingGroup.GENERAL, sortOrder: 6 },

            // Store settings
            { key: 'default_language', labelAr: 'اللغة الافتراضية', labelEn: 'Default Language', value: 'ar', type: SettingType.STRING, group: SettingGroup.STORE, options: ['ar', 'en'], sortOrder: 1 },
            { key: 'timezone', labelAr: 'المنطقة الزمنية', labelEn: 'Timezone', value: 'Asia/Riyadh', type: SettingType.STRING, group: SettingGroup.STORE, sortOrder: 2 },
            { key: 'maintenance_mode', labelAr: 'وضع الصيانة', labelEn: 'Maintenance Mode', value: false, type: SettingType.BOOLEAN, group: SettingGroup.STORE, sortOrder: 3 },

            // Checkout
            { key: 'min_order_amount', labelAr: 'الحد الأدنى للطلب', labelEn: 'Minimum Order Amount', value: 50, type: SettingType.NUMBER, group: SettingGroup.CHECKOUT, sortOrder: 1 },
            { key: 'allow_guest_checkout', labelAr: 'السماح بالشراء للزوار', labelEn: 'Allow Guest Checkout', value: true, type: SettingType.BOOLEAN, group: SettingGroup.CHECKOUT, sortOrder: 2 },
            { key: 'stock_check_enabled', labelAr: 'التحقق من المخزون', labelEn: 'Stock Check Enabled', value: true, type: SettingType.BOOLEAN, group: SettingGroup.CHECKOUT, sortOrder: 3 },

            // Inventory
            { key: 'low_stock_threshold', labelAr: 'حد المخزون المنخفض', labelEn: 'Low Stock Threshold', value: 10, type: SettingType.NUMBER, group: SettingGroup.INVENTORY, sortOrder: 1 },
            { key: 'out_of_stock_visibility', labelAr: 'إظهار المنتجات غير المتوفرة', labelEn: 'Show Out of Stock Products', value: true, type: SettingType.BOOLEAN, group: SettingGroup.INVENTORY, sortOrder: 2 },

            // Loyalty
            { key: 'loyalty_enabled', labelAr: 'تفعيل نقاط الولاء', labelEn: 'Loyalty Program Enabled', value: true, type: SettingType.BOOLEAN, group: SettingGroup.LOYALTY, sortOrder: 1 },
            { key: 'points_per_sar', labelAr: 'نقاط لكل ريال', labelEn: 'Points per SAR', value: 1, type: SettingType.NUMBER, group: SettingGroup.LOYALTY, sortOrder: 2 },
            { key: 'points_value_in_sar', labelAr: 'قيمة النقطة بالريال', labelEn: 'Point Value in SAR', value: 0.01, type: SettingType.NUMBER, group: SettingGroup.LOYALTY, sortOrder: 3 },

            // Social
            { key: 'facebook_url', labelAr: 'رابط فيسبوك', labelEn: 'Facebook URL', type: SettingType.URL, group: SettingGroup.SOCIAL, sortOrder: 1 },
            { key: 'twitter_url', labelAr: 'رابط تويتر', labelEn: 'Twitter URL', type: SettingType.URL, group: SettingGroup.SOCIAL, sortOrder: 2 },
            { key: 'instagram_url', labelAr: 'رابط انستغرام', labelEn: 'Instagram URL', type: SettingType.URL, group: SettingGroup.SOCIAL, sortOrder: 3 },
            { key: 'whatsapp_number', labelAr: 'رقم واتساب', labelEn: 'WhatsApp Number', type: SettingType.STRING, group: SettingGroup.SOCIAL, sortOrder: 4 },

            // SEO
            { key: 'meta_title_ar', labelAr: 'عنوان الميتا', labelEn: 'Meta Title', type: SettingType.STRING, group: SettingGroup.SEO, sortOrder: 1 },
            { key: 'meta_description_ar', labelAr: 'وصف الميتا', labelEn: 'Meta Description', type: SettingType.TEXTAREA, group: SettingGroup.SEO, sortOrder: 2 },
            { key: 'google_analytics_id', labelAr: 'معرف Google Analytics', labelEn: 'Google Analytics ID', type: SettingType.STRING, group: SettingGroup.SEO, sortOrder: 3 },

            // Notifications
            { key: 'notification_newOrder', labelAr: 'إشعار طلب جديد', labelEn: 'New Order Notification', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 1 },
            { key: 'notification_newCustomer', labelAr: 'إشعار عميل جديد', labelEn: 'New Customer Notification', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 2 },
            { key: 'notification_lowStock', labelAr: 'إشعار مخزون منخفض', labelEn: 'Low Stock Notification', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 3 },
            { key: 'notification_supportTicket', labelAr: 'إشعار تذكرة دعم', labelEn: 'Support Ticket Notification', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 4 },
            { key: 'notification_emailEnabled', labelAr: 'تفعيل الإشعارات عبر البريد', labelEn: 'Email Notifications Enabled', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 5 },
            { key: 'notification_pushEnabled', labelAr: 'تفعيل الإشعارات الفورية', labelEn: 'Push Notifications Enabled', value: true, type: SettingType.BOOLEAN, group: SettingGroup.NOTIFICATION, sortOrder: 6 },
        ];

        await this.settingModel.insertMany(settings);
    }

    async seedDefaultData(): Promise<void> {
        // Seed SAR currency
        const currencyCount = await this.currencyModel.countDocuments();
        if (currencyCount === 0) {
            await this.currencyModel.create({
                nameAr: 'ريال سعودي',
                nameEn: 'Saudi Riyal',
                code: 'SAR',
                symbol: 'ر.س',
                symbolNative: '﷼',
                isDefault: true,
                symbolPosition: 'after',
            });
        }

        // Seed Saudi Arabia
        const countryCount = await this.countryModel.countDocuments();
        if (countryCount === 0) {
            const sa = await this.countryModel.create({
                nameAr: 'المملكة العربية السعودية',
                nameEn: 'Saudi Arabia',
                code: 'SA',
                code3: 'SAU',
                phoneCode: '+966',
                currency: 'SAR',
                flagEmoji: '🇸🇦',
                isDefault: true,
            });

            // Seed major cities
            const cities = [
                { nameAr: 'الرياض', nameEn: 'Riyadh', shippingFee: 0, estimatedDeliveryDays: 1 },
                { nameAr: 'جدة', nameEn: 'Jeddah', shippingFee: 0, estimatedDeliveryDays: 2 },
                { nameAr: 'مكة المكرمة', nameEn: 'Makkah', shippingFee: 15, estimatedDeliveryDays: 2 },
                { nameAr: 'المدينة المنورة', nameEn: 'Madinah', shippingFee: 15, estimatedDeliveryDays: 2 },
                { nameAr: 'الدمام', nameEn: 'Dammam', shippingFee: 0, estimatedDeliveryDays: 2 },
                { nameAr: 'الخبر', nameEn: 'Khobar', shippingFee: 0, estimatedDeliveryDays: 2 },
                { nameAr: 'الظهران', nameEn: 'Dhahran', shippingFee: 15, estimatedDeliveryDays: 2 },
                { nameAr: 'الطائف', nameEn: 'Taif', shippingFee: 20, estimatedDeliveryDays: 3 },
                { nameAr: 'تبوك', nameEn: 'Tabuk', shippingFee: 25, estimatedDeliveryDays: 3 },
                { nameAr: 'أبها', nameEn: 'Abha', shippingFee: 25, estimatedDeliveryDays: 3 },
            ];

            for (const city of cities) {
                await this.cityModel.create({ ...city, country: sa._id });
            }
        }

        // Seed VAT
        const taxCount = await this.taxRateModel.countDocuments();
        if (taxCount === 0) {
            await this.taxRateModel.create({
                nameAr: 'ضريبة القيمة المضافة',
                nameEn: 'VAT',
                code: 'vat-15',
                rate: 15,
                isDefault: true,
                includeInPrice: true,
            });
        }

        // Seed Payment Methods
        const paymentCount = await this.paymentMethodModel.countDocuments();
        if (paymentCount === 0) {
            const methods = [
                { nameAr: 'الدفع عند الاستلام', nameEn: 'Cash on Delivery', type: PaymentMethodType.CASH_ON_DELIVERY, icon: 'cash', sortOrder: 1 },
                { nameAr: 'بطاقة مدى', nameEn: 'Mada Card', type: PaymentMethodType.MADA, icon: 'mada', gateway: 'hyperpay', sortOrder: 2 },
                { nameAr: 'بطاقة ائتمان', nameEn: 'Credit Card', type: PaymentMethodType.CREDIT_CARD, icon: 'credit-card', gateway: 'hyperpay', sortOrder: 3 },
                { nameAr: 'Apple Pay', nameEn: 'Apple Pay', type: PaymentMethodType.APPLE_PAY, icon: 'apple', gateway: 'hyperpay', sortOrder: 4 },
                { nameAr: 'STC Pay', nameEn: 'STC Pay', type: PaymentMethodType.STC_PAY, icon: 'stc', gateway: 'hyperpay', sortOrder: 5 },
                { nameAr: 'تحويل بنكي', nameEn: 'Bank Transfer', type: PaymentMethodType.BANK_TRANSFER, icon: 'bank', sortOrder: 6 },
                { nameAr: 'المحفظة', nameEn: 'Wallet', type: PaymentMethodType.WALLET, icon: 'wallet', gateway: 'internal', sortOrder: 7 },
            ];
            await this.paymentMethodModel.insertMany(methods);
        }
    }
}
