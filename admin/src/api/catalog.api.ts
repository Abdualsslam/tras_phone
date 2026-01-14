import apiClient from './client';
import type { ApiResponse, Category, Brand } from '@/types';

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
// Types
// ══════════════════════════════════════════════════════════════

export interface CategoryTree {
    _id: string;
    name: string;
    nameAr: string;
    slug: string;
    image?: string;
    isActive: boolean;
    productsCount: number;
    children?: CategoryTree[];
}

export interface QualityType {
    _id: string;
    name: string;
    nameAr: string;
    code: string;
    displayOrder: number;
    isActive: boolean;
}

export interface Device {
    _id: string;
    name: string;
    nameAr?: string;
    slug: string;
    brandId: string;
    brand?: Brand;
    image?: string;
    releaseYear?: number;
    isPopular: boolean;
    isActive: boolean;
    createdAt: string;
}

export interface BrandWithDevices extends Brand {
    devicesCount?: number;
    productsCount?: number;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const catalogApi = {
    // ─────────────────────────────────────────
    // Categories
    // ─────────────────────────────────────────

    getCategoryTree: async (): Promise<CategoryTree[]> => {
        const response = await apiClient.get<ApiResponse<CategoryTree[]>>('/catalog/categories/tree');
        return response.data.data;
    },

    getRootCategories: async (): Promise<Category[]> => {
        const response = await apiClient.get<ApiResponse<Category[]>>('/catalog/categories');
        return response.data.data;
    },

    getCategoryById: async (id: string): Promise<{ category: Category; breadcrumb: Category[] }> => {
        const response = await apiClient.get<ApiResponse<{ category: Category; breadcrumb: Category[] }>>(`/catalog/categories/${id}`);
        return response.data.data;
    },

    getCategoryChildren: async (id: string): Promise<Category[]> => {
        const response = await apiClient.get<ApiResponse<Category[]>>(`/catalog/categories/${id}/children`);
        return response.data.data;
    },

    createCategory: async (data: any): Promise<Category> => {
        const response = await apiClient.post<ApiResponse<Category>>('/catalog/categories', data);
        return response.data.data;
    },

    updateCategory: async (id: string, data: any): Promise<Category> => {
        const response = await apiClient.put<ApiResponse<Category>>(`/catalog/categories/${id}`, data);
        return response.data.data;
    },

    deleteCategory: async (id: string): Promise<void> => {
        await apiClient.delete(`/catalog/categories/${id}`);
    },

    // ─────────────────────────────────────────
    // Brands
    // ─────────────────────────────────────────

    getBrands: async (featured?: boolean): Promise<BrandWithDevices[]> => {
        const response = await apiClient.get<ApiResponse<BrandWithDevices[]>>('/catalog/brands', {
            params: featured !== undefined ? { featured } : undefined
        });
        return response.data.data;
    },

    getBrandBySlug: async (slug: string): Promise<Brand> => {
        const response = await apiClient.get<ApiResponse<Brand>>(`/catalog/brands/${slug}`);
        return response.data.data;
    },

    createBrand: async (data: {
        name: string;
        nameAr?: string;
        slug?: string;
        logo?: string;
        isFeatured?: boolean;
        isActive?: boolean;
    }): Promise<Brand> => {
        const response = await apiClient.post<ApiResponse<Brand>>('/catalog/brands', data);
        return response.data.data;
    },

    updateBrand: async (id: string, data: Partial<{
        name: string;
        nameAr?: string;
        slug?: string;
        logo?: string;
        isFeatured?: boolean;
        isActive?: boolean;
    }>): Promise<Brand> => {
        const response = await apiClient.put<ApiResponse<Brand>>(`/catalog/brands/${id}`, data);
        return response.data.data;
    },

    deleteBrand: async (id: string): Promise<void> => {
        await apiClient.delete(`/catalog/brands/${id}`);
    },

    // ─────────────────────────────────────────
    // Devices
    // ─────────────────────────────────────────

    getDevices: async (params?: { brandId?: string; limit?: number }): Promise<Device[]> => {
        const response = await apiClient.get<ApiResponse<Device[]>>('/catalog/devices', { params });
        return extractArrayData<Device>(response.data);
    },

    getPopularDevices: async (limit = 10): Promise<Device[]> => {
        const response = await apiClient.get<ApiResponse<Device[]>>('/catalog/devices', {
            params: { limit }
        });
        return extractArrayData<Device>(response.data);
    },

    getDevicesByBrand: async (brandId: string): Promise<Device[]> => {
        const response = await apiClient.get<ApiResponse<Device[]>>(`/catalog/devices/brand/${brandId}`);
        return extractArrayData<Device>(response.data);
    },

    getDeviceBySlug: async (slug: string): Promise<Device> => {
        const response = await apiClient.get<ApiResponse<Device>>(`/catalog/devices/${slug}`);
        return extractData<Device>(response.data);
    },

    createDevice: async (data: {
        name: string;
        nameAr?: string;
        slug?: string;
        brandId: string;
        image?: string;
        releaseYear?: number;
        isPopular?: boolean;
        isActive?: boolean;
    }): Promise<Device> => {
        const response = await apiClient.post<ApiResponse<Device>>('/catalog/devices', data);
        return extractData<Device>(response.data);
    },

    updateDevice: async (id: string, data: Partial<{
        name: string;
        nameAr?: string;
        slug?: string;
        brandId: string;
        image?: string;
        releaseYear?: number;
        isPopular?: boolean;
        isActive?: boolean;
    }>): Promise<Device> => {
        const response = await apiClient.put<ApiResponse<Device>>(`/catalog/devices/${id}`, data);
        return extractData<Device>(response.data);
    },

    deleteDevice: async (id: string): Promise<void> => {
        await apiClient.delete(`/catalog/devices/${id}`);
    },

    // ─────────────────────────────────────────
    // Quality Types
    // ─────────────────────────────────────────

    getQualityTypes: async (): Promise<QualityType[]> => {
        const response = await apiClient.get<ApiResponse<QualityType[]>>('/catalog/quality-types');
        return extractArrayData<QualityType>(response.data);
    },

    createQualityType: async (data: {
        name: string;
        nameAr?: string;
        code: string;
        displayOrder?: number;
        isActive?: boolean;
        color?: string;
        defaultWarrantyDays?: number;
    }): Promise<QualityType> => {
        const response = await apiClient.post<ApiResponse<QualityType>>('/catalog/quality-types', data);
        return extractData<QualityType>(response.data);
    },

    updateQualityType: async (id: string, data: Partial<{
        name: string;
        nameAr?: string;
        code: string;
        displayOrder?: number;
        isActive?: boolean;
        color?: string;
        defaultWarrantyDays?: number;
    }>): Promise<QualityType> => {
        const response = await apiClient.put<ApiResponse<QualityType>>(`/catalog/quality-types/${id}`, data);
        return extractData<QualityType>(response.data);
    },

    deleteQualityType: async (id: string): Promise<void> => {
        await apiClient.delete(`/catalog/quality-types/${id}`);
    },
};

export default catalogApi;
