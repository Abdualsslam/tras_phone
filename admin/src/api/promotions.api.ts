import apiClient from './client';
import type { ApiResponse } from '@/types';

export interface Promotion {
    _id: string;
    name: string;
    nameAr: string;
    code: string;
    description?: string;
    descriptionAr?: string;
    discountType: 'percentage' | 'fixed_amount' | 'buy_x_get_y' | 'free_shipping';
    discountValue?: number;
    maxDiscountAmount?: number;
    buyQuantity?: number;
    getQuantity?: number;
    getDiscountPercentage?: number;
    startDate: string;
    endDate: string;
    minOrderAmount?: number;
    minQuantity?: number;
    scope: 'all' | 'specific_products' | 'specific_categories' | 'specific_brands';
    productIds?: string[];
    categoryIds?: string[];
    brandIds?: string[];
    usageLimit?: number;
    usageLimitPerCustomer?: number;
    usedCount: number;
    image?: string;
    badgeText?: string;
    badgeColor?: string;
    isActive: boolean;
    isAutoApply: boolean;
    priority: number;
    isStackable: boolean;
    createdAt?: string;
    updatedAt?: string;
}

export interface Coupon {
    _id: string;
    code: string;
    type: 'percentage' | 'fixed';
    value: number;
    description?: string;
    startDate: string;
    endDate: string;
    isActive: boolean;
    isPublic: boolean;
    minOrderAmount?: number;
    maxDiscount?: number;
    usageLimit?: number;
    usageCount: number;
    usagePerCustomer?: number;
    applicableProducts?: string[];
    applicableCategories?: string[];
    createdAt: string;
}

export interface CouponStats {
    totalUsage: number;
    totalDiscount: number;
    averageDiscount: number;
    usageByDay: { date: string; count: number }[];
}

export const promotionsApi = {
    // Promotions
    getActivePromotions: async (): Promise<Promotion[]> => {
        const response = await apiClient.get<ApiResponse<Promotion[]>>('/promotions/active');
        return response.data.data;
    },

    getAllPromotions: async (): Promise<Promotion[]> => {
        const response = await apiClient.get<ApiResponse<Promotion[]>>('/promotions');
        return response.data.data;
    },

    getPromotion: async (id: string): Promise<Promotion> => {
        const response = await apiClient.get<ApiResponse<Promotion>>(`/promotions/${id}`);
        return response.data.data;
    },

    createPromotion: async (data: any): Promise<Promotion> => {
        const response = await apiClient.post<ApiResponse<Promotion>>('/promotions', data);
        return response.data.data;
    },

    updatePromotion: async (id: string, data: any): Promise<Promotion> => {
        const response = await apiClient.put<ApiResponse<Promotion>>(`/promotions/${id}`, data);
        return response.data.data;
    },

    deletePromotion: async (id: string): Promise<void> => {
        await apiClient.delete(`/promotions/${id}`);
    },

    // Coupons
    getAllCoupons: async (): Promise<Coupon[]> => {
        const response = await apiClient.get<ApiResponse<Coupon[]>>('/promotions/coupons');
        return response.data.data;
    },

    createCoupon: async (data: any): Promise<Coupon> => {
        const response = await apiClient.post<ApiResponse<Coupon>>('/promotions/coupons', data);
        return response.data.data;
    },

    updateCoupon: async (id: string, data: any): Promise<Coupon> => {
        const response = await apiClient.put<ApiResponse<Coupon>>(`/promotions/coupons/${id}`, data);
        return response.data.data;
    },

    deleteCoupon: async (id: string): Promise<void> => {
        await apiClient.delete(`/promotions/coupons/${id}`);
    },

    getCouponStats: async (id: string): Promise<CouponStats> => {
        const response = await apiClient.get<ApiResponse<CouponStats>>(`/promotions/coupons/${id}/stats`);
        return response.data.data;
    },
};

export default promotionsApi;
