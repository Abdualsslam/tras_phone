import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Setting,
  SettingDocument,
  SettingGroup,
  SettingType,
} from './schemas/setting.schema';
import { Country, CountryDocument } from './schemas/country.schema';
import { City, CityDocument } from './schemas/city.schema';
import { Currency, CurrencyDocument } from './schemas/currency.schema';
import { TaxRate, TaxRateDocument } from './schemas/tax-rate.schema';
import {
  ShippingZone,
  ShippingZoneDocument,
} from './schemas/shipping-zone.schema';
import {
  PaymentMethod,
  PaymentMethodDocument,
  PaymentMethodType,
} from './schemas/payment-method.schema';
import {
  BankAccount,
  BankAccountDocument,
} from '@modules/orders/schemas/bank-account.schema';

@Injectable()
export class SettingsService {
  constructor(
    @InjectModel(Setting.name) private settingModel: Model<SettingDocument>,
    @InjectModel(Country.name) private countryModel: Model<CountryDocument>,
    @InjectModel(City.name) private cityModel: Model<CityDocument>,
    @InjectModel(Currency.name) private currencyModel: Model<CurrencyDocument>,
    @InjectModel(TaxRate.name) private taxRateModel: Model<TaxRateDocument>,
    @InjectModel(ShippingZone.name)
    private shippingZoneModel: Model<ShippingZoneDocument>,
    @InjectModel(PaymentMethod.name)
    private paymentMethodModel: Model<PaymentMethodDocument>,
    @InjectModel(BankAccount.name)
    private bankAccountModel: Model<BankAccountDocument>,
  ) {}

  // ==================== Settings ====================

  async getSetting(key: string): Promise<any> {
    const setting = await this.settingModel.findOne({ key });
    return setting?.value ?? setting?.defaultValue ?? null;
  }

  async getSettings(group?: SettingGroup): Promise<Setting[]> {
    const query = group ? { group } : {};
    return this.settingModel
      .find(query)
      .sort({ group: 1, sortOrder: 1 })
      .exec();
  }

  async getPublicSettings(): Promise<Record<string, any>> {
    const settings = await this.settingModel.find({
      isVisible: true,
      isEncrypted: { $ne: true },
    });

    return settings.reduce(
      (acc, s) => {
        acc[s.key] = s.value ?? s.defaultValue;
        return acc;
      },
      {} as Record<string, any>,
    );
  }

  async getStoreSettings(): Promise<Record<string, any>> {
    const settings = await this.settingModel.find({
      group: SettingGroup.GENERAL,
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

    settings.forEach((setting) => {
      if (setting.key === 'store_name_ar')
        result.storeName = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_email')
        result.storeEmail = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_phone')
        result.storePhone = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_address_ar')
        result.storeAddress = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_description')
        result.storeDescription = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_logo')
        result.logo = setting.value ?? setting.defaultValue ?? '';
      if (setting.key === 'store_favicon')
        result.favicon = setting.value ?? setting.defaultValue ?? '';
    });

    return result;
  }

  async updateStoreSettings(
    data: Record<string, any>,
    updatedBy?: string,
  ): Promise<Record<string, any>> {
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
            lastUpdatedBy: updatedBy
              ? new Types.ObjectId(updatedBy)
              : undefined,
          },
          { upsert: true, new: true },
        );
      }
    }

    return this.getStoreSettings();
  }

  async getNotificationSettings(): Promise<Record<string, any>> {
    const settings = await this.settingModel.find({
      $or: [
        { group: SettingGroup.NOTIFICATION },
        { key: { $regex: '^notification_' } },
      ],
    });

    const result: Record<string, any> = {
      newOrder: false,
      newCustomer: false,
      lowStock: false,
      supportTicket: false,
      emailEnabled: false,
      pushEnabled: false,
    };

    const keyMap: Record<string, keyof typeof result> = {
      neworder: 'newOrder',
      new_order: 'newOrder',
      newcustomer: 'newCustomer',
      new_customer: 'newCustomer',
      lowstock: 'lowStock',
      low_stock: 'lowStock',
      supportticket: 'supportTicket',
      support_ticket: 'supportTicket',
      emailenabled: 'emailEnabled',
      email_enabled: 'emailEnabled',
      pushenabled: 'pushEnabled',
      push_enabled: 'pushEnabled',
    };

    settings.forEach((setting) => {
      const rawKey = setting.key.replace('notification_', '').toLowerCase();
      const mappedKey = keyMap[rawKey] ?? keyMap[rawKey.replace(/_/g, '')];

      if (mappedKey) {
        result[mappedKey] = setting.value ?? setting.defaultValue ?? false;
      }
    });

    return result;
  }

  async updateNotificationSettings(
    data: Record<string, any>,
  ): Promise<Record<string, any>> {
    const allowedKeys = new Set([
      'newOrder',
      'newCustomer',
      'lowStock',
      'supportTicket',
      'emailEnabled',
      'pushEnabled',
    ]);

    const settingKeyMap: Record<string, string> = {
      newOrder: 'notification_neworder',
      newCustomer: 'notification_newcustomer',
      lowStock: 'notification_lowstock',
      supportTicket: 'notification_supportticket',
      emailEnabled: 'notification_emailenabled',
      pushEnabled: 'notification_pushenabled',
    };

    for (const [key, value] of Object.entries(data)) {
      if (!allowedKeys.has(key)) {
        continue;
      }

      const settingKey = settingKeyMap[key] || `notification_${key.toLowerCase()}`;
      await this.settingModel.findOneAndUpdate(
        { key: settingKey },
        {
          $set: { value },
          $setOnInsert: {
            key: settingKey,
            group: SettingGroup.NOTIFICATION,
            type: SettingType.BOOLEAN,
            isPublic: false,
            isEditable: true,
            sortOrder: 999,
          },
        },
        { upsert: true, new: true },
      );
    }
    return this.getNotificationSettings();
  }

  async updateSetting(
    key: string,
    value: any,
    updatedBy?: string,
  ): Promise<Setting> {
    const setting = await this.settingModel.findOne({ key });
    if (!setting) throw new NotFoundException('Setting not found');
    if (!setting.isEditable)
      throw new BadRequestException('Setting is not editable');

    // Validate value based on type
    this.validateSettingValue(setting, value);

    setting.value = value;
    setting.lastUpdatedBy = updatedBy
      ? new Types.ObjectId(updatedBy)
      : undefined;
    return setting.save();
  }

  async updateMultipleSettings(
    settings: { key: string; value: any }[],
    updatedBy?: string,
  ): Promise<void> {
    for (const { key, value } of settings) {
      await this.updateSetting(key, value, updatedBy);
    }
  }

  private validateSettingValue(setting: Setting, value: any): void {
    switch (setting.type) {
      case SettingType.NUMBER:
        if (typeof value !== 'number')
          throw new BadRequestException('Value must be a number');
        if (setting.minValue !== undefined && value < setting.minValue) {
          throw new BadRequestException(
            `Value must be at least ${setting.minValue}`,
          );
        }
        if (setting.maxValue !== undefined && value > setting.maxValue) {
          throw new BadRequestException(
            `Value must be at most ${setting.maxValue}`,
          );
        }
        break;
      case SettingType.BOOLEAN:
        if (typeof value !== 'boolean')
          throw new BadRequestException('Value must be a boolean');
        break;
      case SettingType.EMAIL:
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value))
          throw new BadRequestException('Invalid email format');
        break;
      case SettingType.URL:
        try {
          new URL(value);
        } catch {
          throw new BadRequestException('Invalid URL format');
        }
        break;
    }
  }

  // ==================== Countries ====================

  async createCountry(
    data: Partial<Country> & { name?: string },
  ): Promise<any> {
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
    const countries = await this.countryModel
      .find(query)
      .sort({ sortOrder: 1, nameEn: 1 })
      .exec();

    // Transform to match frontend expectations
    return countries.map((country) => ({
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
    return this.countryModel
      .find({ isActive: true, allowShipping: true })
      .sort({ sortOrder: 1 })
      .exec();
  }

  async updateCountry(
    id: string,
    data: Partial<Country> & { name?: string },
  ): Promise<any> {
    // Convert name to nameEn if provided (for frontend compatibility)
    const updateData: any = { ...data };
    if (updateData.name && !updateData.nameEn) {
      updateData.nameEn = updateData.name;
      delete updateData.name;
    }
    const country = await this.countryModel.findByIdAndUpdate(id, updateData, {
      new: true,
    });
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
      countryId:
        typeof city.country === 'object' && city.country?._id
          ? city.country._id.toString()
          : city.country?.toString() || city.country,
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

  async findAllCities(
    countryId?: string,
    activeOnly: boolean = false,
  ): Promise<any[]> {
    const query: any = {};
    if (countryId) {
      query.country = new Types.ObjectId(countryId);
    }
    if (activeOnly) {
      query.isActive = true;
    }
    const cities = await this.cityModel
      .find(query)
      .populate('country', 'nameAr nameEn code')
      .sort({ sortOrder: 1, nameEn: 1 })
      .exec();

    // Transform to match frontend expectations
    return cities.map((city) => ({
      _id: city._id,
      name: city.nameEn,
      nameAr: city.nameAr,
      countryId:
        typeof city.country === 'object' && city.country?._id
          ? city.country._id.toString()
          : city.country?.toString() || city.country,
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

  async findCitiesByCountry(
    countryId: string,
    activeOnly: boolean = true,
  ): Promise<City[]> {
    const query: any = { country: new Types.ObjectId(countryId) };
    if (activeOnly) query.isActive = true;
    return this.cityModel.find(query).sort({ sortOrder: 1, nameEn: 1 }).exec();
  }

  async findDeliveryCities(countryId: string): Promise<City[]> {
    return this.cityModel
      .find({
        country: new Types.ObjectId(countryId),
        isActive: true,
        allowDelivery: true,
      })
      .sort({ sortOrder: 1 })
      .exec();
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
    const city = await this.cityModel
      .findByIdAndUpdate(id, updateData, { new: true })
      .populate('country', 'nameAr nameEn code');
    if (!city) throw new NotFoundException('City not found');

    // Transform to match frontend expectations
    return {
      _id: city._id,
      name: city.nameEn,
      nameAr: city.nameAr,
      countryId:
        typeof city.country === 'object' && city.country?._id
          ? city.country._id.toString()
          : city.country?.toString() || city.country,
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

  async createCurrency(
    data: Partial<Currency> & { name?: string },
  ): Promise<any> {
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
    const currencies = await this.currencyModel
      .find(query)
      .sort({ sortOrder: 1 })
      .exec();

    // Transform to match frontend expectations
    return currencies.map((currency) => ({
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

  async updateCurrency(
    id: string,
    data: Partial<Currency> & { name?: string },
  ): Promise<any> {
    // Convert name to nameEn if provided (for frontend compatibility)
    const updateData: any = { ...data };
    if (updateData.name && !updateData.nameEn) {
      updateData.nameEn = updateData.name;
      delete updateData.name;
    }
    const currency = await this.currencyModel.findByIdAndUpdate(
      id,
      updateData,
      { new: true },
    );
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
      { new: true },
    );
    if (!currency) throw new NotFoundException('Currency not found');
    return currency;
  }

  // ==================== Tax Rates ====================

  async createTaxRate(
    data: Partial<TaxRate> & { name?: string },
    createdBy?: string,
  ): Promise<any> {
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
    const rates = await this.taxRateModel
      .find(query)
      .sort({ priority: -1 })
      .exec();

    // Transform to match frontend expectations
    return rates.map((rate) => ({
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

  async calculateTax(
    amount: number,
    countryId?: string,
    categoryId?: string,
  ): Promise<number> {
    const query: any = { isActive: true };

    if (countryId) {
      query.$or = [
        { countries: { $size: 0 } },
        { countries: new Types.ObjectId(countryId) },
      ];
    }

    const taxRate = await this.taxRateModel
      .findOne(query)
      .sort({ priority: -1 });
    if (!taxRate) return 0;

    return taxRate.type === 'percentage'
      ? (amount * taxRate.rate) / 100
      : taxRate.rate;
  }

  async updateTaxRate(
    id: string,
    data: Partial<TaxRate> & { name?: string },
  ): Promise<any> {
    // Convert name to nameEn if provided (for frontend compatibility)
    const updateData: any = { ...data };
    if (updateData.name && !updateData.nameEn) {
      updateData.nameEn = updateData.name;
      delete updateData.name;
    }
    const rate = await this.taxRateModel.findByIdAndUpdate(id, updateData, {
      new: true,
    });
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

  async createShippingZone(
    data: Partial<ShippingZone> & { name?: string },
    createdBy?: string,
  ): Promise<any> {
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
    return zones.map((zone) => ({
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

  async calculateShipping(
    cityId: string,
    weight: number,
    orderAmount: number,
  ): Promise<any> {
    const zone = await this.findShippingZoneForCity(cityId);
    if (!zone)
      throw new BadRequestException('Shipping not available for this location');

    const availableRates = zone.rates.filter((r) => {
      if (!r.isActive) return false;
      if (r.minWeight && weight < r.minWeight) return false;
      if (r.maxWeight && weight > r.maxWeight) return false;
      return true;
    });

    return availableRates.map((rate) => {
      let cost = rate.cost;

      if (rate.type === 'free' && orderAmount >= rate.minOrderAmount) {
        cost = 0;
      } else if (rate.type === 'weight') {
        cost = rate.cost + weight * (rate.weightRate || 0);
      }

      return {
        name: { ar: rate.nameAr, en: rate.nameEn },
        cost,
        estimatedDays: rate.estimatedDays,
        type: rate.type,
      };
    });
  }

  async updateShippingZone(
    id: string,
    data: Partial<ShippingZone> & { name?: string },
  ): Promise<any> {
    // Convert name to nameEn if provided (for frontend compatibility)
    const updateData: any = { ...data };
    if (updateData.name && !updateData.nameEn) {
      updateData.nameEn = updateData.name;
      delete updateData.name;
    }
    const zone = await this.shippingZoneModel.findByIdAndUpdate(
      id,
      updateData,
      { new: true },
    );
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

  private hasBankDetails(details?: Record<string, any>): boolean {
    if (!details) return false;

    const fields = [
      details.bankNameAr,
      details.bankNameEn,
      details.accountName,
      details.accountNumber,
      details.iban,
      details.swiftCode,
    ];

    return fields.some((value) => typeof value === 'string' && value.trim());
  }

  private mapPaymentMethodResponse(method: any): any {
    return {
      _id: method._id,
      name: method.nameEn,
      nameAr: method.nameAr,
      type: method.type,
      descriptionAr: method.descriptionAr,
      descriptionEn: method.descriptionEn,
      icon: method.logo || method.icon,
      logo: method.logo || method.icon,
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

  private mapBankAccountToPaymentMethod(
    account: BankAccountDocument,
    bankTransferBase?: PaymentMethodDocument | null,
  ): any {
    return {
      _id: account._id,
      name: account.displayName || account.bankName,
      nameAr:
        account.displayNameAr ||
        account.bankNameAr ||
        account.displayName ||
        account.bankName,
      type: PaymentMethodType.BANK_TRANSFER,
      descriptionAr: bankTransferBase?.descriptionAr || '',
      descriptionEn: bankTransferBase?.descriptionEn || '',
      icon: account.logo || bankTransferBase?.logo || bankTransferBase?.icon,
      logo: account.logo || bankTransferBase?.logo || bankTransferBase?.icon,
      gateway: bankTransferBase?.gateway || 'none',
      gatewayConfig: bankTransferBase?.gatewayConfig,
      fixedFee: bankTransferBase?.fixedFee ?? 0,
      percentageFee: bankTransferBase?.percentageFee ?? 0,
      minAmount: bankTransferBase?.minAmount ?? 0,
      maxAmount: bankTransferBase?.maxAmount,
      isActive: account.isActive,
      countries: bankTransferBase?.countries || [],
      platforms: bankTransferBase?.platforms || ['web', 'mobile'],
      sortOrder: account.sortOrder ?? bankTransferBase?.sortOrder ?? 0,
      instructionsAr: account.instructionsAr || bankTransferBase?.instructionsAr || '',
      instructionsEn: account.instructions || bankTransferBase?.instructionsEn || '',
      bankDetails: {
        bankNameAr: account.bankNameAr || '',
        bankNameEn: account.bankName || '',
        accountName: account.accountName || '',
        accountNumber: account.accountNumber || '',
        iban: account.iban || '',
        swiftCode: account.bankCode || '',
      },
      isBankAccount: true,
      bankAccountId: account._id,
    };
  }

  private buildBankAccountPayloadFromPaymentMethod(data: any): any {
    const bankDetails = data.bankDetails || {};
    const bankName =
      bankDetails.bankNameEn ||
      bankDetails.bankNameAr ||
      data.nameEn ||
      data.nameAr ||
      'Bank Transfer';

    const accountNumber = bankDetails.accountNumber?.trim();
    if (!accountNumber) {
      throw new BadRequestException(
        'Account number is required when creating bank transfer account',
      );
    }

    return {
      bankName,
      bankNameAr: bankDetails.bankNameAr || undefined,
      bankCode: bankDetails.swiftCode || undefined,
      accountName: bankDetails.accountName || 'Bank Account',
      accountNameAr: bankDetails.accountName || undefined,
      accountNumber,
      iban: bankDetails.iban || undefined,
      displayName: data.nameEn || bankName,
      displayNameAr: data.nameAr || bankDetails.bankNameAr || bankName,
      logo: data.logo || data.icon || undefined,
      instructions: data.instructionsEn || undefined,
      instructionsAr: data.instructionsAr || undefined,
      isActive: typeof data.isActive === 'boolean' ? data.isActive : true,
      sortOrder: Number.isFinite(data.sortOrder) ? data.sortOrder : 0,
    };
  }

  private async ensureBankTransferBaseMethod(data?: any): Promise<PaymentMethodDocument> {
    const existing = await this.paymentMethodModel.findOne({
      type: PaymentMethodType.BANK_TRANSFER,
    });

    if (existing) {
      return existing;
    }

    return this.paymentMethodModel.create({
      nameAr: data?.nameAr || 'تحويل بنكي',
      nameEn: data?.nameEn || 'Bank Transfer',
      type: PaymentMethodType.BANK_TRANSFER,
      icon: data?.icon || data?.logo || 'bank',
      logo: data?.logo || data?.icon || 'bank',
      gateway: data?.gateway || 'none',
      fixedFee: data?.fixedFee ?? 0,
      percentageFee: data?.percentageFee ?? 0,
      minAmount: data?.minAmount ?? 0,
      maxAmount: data?.maxAmount,
      isActive: typeof data?.isActive === 'boolean' ? data.isActive : true,
      countries: data?.countries || [],
      platforms: data?.platforms || ['web', 'mobile'],
      sortOrder: Number.isFinite(data?.sortOrder) ? data.sortOrder : 6,
      instructionsAr: data?.instructionsAr || '',
      instructionsEn: data?.instructionsEn || '',
      bankDetails: undefined,
    });
  }

  async migrateLegacyBankTransferAccounts(): Promise<void> {
    const bankTransferBase = await this.ensureBankTransferBaseMethod();

    if (this.hasBankDetails((bankTransferBase as any).bankDetails)) {
      const accountNumber = (bankTransferBase as any).bankDetails?.accountNumber?.trim();

      if (accountNumber) {
        const payload = this.buildBankAccountPayloadFromPaymentMethod(bankTransferBase);
        const exists = await this.bankAccountModel.findOne({
          accountNumber: payload.accountNumber,
        });

        if (!exists) {
          await this.bankAccountModel.create(payload);
        }
      }

      await this.paymentMethodModel.findByIdAndUpdate(bankTransferBase._id, {
        nameAr: 'تحويل بنكي',
        nameEn: 'Bank Transfer',
        $unset: { bankDetails: 1 },
      });
    }
  }

  // ==================== Payment Methods ====================

  async createPaymentMethod(
    data: Partial<PaymentMethod> & { name?: string },
  ): Promise<any> {
    await this.migrateLegacyBankTransferAccounts();

    // Convert name to nameEn if provided (for frontend compatibility)
    const createData: any = { ...data };
    if (createData.name && !createData.nameEn) {
      createData.nameEn = createData.name;
      delete createData.name;
    }

    // Keep single image source for admin UI compatibility
    if (createData.logo && !createData.icon) {
      createData.icon = createData.logo;
    } else if (createData.icon && !createData.logo) {
      createData.logo = createData.icon;
    } else if (createData.logo && createData.icon && createData.logo !== createData.icon) {
      createData.icon = createData.logo;
    }

    if (
      createData.type === PaymentMethodType.BANK_TRANSFER &&
      this.hasBankDetails(createData.bankDetails)
    ) {
      const bankTransferBase = await this.ensureBankTransferBaseMethod(createData);
      const accountPayload = this.buildBankAccountPayloadFromPaymentMethod(createData);
      const account = await this.bankAccountModel.create(accountPayload);

      return this.mapBankAccountToPaymentMethod(account, bankTransferBase);
    }

    let method: any = null;

    // Keep type unique: for payment methods, update same type instead of duplicate
    if (createData.type) {
      const existingMethod = await this.paymentMethodModel.findOne({
        type: createData.type,
      });

      if (existingMethod) {
        method = await this.paymentMethodModel.findByIdAndUpdate(
          existingMethod._id,
          {
            ...createData,
            bankDetails:
              createData.type === PaymentMethodType.BANK_TRANSFER
                ? undefined
                : createData.bankDetails,
          },
          { new: true },
        );
      }
    }

    if (!method) {
      method = await this.paymentMethodModel.create({
        ...createData,
        bankDetails:
          createData.type === PaymentMethodType.BANK_TRANSFER
            ? undefined
            : createData.bankDetails,
      });
    }

    return this.mapPaymentMethodResponse(method);
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
    await this.migrateLegacyBankTransferAccounts();

    const methods = await this.paymentMethodModel
      .find()
      .sort({ sortOrder: 1 })
      .exec();

    const bankTransferBase = methods.find(
      (method) => method.type === PaymentMethodType.BANK_TRANSFER,
    );

    const bankAccounts = await this.bankAccountModel
      .find()
      .sort({ sortOrder: 1, createdAt: 1 })
      .exec();

    const methodResponses = methods.map((method) =>
      this.mapPaymentMethodResponse(method),
    );
    const bankAccountResponses = bankAccounts.map((account) =>
      this.mapBankAccountToPaymentMethod(account, bankTransferBase),
    );

    return [...methodResponses, ...bankAccountResponses];
  }

  async getPaymentMethodConfig(
    type: PaymentMethodType,
  ): Promise<PaymentMethod> {
    const method = await this.paymentMethodModel.findOne({ type });
    if (!method) throw new NotFoundException('Payment method not found');
    return method;
  }

  async updatePaymentMethod(
    id: string,
    data: Partial<PaymentMethod> & { name?: string },
    updatedBy?: string,
  ): Promise<any> {
    await this.migrateLegacyBankTransferAccounts();

    // Convert name to nameEn if provided (for frontend compatibility)
    const updateData: any = { ...data };
    if (updateData.name && !updateData.nameEn) {
      updateData.nameEn = updateData.name;
      delete updateData.name;
    }

    if (updateData.logo && !updateData.icon) {
      updateData.icon = updateData.logo;
    } else if (updateData.icon && !updateData.logo) {
      updateData.logo = updateData.icon;
    } else if (updateData.logo && updateData.icon && updateData.logo !== updateData.icon) {
      updateData.icon = updateData.logo;
    }

    const existingMethod = await this.paymentMethodModel.findById(id);

    if (!existingMethod) {
      const bankAccount = await this.bankAccountModel.findById(id);
      if (!bankAccount) {
        throw new NotFoundException('Payment method not found');
      }

      const bankDetails = updateData.bankDetails || {};
      const bankUpdatePayload: any = {
        bankName:
          bankDetails.bankNameEn ||
          bankDetails.bankNameAr ||
          updateData.nameEn ||
          updateData.nameAr ||
          bankAccount.bankName,
        bankNameAr: bankDetails.bankNameAr || updateData.nameAr || bankAccount.bankNameAr,
        bankCode: bankDetails.swiftCode || bankAccount.bankCode,
        accountName: bankDetails.accountName || bankAccount.accountName,
        accountNameAr: bankDetails.accountName || bankAccount.accountNameAr,
        accountNumber: bankDetails.accountNumber || bankAccount.accountNumber,
        iban: bankDetails.iban || bankAccount.iban,
        displayName: updateData.nameEn || bankAccount.displayName,
        displayNameAr:
          updateData.nameAr ||
          bankDetails.bankNameAr ||
          bankAccount.displayNameAr ||
          bankAccount.bankNameAr,
        logo: updateData.logo || updateData.icon || bankAccount.logo,
        instructions: updateData.instructionsEn || bankAccount.instructions,
        instructionsAr: updateData.instructionsAr || bankAccount.instructionsAr,
      };

      if (typeof updateData.isActive === 'boolean') {
        bankUpdatePayload.isActive = updateData.isActive;
      }

      if (Number.isFinite(updateData.sortOrder)) {
        bankUpdatePayload.sortOrder = updateData.sortOrder;
      }

      const updatedAccount = await this.bankAccountModel.findByIdAndUpdate(
        id,
        bankUpdatePayload,
        { new: true },
      );
      if (!updatedAccount) {
        throw new NotFoundException('Payment method not found');
      }

      const bankTransferBase = await this.paymentMethodModel.findOne({
        type: PaymentMethodType.BANK_TRANSFER,
      });

      return this.mapBankAccountToPaymentMethod(updatedAccount, bankTransferBase);
    }

    if (existingMethod.type === PaymentMethodType.BANK_TRANSFER) {
      throw new BadRequestException(
        'Base bank transfer method is protected and cannot be modified',
      );
    }

    const method = await this.paymentMethodModel.findByIdAndUpdate(
      id,
      {
        ...updateData,
        bankDetails: updateData.bankDetails,
        lastUpdatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined,
      },
      { new: true },
    );

    return this.mapPaymentMethodResponse(method);
  }

  async deletePaymentMethod(id: string): Promise<void> {
    const method = await this.paymentMethodModel.findById(id);
    if (method) {
      if (method.type === PaymentMethodType.BANK_TRANSFER) {
        throw new BadRequestException(
          'Base bank transfer method is protected and cannot be deleted',
        );
      }
      await this.paymentMethodModel.findByIdAndDelete(id);
      return;
    }

    const bankAccount = await this.bankAccountModel.findById(id);
    if (bankAccount) {
      await this.bankAccountModel.findByIdAndDelete(id);
      return;
    }

    throw new NotFoundException('Payment method not found');
  }

  // ==================== Seeding ====================

  async seedDefaultSettings(): Promise<void> {
    const count = await this.settingModel.countDocuments();
    if (count > 0) return;

    const settings = [
      // General
      {
        key: 'store_name_ar',
        labelAr: 'اسم المتجر',
        labelEn: 'Store Name',
        value: 'متجر تراس فون',
        type: SettingType.STRING,
        group: SettingGroup.GENERAL,
        isProtected: true,
        sortOrder: 1,
      },
      {
        key: 'store_name_en',
        labelAr: 'اسم المتجر (انجليزي)',
        labelEn: 'Store Name (English)',
        value: 'Tras Phone Store',
        type: SettingType.STRING,
        group: SettingGroup.GENERAL,
        isProtected: true,
        sortOrder: 2,
      },
      {
        key: 'store_email',
        labelAr: 'البريد الإلكتروني',
        labelEn: 'Store Email',
        value: 'info@trasphone.com',
        type: SettingType.EMAIL,
        group: SettingGroup.GENERAL,
        sortOrder: 3,
      },
      {
        key: 'store_phone',
        labelAr: 'رقم الهاتف',
        labelEn: 'Store Phone',
        value: '+966500000000',
        type: SettingType.STRING,
        group: SettingGroup.GENERAL,
        sortOrder: 4,
      },
      {
        key: 'store_address_ar',
        labelAr: 'العنوان',
        labelEn: 'Store Address',
        value: 'الرياض، المملكة العربية السعودية',
        type: SettingType.TEXTAREA,
        group: SettingGroup.GENERAL,
        sortOrder: 5,
      },
      {
        key: 'store_logo',
        labelAr: 'شعار المتجر',
        labelEn: 'Store Logo',
        type: SettingType.IMAGE,
        group: SettingGroup.GENERAL,
        sortOrder: 6,
      },

      // Store settings
      {
        key: 'default_language',
        labelAr: 'اللغة الافتراضية',
        labelEn: 'Default Language',
        value: 'ar',
        type: SettingType.STRING,
        group: SettingGroup.STORE,
        options: ['ar', 'en'],
        sortOrder: 1,
      },
      {
        key: 'timezone',
        labelAr: 'المنطقة الزمنية',
        labelEn: 'Timezone',
        value: 'Asia/Riyadh',
        type: SettingType.STRING,
        group: SettingGroup.STORE,
        sortOrder: 2,
      },
      {
        key: 'maintenance_mode',
        labelAr: 'وضع الصيانة',
        labelEn: 'Maintenance Mode',
        value: false,
        type: SettingType.BOOLEAN,
        group: SettingGroup.STORE,
        sortOrder: 3,
      },

      // Checkout
      {
        key: 'min_order_amount',
        labelAr: 'الحد الأدنى للطلب',
        labelEn: 'Minimum Order Amount',
        value: 50,
        type: SettingType.NUMBER,
        group: SettingGroup.CHECKOUT,
        sortOrder: 1,
      },
      {
        key: 'allow_guest_checkout',
        labelAr: 'السماح بالشراء للزوار',
        labelEn: 'Allow Guest Checkout',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.CHECKOUT,
        sortOrder: 2,
      },
      {
        key: 'stock_check_enabled',
        labelAr: 'التحقق من المخزون',
        labelEn: 'Stock Check Enabled',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.CHECKOUT,
        sortOrder: 3,
      },

      // Inventory
      {
        key: 'low_stock_threshold',
        labelAr: 'حد المخزون المنخفض',
        labelEn: 'Low Stock Threshold',
        value: 10,
        type: SettingType.NUMBER,
        group: SettingGroup.INVENTORY,
        sortOrder: 1,
      },
      {
        key: 'out_of_stock_visibility',
        labelAr: 'إظهار المنتجات غير المتوفرة',
        labelEn: 'Show Out of Stock Products',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.INVENTORY,
        sortOrder: 2,
      },

      // Loyalty
      {
        key: 'loyalty_enabled',
        labelAr: 'تفعيل نقاط الولاء',
        labelEn: 'Loyalty Program Enabled',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.LOYALTY,
        sortOrder: 1,
      },
      {
        key: 'points_per_sar',
        labelAr: 'نقاط لكل ريال',
        labelEn: 'Points per SAR',
        value: 1,
        type: SettingType.NUMBER,
        group: SettingGroup.LOYALTY,
        sortOrder: 2,
      },
      {
        key: 'points_value_in_sar',
        labelAr: 'قيمة النقطة بالريال',
        labelEn: 'Point Value in SAR',
        value: 0.01,
        type: SettingType.NUMBER,
        group: SettingGroup.LOYALTY,
        sortOrder: 3,
      },

      // Social
      {
        key: 'facebook_url',
        labelAr: 'رابط فيسبوك',
        labelEn: 'Facebook URL',
        type: SettingType.URL,
        group: SettingGroup.SOCIAL,
        sortOrder: 1,
      },
      {
        key: 'twitter_url',
        labelAr: 'رابط تويتر',
        labelEn: 'Twitter URL',
        type: SettingType.URL,
        group: SettingGroup.SOCIAL,
        sortOrder: 2,
      },
      {
        key: 'instagram_url',
        labelAr: 'رابط انستغرام',
        labelEn: 'Instagram URL',
        type: SettingType.URL,
        group: SettingGroup.SOCIAL,
        sortOrder: 3,
      },
      {
        key: 'whatsapp_number',
        labelAr: 'رقم واتساب',
        labelEn: 'WhatsApp Number',
        type: SettingType.STRING,
        group: SettingGroup.SOCIAL,
        sortOrder: 4,
      },

      // SEO
      {
        key: 'meta_title_ar',
        labelAr: 'عنوان الميتا',
        labelEn: 'Meta Title',
        type: SettingType.STRING,
        group: SettingGroup.SEO,
        sortOrder: 1,
      },
      {
        key: 'meta_description_ar',
        labelAr: 'وصف الميتا',
        labelEn: 'Meta Description',
        type: SettingType.TEXTAREA,
        group: SettingGroup.SEO,
        sortOrder: 2,
      },
      {
        key: 'google_analytics_id',
        labelAr: 'معرف Google Analytics',
        labelEn: 'Google Analytics ID',
        type: SettingType.STRING,
        group: SettingGroup.SEO,
        sortOrder: 3,
      },

      // Notifications
      {
        key: 'notification_newOrder',
        labelAr: 'إشعار طلب جديد',
        labelEn: 'New Order Notification',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 1,
      },
      {
        key: 'notification_newCustomer',
        labelAr: 'إشعار عميل جديد',
        labelEn: 'New Customer Notification',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 2,
      },
      {
        key: 'notification_lowStock',
        labelAr: 'إشعار مخزون منخفض',
        labelEn: 'Low Stock Notification',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 3,
      },
      {
        key: 'notification_supportTicket',
        labelAr: 'إشعار تذكرة دعم',
        labelEn: 'Support Ticket Notification',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 4,
      },
      {
        key: 'notification_emailEnabled',
        labelAr: 'تفعيل الإشعارات عبر البريد',
        labelEn: 'Email Notifications Enabled',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 5,
      },
      {
        key: 'notification_pushEnabled',
        labelAr: 'تفعيل الإشعارات الفورية',
        labelEn: 'Push Notifications Enabled',
        value: true,
        type: SettingType.BOOLEAN,
        group: SettingGroup.NOTIFICATION,
        sortOrder: 6,
      },
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
        {
          nameAr: 'الرياض',
          nameEn: 'Riyadh',
          shippingFee: 0,
          estimatedDeliveryDays: 1,
        },
        {
          nameAr: 'جدة',
          nameEn: 'Jeddah',
          shippingFee: 0,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'مكة المكرمة',
          nameEn: 'Makkah',
          shippingFee: 15,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'المدينة المنورة',
          nameEn: 'Madinah',
          shippingFee: 15,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'الدمام',
          nameEn: 'Dammam',
          shippingFee: 0,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'الخبر',
          nameEn: 'Khobar',
          shippingFee: 0,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'الظهران',
          nameEn: 'Dhahran',
          shippingFee: 15,
          estimatedDeliveryDays: 2,
        },
        {
          nameAr: 'الطائف',
          nameEn: 'Taif',
          shippingFee: 20,
          estimatedDeliveryDays: 3,
        },
        {
          nameAr: 'تبوك',
          nameEn: 'Tabuk',
          shippingFee: 25,
          estimatedDeliveryDays: 3,
        },
        {
          nameAr: 'أبها',
          nameEn: 'Abha',
          shippingFee: 25,
          estimatedDeliveryDays: 3,
        },
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
        {
          nameAr: 'الدفع عند الاستلام',
          nameEn: 'Cash on Delivery',
          type: PaymentMethodType.CASH_ON_DELIVERY,
          icon: 'cash',
          sortOrder: 1,
        },
        {
          nameAr: 'بطاقة مدى',
          nameEn: 'Mada Card',
          type: PaymentMethodType.MADA,
          icon: 'mada',
          gateway: 'hyperpay',
          sortOrder: 2,
        },
        {
          nameAr: 'بطاقة ائتمان',
          nameEn: 'Credit Card',
          type: PaymentMethodType.CREDIT_CARD,
          icon: 'credit-card',
          gateway: 'hyperpay',
          sortOrder: 3,
        },
        {
          nameAr: 'Apple Pay',
          nameEn: 'Apple Pay',
          type: PaymentMethodType.APPLE_PAY,
          icon: 'apple',
          gateway: 'hyperpay',
          sortOrder: 4,
        },
        {
          nameAr: 'STC Pay',
          nameEn: 'STC Pay',
          type: PaymentMethodType.STC_PAY,
          icon: 'stc',
          gateway: 'hyperpay',
          sortOrder: 5,
        },
        {
          nameAr: 'تحويل بنكي',
          nameEn: 'Bank Transfer',
          type: PaymentMethodType.BANK_TRANSFER,
          icon: 'bank',
          sortOrder: 6,
        },
        {
          nameAr: 'المحفظة',
          nameEn: 'Wallet',
          type: PaymentMethodType.WALLET,
          icon: 'wallet',
          gateway: 'internal',
          sortOrder: 7,
        },
        {
          nameAr: 'الدفع بالآجل',
          nameEn: 'Credit Limit',
          type: PaymentMethodType.CREDIT,
          icon: 'credit-limit',
          gateway: 'internal',
          sortOrder: 8,
        },
      ];
      await this.paymentMethodModel.insertMany(methods);
    }
  }
}
