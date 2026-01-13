import apiClient from './client';
import type { ApiResponse } from '@/types';

// Helper function to extract data from nested API response
// API returns: { data: { data: actualData } } or { data: actualData }
function extractData<T>(responseData: any): T {
    // Check if data is nested (response.data.data structure from backend)
    if (responseData && typeof responseData === 'object' && 'data' in responseData) {
        return responseData.data as T;
    }
    return responseData as T;
}

// Helper function to extract array data safely
function extractArrayData<T>(responseData: any): T[] {
    const data = extractData<T[] | T>(responseData);
    return Array.isArray(data) ? data : [];
}

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
        return extractData<StoreSettings>(response.data.data);
    },

    updateStoreSettings: async (data: Partial<StoreSettings>): Promise<StoreSettings> => {
        const response = await apiClient.put<ApiResponse<StoreSettings>>('/settings/store', data);
        return extractData<StoreSettings>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Localization
    // ─────────────────────────────────────────

    getLocalizationSettings: async (): Promise<LocalizationSettings> => {
        const response = await apiClient.get<ApiResponse<LocalizationSettings>>('/settings/localization');
        return extractData<LocalizationSettings>(response.data.data);
    },

    updateLocalizationSettings: async (data: Partial<LocalizationSettings>): Promise<LocalizationSettings> => {
        const response = await apiClient.put<ApiResponse<LocalizationSettings>>('/settings/localization', data);
        return extractData<LocalizationSettings>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Notifications
    // ─────────────────────────────────────────

    getNotificationSettings: async (): Promise<NotificationSettings> => {
        const response = await apiClient.get<ApiResponse<NotificationSettings>>('/settings/notifications');
        return extractData<NotificationSettings>(response.data.data);
    },

    updateNotificationSettings: async (data: Partial<NotificationSettings>): Promise<NotificationSettings> => {
        const response = await apiClient.put<ApiResponse<NotificationSettings>>('/settings/notifications', data);
        return extractData<NotificationSettings>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Payment
    // ─────────────────────────────────────────

    getPaymentSettings: async (): Promise<PaymentSettings> => {
        const response = await apiClient.get<ApiResponse<PaymentSettings>>('/settings/payment');
        return extractData<PaymentSettings>(response.data.data);
    },

    updatePaymentSettings: async (data: Partial<PaymentSettings>): Promise<PaymentSettings> => {
        const response = await apiClient.put<ApiResponse<PaymentSettings>>('/settings/payment', data);
        return extractData<PaymentSettings>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Shipping
    // ─────────────────────────────────────────

    getShippingSettings: async (): Promise<ShippingSettings> => {
        const response = await apiClient.get<ApiResponse<ShippingSettings>>('/settings/shipping');
        return extractData<ShippingSettings>(response.data.data);
    },

    updateShippingSettings: async (data: Partial<ShippingSettings>): Promise<ShippingSettings> => {
        const response = await apiClient.put<ApiResponse<ShippingSettings>>('/settings/shipping', data);
        return extractData<ShippingSettings>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Countries
    // ─────────────────────────────────────────

    getCountries: async (): Promise<Country[]> => {
        const response = await apiClient.get<ApiResponse<Country[]>>('/settings/admin/countries');
        return extractArrayData<Country>(response.data.data);
    },

    createCountry: async (data: Omit<Country, '_id'>): Promise<Country> => {
        const response = await apiClient.post<ApiResponse<Country>>('/settings/admin/countries', data);
        return extractData<Country>(response.data.data);
    },

    updateCountry: async (id: string, data: Partial<Country>): Promise<Country> => {
        const response = await apiClient.put<ApiResponse<Country>>(`/settings/admin/countries/${id}`, data);
        return extractData<Country>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Cities
    // ─────────────────────────────────────────

    getCities: async (countryId?: string): Promise<City[]> => {
        const response = await apiClient.get<ApiResponse<City[]>>('/settings/admin/cities', {
            params: countryId ? { countryId } : undefined,
        });
        return extractArrayData<City>(response.data.data);
    },

    createCity: async (data: Omit<City, '_id'>): Promise<City> => {
        const response = await apiClient.post<ApiResponse<City>>('/settings/admin/cities', data);
        return extractData<City>(response.data.data);
    },

    updateCity: async (id: string, data: Partial<City>): Promise<City> => {
        const response = await apiClient.put<ApiResponse<City>>(`/settings/admin/cities/${id}`, data);
        return extractData<City>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Currencies
    // ─────────────────────────────────────────

    getCurrencies: async (): Promise<Currency[]> => {
        const response = await apiClient.get<ApiResponse<Currency[]>>('/settings/admin/currencies');
        return extractArrayData<Currency>(response.data.data);
    },

    createCurrency: async (data: Omit<Currency, '_id'>): Promise<Currency> => {
        const response = await apiClient.post<ApiResponse<Currency>>('/settings/admin/currencies', data);
        return extractData<Currency>(response.data.data);
    },

    updateCurrency: async (id: string, data: Partial<Currency>): Promise<Currency> => {
        const response = await apiClient.put<ApiResponse<Currency>>(`/settings/admin/currencies/${id}`, data);
        return extractData<Currency>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Tax Rates
    // ─────────────────────────────────────────

    getTaxRates: async (): Promise<TaxRate[]> => {
        const response = await apiClient.get<ApiResponse<TaxRate[]>>('/settings/admin/tax-rates');
        return extractArrayData<TaxRate>(response.data.data);
    },

    createTaxRate: async (data: Omit<TaxRate, '_id'>): Promise<TaxRate> => {
        const response = await apiClient.post<ApiResponse<TaxRate>>('/settings/admin/tax-rates', data);
        return extractData<TaxRate>(response.data.data);
    },

    updateTaxRate: async (id: string, data: Partial<TaxRate>): Promise<TaxRate> => {
        const response = await apiClient.put<ApiResponse<TaxRate>>(`/settings/admin/tax-rates/${id}`, data);
        return extractData<TaxRate>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Shipping Zones
    // ─────────────────────────────────────────

    getShippingZones: async (): Promise<ShippingZone[]> => {
        const response = await apiClient.get<ApiResponse<ShippingZone[]>>('/settings/admin/shipping-zones');
        return extractArrayData<ShippingZone>(response.data.data);
    },

    createShippingZone: async (data: Omit<ShippingZone, '_id'>): Promise<ShippingZone> => {
        const response = await apiClient.post<ApiResponse<ShippingZone>>('/settings/admin/shipping-zones', data);
        return extractData<ShippingZone>(response.data.data);
    },

    updateShippingZone: async (id: string, data: Partial<ShippingZone>): Promise<ShippingZone> => {
        const response = await apiClient.put<ApiResponse<ShippingZone>>(`/settings/admin/shipping-zones/${id}`, data);
        return extractData<ShippingZone>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Payment Methods
    // ─────────────────────────────────────────

    getPaymentMethods: async (): Promise<PaymentMethod[]> => {
        const response = await apiClient.get<ApiResponse<PaymentMethod[]>>('/settings/admin/payment-methods');
        return extractArrayData<PaymentMethod>(response.data.data);
    },

    createPaymentMethod: async (data: Omit<PaymentMethod, '_id'>): Promise<PaymentMethod> => {
        const response = await apiClient.post<ApiResponse<PaymentMethod>>('/settings/admin/payment-methods', data);
        return extractData<PaymentMethod>(response.data.data);
    },

    updatePaymentMethod: async (id: string, data: Partial<PaymentMethod>): Promise<PaymentMethod> => {
        const response = await apiClient.put<ApiResponse<PaymentMethod>>(`/settings/admin/payment-methods/${id}`, data);
        return extractData<PaymentMethod>(response.data.data);
    },

    // ─────────────────────────────────────────
    // App Versions
    // ─────────────────────────────────────────

    getAppVersions: async (platform?: 'ios' | 'android'): Promise<AppVersion[]> => {
        const response = await apiClient.get<ApiResponse<AppVersion[]>>('/settings/app-versions', {
            params: platform ? { platform } : undefined,
        });
        return extractArrayData<AppVersion>(response.data.data);
    },

    createAppVersion: async (data: Omit<AppVersion, '_id' | 'createdAt'>): Promise<AppVersion> => {
        const response = await apiClient.post<ApiResponse<AppVersion>>('/settings/admin/app-versions', data);
        return extractData<AppVersion>(response.data.data);
    },

    updateAppVersion: async (id: string, data: Partial<AppVersion>): Promise<AppVersion> => {
        const response = await apiClient.put<ApiResponse<AppVersion>>(`/settings/admin/app-versions/${id}`, data);
        return extractData<AppVersion>(response.data.data);
    },

    setCurrentAppVersion: async (id: string): Promise<AppVersion> => {
        const response = await apiClient.put<ApiResponse<AppVersion>>(`/settings/admin/app-versions/${id}/current`);
        return extractData<AppVersion>(response.data.data);
    },

    deleteAppVersion: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/app-versions/${id}`);
    },

    // ─────────────────────────────────────────
    // Admin Cities
    // ─────────────────────────────────────────

    getAdminCities: async (countryId?: string): Promise<City[]> => {
        const response = await apiClient.get<ApiResponse<City[]>>('/settings/admin/cities', {
            params: countryId ? { countryId } : undefined,
        });
        return extractArrayData<City>(response.data.data);
    },

    deleteCity: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/cities/${id}`);
    },

    deleteCountry: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/countries/${id}`);
    },

    deleteCurrency: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/currencies/${id}`);
    },

    deleteTaxRate: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/tax-rates/${id}`);
    },

    deleteShippingZone: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/shipping-zones/${id}`);
    },

    deletePaymentMethod: async (id: string): Promise<void> => {
        await apiClient.delete(`/settings/admin/payment-methods/${id}`);
    },
};

export interface AppVersion {
    _id: string;
    platform: 'ios' | 'android';
    version: string;
    buildNumber: number;
    minRequiredVersion?: string;
    releaseNotes?: string;
    releaseNotesAr?: string;
    downloadUrl?: string;
    isCurrent: boolean;
    isForceUpdate: boolean;
    isActive: boolean;
    createdAt: string;
}

export default settingsApi;

