import apiClient from './client';
import type { ApiResponse, Category, Brand } from '@/types';

// Categories
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

export const catalogApi = {
    // Categories
    getCategoryTree: async (): Promise<CategoryTree[]> => {
        const response = await apiClient.get<ApiResponse<CategoryTree[]>>('/catalog/categories/tree');
        return response.data.data;
    },

    getRootCategories: async (): Promise<Category[]> => {
        const response = await apiClient.get<ApiResponse<Category[]>>('/catalog/categories/root');
        return response.data.data;
    },

    getCategoryById: async (id: string): Promise<Category> => {
        const response = await apiClient.get<ApiResponse<Category>>(`/catalog/categories/${id}`);
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

    // Brands
    getBrands: async (featured?: boolean): Promise<Brand[]> => {
        const response = await apiClient.get<ApiResponse<Brand[]>>('/catalog/brands', {
            params: featured !== undefined ? { featured } : undefined
        });
        return response.data.data;
    },

    getBrandBySlug: async (slug: string): Promise<Brand> => {
        const response = await apiClient.get<ApiResponse<Brand>>(`/catalog/brands/${slug}`);
        return response.data.data;
    },

    createBrand: async (data: any): Promise<Brand> => {
        const response = await apiClient.post<ApiResponse<Brand>>('/catalog/brands', data);
        return response.data.data;
    },

    updateBrand: async (id: string, data: any): Promise<Brand> => {
        const response = await apiClient.put<ApiResponse<Brand>>(`/catalog/brands/${id}`, data);
        return response.data.data;
    },

    // Devices
    getPopularDevices: async (limit = 10): Promise<any[]> => {
        const response = await apiClient.get<ApiResponse<any[]>>('/catalog/devices/popular', {
            params: { limit }
        });
        return response.data.data;
    },

    // Quality Types
    getQualityTypes: async (): Promise<QualityType[]> => {
        const response = await apiClient.get<ApiResponse<QualityType[]>>('/catalog/quality-types');
        return response.data.data;
    },
};

export interface QualityType {
    _id: string;
    name: string;
    nameAr: string;
    code: string;
    displayOrder: number;
    isActive: boolean;
}

export default catalogApi;
