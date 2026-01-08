import apiClient from './client';
import type { ApiResponse, Product, PaginatedResponse } from '@/types';

export interface CreateProductDto {
    // Required fields
    sku: string;
    name: string;
    nameAr: string;
    slug: string;
    brandId: string;
    categoryId: string;
    qualityTypeId: string;
    basePrice: number;

    // Optional fields
    description?: string;
    descriptionAr?: string;
    shortDescription?: string;
    shortDescriptionAr?: string;
    additionalCategories?: string[];
    compatibleDevices?: string[];
    compareAtPrice?: number;
    costPrice?: number;
    stockQuantity?: number;
    lowStockThreshold?: number;
    trackInventory?: boolean;
    allowBackorder?: boolean;
    minOrderQuantity?: number;
    maxOrderQuantity?: number;
    status?: 'draft' | 'active' | 'inactive' | 'out_of_stock' | 'discontinued';
    isActive?: boolean;
    isFeatured?: boolean;
    mainImage?: string;
    images?: string[];
    specifications?: Record<string, any>;
    weight?: number;
    dimensions?: string;
    color?: string;
    tags?: string[];
}

export interface UpdateProductDto extends Partial<CreateProductDto> { }

export interface ProductsQueryParams {
    page?: number;
    limit?: number;
    search?: string;
    categoryId?: string;
    brandId?: string;
    status?: string;
}

export const productsApi = {
    getAll: async (params?: ProductsQueryParams): Promise<PaginatedResponse<Product>> => {
        const response = await apiClient.get<ApiResponse<any[]>>('/products', { params });

        // Transform backend response to expected format
        const rawProducts = response.data.data || [];
        const meta = (response.data as any).meta || {};

        // Map backend fields to frontend expected fields
        const products: Product[] = rawProducts.map((p: any) => ({
            _id: p._id || p.id,
            name: p.name,
            nameAr: p.nameAr,
            sku: p.sku,
            description: p.description,
            descriptionAr: p.descriptionAr,
            category: p.categoryId,
            brand: p.brandId,
            images: p.images || [],
            price: p.basePrice || 0,
            compareAtPrice: p.compareAtPrice,
            stock: p.stockQuantity || 0,
            status: p.status || 'draft',
            featured: p.isFeatured || false,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
        }));

        return {
            items: products,
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || products.length,
                totalPages: meta.pages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    getById: async (id: string): Promise<Product> => {
        const response = await apiClient.get<ApiResponse<Product>>(`/products/${id}`);
        return response.data.data;
    },

    create: async (data: CreateProductDto): Promise<Product> => {
        const response = await apiClient.post<ApiResponse<Product>>('/products', data);
        return response.data.data;
    },

    update: async (id: string, data: UpdateProductDto): Promise<Product> => {
        const response = await apiClient.put<ApiResponse<Product>>(`/products/${id}`, data);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/products/${id}`);
    },

    setPrices: async (id: string, prices: Record<string, number>): Promise<Product> => {
        const response = await apiClient.post<ApiResponse<Product>>(`/products/${id}/prices`, { prices });
        return response.data.data;
    },
};

export default productsApi;
