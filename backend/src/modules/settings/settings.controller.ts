import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SettingsService } from './settings.service';
import { AppVersionService } from './app-version.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { SettingGroup } from './schemas/setting.schema';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { UserRole } from '../../common/enums/user-role.enum';

@ApiTags('Settings')
@Controller('settings')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class SettingsController {
  constructor(
    private readonly settingsService: SettingsService,
    private readonly appVersionService: AppVersionService,
  ) {}

  // ==================== Public Settings ====================

  @Get('public')
  @Public()
  @ApiOperation({ summary: 'Get public settings' })
  async getPublicSettings() {
    const settings = await this.settingsService.getPublicSettings();
    return ResponseBuilder.success(settings);
  }

  // ==================== Store Settings ====================

  @Get('store')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get store settings' })
  async getStoreSettings() {
    const settings = await this.settingsService.getStoreSettings();
    return ResponseBuilder.success(settings);
  }

  @Put('store')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update store settings' })
  async updateStoreSettings(@CurrentUser() user: any, @Body() data: any) {
    const settings = await this.settingsService.updateStoreSettings(
      data,
      user.adminId,
    );
    return ResponseBuilder.success(settings, 'Store settings updated');
  }

  // ==================== Countries & Cities ====================

  @Get('countries')
  @Public()
  @ApiOperation({ summary: 'Get all countries' })
  async getCountries() {
    const countries = await this.settingsService.findAllCountries();
    return ResponseBuilder.success(countries);
  }

  @Get('countries/shipping')
  @Public()
  @ApiOperation({ summary: 'Get shipping countries' })
  async getShippingCountries() {
    const countries = await this.settingsService.findShippingCountries();
    return ResponseBuilder.success(countries);
  }

  @Get('countries/:countryId/cities')
  @Public()
  @ApiOperation({ summary: 'Get cities by country' })
  async getCities(@Param('countryId') countryId: string) {
    const cities = await this.settingsService.findCitiesByCountry(countryId);
    return ResponseBuilder.success(cities);
  }

  @Get('countries/:countryId/cities/delivery')
  @Public()
  @ApiOperation({ summary: 'Get delivery cities by country' })
  async getDeliveryCities(@Param('countryId') countryId: string) {
    const cities = await this.settingsService.findDeliveryCities(countryId);
    return ResponseBuilder.success(cities);
  }

  // ==================== Currencies ====================

  @Get('currencies')
  @Public()
  @ApiOperation({ summary: 'Get all currencies' })
  async getCurrencies() {
    const currencies = await this.settingsService.findAllCurrencies();
    return ResponseBuilder.success(currencies);
  }

  @Get('currencies/default')
  @Public()
  @ApiOperation({ summary: 'Get default currency' })
  async getDefaultCurrency() {
    const currency = await this.settingsService.getDefaultCurrency();
    return ResponseBuilder.success(currency);
  }

  // ==================== Tax Rates ====================

  @Get('tax-rates')
  @Public()
  @ApiOperation({ summary: 'Get all tax rates' })
  async getTaxRates() {
    const rates = await this.settingsService.findAllTaxRates();
    return ResponseBuilder.success(rates);
  }

  @Post('calculate-tax')
  @Public()
  @ApiOperation({ summary: 'Calculate tax for amount' })
  async calculateTax(
    @Body() data: { amount: number; countryId?: string; categoryId?: string },
  ) {
    const tax = await this.settingsService.calculateTax(
      data.amount,
      data.countryId,
      data.categoryId,
    );
    return ResponseBuilder.success({ tax, total: data.amount + tax });
  }

  // ==================== Shipping ====================

  @Get('shipping-zones')
  @Public()
  @ApiOperation({ summary: 'Get shipping zones' })
  async getShippingZones() {
    const zones = await this.settingsService.findAllShippingZones();
    return ResponseBuilder.success(zones);
  }

  @Post('calculate-shipping')
  @Public()
  @ApiOperation({ summary: 'Calculate shipping for city' })
  async calculateShipping(
    @Body() data: { cityId: string; weight: number; orderAmount: number },
  ) {
    const rates = await this.settingsService.calculateShipping(
      data.cityId,
      data.weight,
      data.orderAmount,
    );
    return ResponseBuilder.success(rates);
  }

  // ==================== Payment Methods ====================

  @Get('payment-methods')
  @Public()
  @ApiOperation({ summary: 'Get active payment methods' })
  async getPaymentMethods(@Query('platform') platform?: string) {
    const methods =
      await this.settingsService.findActivePaymentMethods(platform);
    // Return raw array so TransformInterceptor wraps once as { data: methods }.
    // ResponseBuilder.success() here would double-wrap; mobile expects data = array.
    return methods as any;
  }

  // ==================== Notification Settings ====================

  @Get('notifications')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get notification settings' })
  async getNotificationSettings() {
    const settings = await this.settingsService.getNotificationSettings();
    return ResponseBuilder.success(settings);
  }

  @Put('notifications')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update notification settings' })
  async updateNotificationSettings(@Body() data: any) {
    const settings =
      await this.settingsService.updateNotificationSettings(data);
    return ResponseBuilder.success(settings, 'Notification settings updated');
  }

  // ==================== Admin - Settings ====================

  @Get('admin')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all settings (admin)' })
  async getAllSettings(@Query('group') group?: SettingGroup) {
    const settings = await this.settingsService.getSettings(group);
    return ResponseBuilder.success(settings);
  }

  @Put('admin/:key')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update setting' })
  async updateSetting(
    @CurrentUser() user: any,
    @Param('key') key: string,
    @Body() data: { value: any },
  ) {
    const setting = await this.settingsService.updateSetting(
      key,
      data.value,
      user.adminId,
    );
    return ResponseBuilder.success(setting, 'Setting updated');
  }

  @Put('admin/batch')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update multiple settings' })
  async updateMultipleSettings(
    @CurrentUser() user: any,
    @Body() data: { settings: { key: string; value: any }[] },
  ) {
    await this.settingsService.updateMultipleSettings(
      data.settings,
      user.adminId,
    );
    return ResponseBuilder.success(null, 'Settings updated');
  }

  // ==================== Admin - Countries ====================

  @Get('admin/countries')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all countries (admin)' })
  async getAllCountries() {
    const countries = await this.settingsService.findAllCountries(false);
    return ResponseBuilder.success(countries);
  }

  @Post('admin/countries')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create country' })
  async createCountry(@Body() data: any) {
    const country = await this.settingsService.createCountry(data);
    return ResponseBuilder.success(country, 'Country created');
  }

  @Put('admin/countries/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update country' })
  async updateCountry(@Param('id') id: string, @Body() data: any) {
    const country = await this.settingsService.updateCountry(id, data);
    return ResponseBuilder.success(country, 'Country updated');
  }

  // ==================== Admin - Cities ====================

  @Get('admin/cities')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all cities (admin)' })
  async getAllCities(@Query('countryId') countryId?: string) {
    const cities = await this.settingsService.findAllCities(countryId, false);
    return ResponseBuilder.success(cities);
  }

  @Post('admin/cities')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create city' })
  async createCity(@Body() data: any) {
    const city = await this.settingsService.createCity(data);
    return ResponseBuilder.success(city, 'City created');
  }

  @Put('admin/cities/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update city' })
  async updateCity(@Param('id') id: string, @Body() data: any) {
    const city = await this.settingsService.updateCity(id, data);
    return ResponseBuilder.success(city, 'City updated');
  }

  // ==================== Admin - Currencies ====================

  @Get('admin/currencies')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all currencies (admin)' })
  async getAllCurrencies() {
    const currencies = await this.settingsService.findAllCurrencies(false);
    return ResponseBuilder.success(currencies);
  }

  @Post('admin/currencies')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create currency' })
  async createCurrency(@Body() data: any) {
    const currency = await this.settingsService.createCurrency(data);
    return ResponseBuilder.success(currency, 'Currency created');
  }

  @Put('admin/currencies/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update currency' })
  async updateCurrency(@Param('id') id: string, @Body() data: any) {
    const currency = await this.settingsService.updateCurrency(id, data);
    return ResponseBuilder.success(currency, 'Currency updated');
  }

  // ==================== Admin - Tax Rates ====================

  @Get('admin/tax-rates')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all tax rates (admin)' })
  async getAllTaxRates() {
    const rates = await this.settingsService.findAllTaxRates(false);
    return ResponseBuilder.success(rates);
  }

  @Post('admin/tax-rates')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create tax rate' })
  async createTaxRate(@CurrentUser() user: any, @Body() data: any) {
    const rate = await this.settingsService.createTaxRate(data, user.adminId);
    return ResponseBuilder.success(rate, 'Tax rate created');
  }

  @Put('admin/tax-rates/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update tax rate' })
  async updateTaxRate(@Param('id') id: string, @Body() data: any) {
    const rate = await this.settingsService.updateTaxRate(id, data);
    return ResponseBuilder.success(rate, 'Tax rate updated');
  }

  // ==================== Admin - Shipping Zones ====================

  @Get('admin/shipping-zones')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all shipping zones (admin)' })
  async getAllShippingZones() {
    const zones = await this.settingsService.findAllShippingZones(false);
    return ResponseBuilder.success(zones);
  }

  @Post('admin/shipping-zones')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create shipping zone' })
  async createShippingZone(@CurrentUser() user: any, @Body() data: any) {
    const zone = await this.settingsService.createShippingZone(
      data,
      user.adminId,
    );
    return ResponseBuilder.success(zone, 'Shipping zone created');
  }

  @Put('admin/shipping-zones/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update shipping zone' })
  async updateShippingZone(@Param('id') id: string, @Body() data: any) {
    const zone = await this.settingsService.updateShippingZone(id, data);
    return ResponseBuilder.success(zone, 'Shipping zone updated');
  }

  // ==================== Admin - Payment Methods ====================

  @Get('admin/payment-methods')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all payment methods (admin)' })
  async getAllPaymentMethods() {
    const methods = await this.settingsService.findAllPaymentMethods();
    return ResponseBuilder.success(methods);
  }

  @Post('admin/payment-methods')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create payment method' })
  async createPaymentMethod(@Body() data: any) {
    const method = await this.settingsService.createPaymentMethod(data);
    return ResponseBuilder.success(method, 'Payment method created');
  }

  @Put('admin/payment-methods/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update payment method' })
  async updatePaymentMethod(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() data: any,
  ) {
    const method = await this.settingsService.updatePaymentMethod(
      id,
      data,
      user.adminId,
    );
    return ResponseBuilder.success(method, 'Payment method updated');
  }

  @Delete('admin/payment-methods/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete payment method' })
  async deletePaymentMethod(@Param('id') id: string) {
    await this.settingsService.deletePaymentMethod(id);
    return ResponseBuilder.success(null, 'Payment method deleted');
  }

  // ==================== App Versions ====================

  @Get('app-versions')
  @Public()
  @ApiOperation({ summary: 'Get all app versions' })
  async getAppVersions(@Query('platform') platform?: 'ios' | 'android') {
    const versions = await this.appVersionService.findAll(platform);
    return ResponseBuilder.success(versions);
  }

  @Get('app-versions/current/:platform')
  @Public()
  @ApiOperation({ summary: 'Get current app version' })
  async getCurrentAppVersion(@Param('platform') platform: 'ios' | 'android') {
    const version = await this.appVersionService.getCurrentVersion(platform);
    return ResponseBuilder.success(version);
  }

  @Post('app-versions/check')
  @Public()
  @ApiOperation({ summary: 'Check app version' })
  async checkAppVersion(
    @Body() data: { platform: 'ios' | 'android'; currentVersion: string },
  ) {
    const result = await this.appVersionService.checkVersion(
      data.platform,
      data.currentVersion,
    );
    return ResponseBuilder.success(result);
  }

  @Post('admin/app-versions')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create app version' })
  async createAppVersion(@CurrentUser() user: any, @Body() data: any) {
    const version = await this.appVersionService.create(data, user.adminId);
    return ResponseBuilder.success(version, 'App version created');
  }

  @Put('admin/app-versions/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update app version' })
  async updateAppVersion(@Param('id') id: string, @Body() data: any) {
    const version = await this.appVersionService.update(id, data);
    return ResponseBuilder.success(version, 'App version updated');
  }

  @Put('admin/app-versions/:id/current')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Set as current version' })
  async setCurrentVersion(@Param('id') id: string) {
    const version = await this.appVersionService.setCurrent(id);
    return ResponseBuilder.success(version, 'Set as current version');
  }

  @Delete('admin/app-versions/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete app version' })
  async deleteAppVersion(@Param('id') id: string) {
    await this.appVersionService.delete(id);
    return ResponseBuilder.success(null, 'App version deleted');
  }
}
