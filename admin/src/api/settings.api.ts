import apiClient from './client';
import type { ApiResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Basic Settings Types
// ══════════════════════════════════════════════════════════════

export interface StoreSettings {
    storeName: string;
    storeEmail: string;
    storePhone: string;
    storeAddress: string;
    storeDescription: string;
    logo?: string;
    favicon?: string;
}

export interface LocalizationSettings {
    defaultLanguage: 'ar' | 'en';
    defaultCurrency: string;
    timezone: string;
    dateFormat: string;
}

export interface NotificationSettings {
    newOrder: boolean;
    newCustomer: boolean;
    lowStock: boolean;
    supportTicket: boolean;
    emailEnabled: boolean;
    pushEnabled: boolean;
}

export interface PaymentSettings {
    enabledMethods: string[];
    defaultMethod: string;
    taxRate: number;
    enableTax: boolean;
}

export interface ShippingSettings {
    enabledCarriers: string[];
    defaultCarrier: string;
    freeShippingThreshold: number;
}

// ══════════════════════════════════════════════════════════════
// Extended Settings Types
// ══════════════════════════════════════════════════════════════

export interface Country {
    _id: string;
    name: string;
    nameAr?: string;
    code: string;
    phoneCode?: string;
    isActive: boolean;
}

export interface City {
    _id: string;
    name: string;
    nameAr?: string;
    countryId: string;
    isActive: boolean;
}

export interface Currency {
    _id: string;
    name: string;
    nameAr?: string;
    code: string;
    symbol: string;
    exchangeRate: number;
    isDefault: boolean;
    isActive: boolean;
}

export interface TaxRate {
    _id: string;
    name: string;
    nameAr?: string;
    rate: number;
    countryId?: string;
    isDefault: boolean;
    isActive: boolean;
}

export interface ShippingZone {
    _id: string;
    name: string;
    nameAr?: string;
    countries: string[];
    rates: { minWeight: number; maxWeight: number; price: number }[];
    isActive: boolean;
}

export interface PaymentMethod {
    _id: string;
    name: string;
    nameAr?: string;
    code: string;
    type: 'online' | 'offline' | 'wallet';
    settings?: Record<string, any>;
    isActive: boolean;
}

// ══════════════════════════════════════════════════════════════
// Settings API
// ══════════════════════════════════════════════════════════════

export const settingsApi = {
    // ─────────────────────────────────────────
    // General Settings
    // ─────────────────────────────────────────

    getStoreSettings: async (): Promise<StoreSettings> => {
        const response = await apiClient.get<ApiResponse<StoreSettings>>('/settings/store');
        return response.data.data;
    },

    updateStoreSettings: async (data: Partial<StoreSettings>): Promise<StoreSettings> => {
        const response = await apiClient.put<ApiResponse<StoreSettings>>('/settings/store', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Localization
    // ─────────────────────────────────────────

    getLocalizationSettings: async (): Promise<LocalizationSettings> => {
        const response = await apiClient.get<ApiResponse<LocalizationSettings>>('/settings/localization');
        return response.data.data;
    },

    updateLocalizationSettings: async (data: Partial<LocalizationSettings>): Promise<LocalizationSettings> => {
        const response = await apiClient.put<ApiResponse<LocalizationSettings>>('/settings/localization', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Notifications
    // ─────────────────────────────────────────

    getNotificationSettings: async (): Promise<NotificationSettings> => {
        const response = await apiClient.get<ApiResponse<NotificationSettings>>('/settings/notifications');
        return response.data.data;
    },

    updateNotificationSettings: async (data: Partial<NotificationSettings>): Promise<NotificationSettings> => {
        const response = await apiClient.put<ApiResponse<NotificationSettings>>('/settings/notifications', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Payment
    // ─────────────────────────────────────────

    getPaymentSettings: async (): Promise<PaymentSettings> => {
        const response = await apiClient.get<ApiResponse<PaymentSettings>>('/settings/payment');
        return response.data.data;
    },

    updatePaymentSettings: async (data: Partial<PaymentSettings>): Promise<PaymentSettings> => {
        const response = await apiClient.put<ApiResponse<PaymentSettings>>('/settings/payment', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Shipping
    // ─────────────────────────────────────────

    getShippingSettings: async (): Promise<ShippingSettings> => {
        const response = await apiClient.get<ApiResponse<ShippingSettings>>('/settings/shipping');
        return response.data.data;
    },

    updateShippingSettings: async (data: Partial<ShippingSettings>): Promise<ShippingSettings> => {
        const response = await apiClient.put<ApiResponse<ShippingSettings>>('/settings/shipping', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Countries
    // ─────────────────────────────────────────

    getCountries: async (): Promise<Country[]> => {
        const response = await apiClient.get<ApiResponse<Country[]>>('/settings/admin/countries');
        return response.data.data;
    },

    createCountry: async (data: Omit<Country, '_id'>): Promise<Country> => {
        const response = await apiClient.post<ApiResponse<Country>>('/settings/admin/countries', data);
        return response.data.data;
    },

    updateCountry: async (id: string, data: Partial<Country>): Promise<Country> => {
        const response = await apiClient.put<ApiResponse<Country>>(`/settings/admin/countries/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Cities
    // ─────────────────────────────────────────

    getCities: async (countryId?: string): Promise<City[]> => {
        const response = await apiClient.get<ApiResponse<City[]>>('/settings/admin/cities', {
            params: countryId ? { countryId } : undefined,
        });
        return response.data.data;
    },

    createCity: async (data: Omit<City, '_id'>): Promise<City> => {
        const response = await apiClient.post<ApiResponse<City>>('/settings/admin/cities', data);
        return response.data.data;
    },

    updateCity: async (id: string, data: Partial<City>): Promise<City> => {
        const response = await apiClient.put<ApiResponse<City>>(`/settings/admin/cities/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Currencies
    // ─────────────────────────────────────────

    getCurrencies: async (): Promise<Currency[]> => {
        const response = await apiClient.get<ApiResponse<Currency[]>>('/settings/admin/currencies');
        return response.data.data;
    },

    createCurrency: async (data: Omit<Currency, '_id'>): Promise<Currency> => {
        const response = await apiClient.post<ApiResponse<Currency>>('/settings/admin/currencies', data);
        return response.data.data;
    },

    updateCurrency: async (id: string, data: Partial<Currency>): Promise<Currency> => {
        const response = await apiClient.put<ApiResponse<Currency>>(`/settings/admin/currencies/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Tax Rates
    // ─────────────────────────────────────────

    getTaxRates: async (): Promise<TaxRate[]> => {
        const response = await apiClient.get<ApiResponse<TaxRate[]>>('/settings/admin/tax-rates');
        return response.data.data;
    },

    createTaxRate: async (data: Omit<TaxRate, '_id'>): Promise<TaxRate> => {
        const response = await apiClient.post<ApiResponse<TaxRate>>('/settings/admin/tax-rates', data);
        return response.data.data;
    },

    updateTaxRate: async (id: string, data: Partial<TaxRate>): Promise<TaxRate> => {
        const response = await apiClient.put<ApiResponse<TaxRate>>(`/settings/admin/tax-rates/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Shipping Zones
    // ─────────────────────────────────────────

    getShippingZones: async (): Promise<ShippingZone[]> => {
        const response = await apiClient.get<ApiResponse<ShippingZone[]>>('/settings/admin/shipping-zones');
        return response.data.data;
    },

    createShippingZone: async (data: Omit<ShippingZone, '_id'>): Promise<ShippingZone> => {
        const response = await apiClient.post<ApiResponse<ShippingZone>>('/settings/admin/shipping-zones', data);
        return response.data.data;
    },

    updateShippingZone: async (id: string, data: Partial<ShippingZone>): Promise<ShippingZone> => {
        const response = await apiClient.put<ApiResponse<ShippingZone>>(`/settings/admin/shipping-zones/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Payment Methods
    // ─────────────────────────────────────────

    getPaymentMethods: async (): Promise<PaymentMethod[]> => {
        const response = await apiClient.get<ApiResponse<PaymentMethod[]>>('/settings/admin/payment-methods');
        return response.data.data;
    },

    createPaymentMethod: async (data: Omit<PaymentMethod, '_id'>): Promise<PaymentMethod> => {
        const response = await apiClient.post<ApiResponse<PaymentMethod>>('/settings/admin/payment-methods', data);
        return response.data.data;
    },

    updatePaymentMethod: async (id: string, data: Partial<PaymentMethod>): Promise<PaymentMethod> => {
        const response = await apiClient.put<ApiResponse<PaymentMethod>>(`/settings/admin/payment-methods/${id}`, data);
        return response.data.data;
    },
};

export default settingsApi;

