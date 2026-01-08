import apiClient from './client';
import type { ApiResponse } from '@/types';

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

export const settingsApi = {
    // General Settings
    getStoreSettings: async (): Promise<StoreSettings> => {
        const response = await apiClient.get<ApiResponse<StoreSettings>>('/settings/store');
        return response.data.data;
    },

    updateStoreSettings: async (data: Partial<StoreSettings>): Promise<StoreSettings> => {
        const response = await apiClient.put<ApiResponse<StoreSettings>>('/settings/store', data);
        return response.data.data;
    },

    // Localization
    getLocalizationSettings: async (): Promise<LocalizationSettings> => {
        const response = await apiClient.get<ApiResponse<LocalizationSettings>>('/settings/localization');
        return response.data.data;
    },

    updateLocalizationSettings: async (data: Partial<LocalizationSettings>): Promise<LocalizationSettings> => {
        const response = await apiClient.put<ApiResponse<LocalizationSettings>>('/settings/localization', data);
        return response.data.data;
    },

    // Notifications
    getNotificationSettings: async (): Promise<NotificationSettings> => {
        const response = await apiClient.get<ApiResponse<NotificationSettings>>('/settings/notifications');
        return response.data.data;
    },

    updateNotificationSettings: async (data: Partial<NotificationSettings>): Promise<NotificationSettings> => {
        const response = await apiClient.put<ApiResponse<NotificationSettings>>('/settings/notifications', data);
        return response.data.data;
    },

    // Payment
    getPaymentSettings: async (): Promise<PaymentSettings> => {
        const response = await apiClient.get<ApiResponse<PaymentSettings>>('/settings/payment');
        return response.data.data;
    },

    updatePaymentSettings: async (data: Partial<PaymentSettings>): Promise<PaymentSettings> => {
        const response = await apiClient.put<ApiResponse<PaymentSettings>>('/settings/payment', data);
        return response.data.data;
    },

    // Shipping
    getShippingSettings: async (): Promise<ShippingSettings> => {
        const response = await apiClient.get<ApiResponse<ShippingSettings>>('/settings/shipping');
        return response.data.data;
    },

    updateShippingSettings: async (data: Partial<ShippingSettings>): Promise<ShippingSettings> => {
        const response = await apiClient.put<ApiResponse<ShippingSettings>>('/settings/shipping', data);
        return response.data.data;
    },
};

export default settingsApi;
