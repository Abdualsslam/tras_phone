import apiClient from './client';
import type { ApiResponse, Product, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

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
    video?: string;
    specifications?: Record<string, any>;
    weight?: number;
    dimensions?: string;
    color?: string;
    tags?: string[];
    relatedProducts?: string[];
    relatedEducationalContent?: string[];
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

export interface PriceLevel {
    _id: string;
    name: string;
    nameAr?: string;
    code: string;
    description?: string;
    discountPercentage?: number;
    minOrderAmount?: number;
    color?: string;
    displayOrder?: number;
    isActive?: boolean;
    isDefault?: boolean;
}

export interface CreatePriceLevelDto {
    name: string;
    nameAr: string;
    code: string;
    description?: string;
    discountPercentage?: number;
    minOrderAmount?: number;
    color?: string;
    displayOrder?: number;
    isActive?: boolean;
    isDefault?: boolean;
}

export interface UpdatePriceLevelDto {
    name?: string;
    nameAr?: string;
    code?: string;
    description?: string;
    discountPercentage?: number;
    minOrderAmount?: number;
    color?: string;
    displayOrder?: number;
    isActive?: boolean;
    isDefault?: boolean;
}

export interface ProductPrice {
    priceLevelId: string;
    priceLevel?: PriceLevel;
    price: number;
}

export interface ProductReview {
    _id: string;
    customerId: string | { _id: string; shopName?: string; companyName?: string; responsiblePersonName?: string };
    customer?: {
        _id: string;
        companyName: string;
        contactName: string;
    };
    rating: number;
    comment?: string;
    status?: 'pending' | 'approved' | 'rejected';
    isVerified?: boolean;
    isVerifiedPurchase?: boolean;
    isApproved?: boolean;
    createdAt: string;
}

export interface StockAlert {
    _id: string;
    productId: string;
    product?: Product;
    threshold: number;
    email?: string;
    isActive: boolean;
    lastTriggered?: string;
    createdAt: string;
}

export interface ProductsImportExportResult {
    success: boolean;
    summary: {
        total: number;
        created: number;
        updated: number;
        skipped: number;
        errors: number;
    };
    errors: Array<{
        row: number;
        sheet: string;
        field: string;
        message: string;
        value?: unknown;
    }>;
    warnings: Array<{
        row: number;
        sheet: string;
        field: string;
        message: string;
    }>;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const productsApi = {
    // ─────────────────────────────────────────
    // Products CRUD
    // ─────────────────────────────────────────

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
            slug: p.slug,
            description: p.description,
            descriptionAr: p.descriptionAr,
            shortDescription: p.shortDescription,
            shortDescriptionAr: p.shortDescriptionAr,
            category: p.categoryId,
            brand: p.brandId,
            qualityTypeId:
                typeof p.qualityTypeId === 'object' && p.qualityTypeId
                    ? (p.qualityTypeId._id || p.qualityTypeId.id || '')
                    : (p.qualityTypeId || ''),
            mainImage: p.mainImage,
            images: p.images || [],
            video: p.video,
            price: p.basePrice || 0,
            compareAtPrice: p.compareAtPrice,
            costPrice: p.costPrice,
            stock: p.stockQuantity || 0,
            lowStockThreshold: p.lowStockThreshold,
            minOrderQuantity: p.minOrderQuantity,
            maxOrderQuantity: p.maxOrderQuantity,
            status: p.status || 'draft',
            isActive: p.isActive,
            featured: p.isFeatured || false,
            trackInventory: p.trackInventory,
            allowBackorder: p.allowBackorder,
            additionalCategories: p.additionalCategories || [],
            tags: p.tags || [],
            specifications: p.specifications || {},
            weight: p.weight,
            dimensions: p.dimensions,
            color: p.color,
            averageRating: p.averageRating ?? 0,
            reviewsCount: p.reviewsCount ?? 0,
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

    // ─────────────────────────────────────────
    // Price Levels
    // ─────────────────────────────────────────

    getPriceLevels: async (): Promise<PriceLevel[]> => {
        const response = await apiClient.get<ApiResponse<PriceLevel[]>>('/products/price-levels');
        return response.data.data;
    },

    setProductPrices: async (productId: string, prices: { priceLevelId: string; price: number }[]): Promise<ProductPrice[]> => {
        const response = await apiClient.post<ApiResponse<ProductPrice[]>>(`/products/${productId}/prices`, { prices });
        return response.data.data;
    },

    getProductPrices: async (productId: string): Promise<ProductPrice[]> => {
        const response = await apiClient.get<ApiResponse<ProductPrice[]>>(`/products/${productId}/prices`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Price Levels Management (Admin)
    // ─────────────────────────────────────────

    getAllPriceLevels: async (): Promise<PriceLevel[]> => {
        const response = await apiClient.get<ApiResponse<PriceLevel[]>>('/products/price-levels/all');
        return response.data.data;
    },

    getPriceLevelById: async (id: string): Promise<PriceLevel> => {
        const response = await apiClient.get<ApiResponse<PriceLevel>>(`/products/price-levels/${id}`);
        return response.data.data;
    },

    createPriceLevel: async (data: CreatePriceLevelDto): Promise<PriceLevel> => {
        const response = await apiClient.post<ApiResponse<PriceLevel>>('/products/price-levels', data);
        return response.data.data;
    },

    updatePriceLevel: async (id: string, data: UpdatePriceLevelDto): Promise<PriceLevel> => {
        const response = await apiClient.put<ApiResponse<PriceLevel>>(`/products/price-levels/${id}`, data);
        return response.data.data;
    },

    deletePriceLevel: async (id: string): Promise<void> => {
        await apiClient.delete(`/products/price-levels/${id}`);
    },

    // ─────────────────────────────────────────
    // Reviews
    // ─────────────────────────────────────────

    getProductReviews: async (productId: string): Promise<ProductReview[]> => {
        const response = await apiClient.get<ApiResponse<ProductReview[]>>(`/products/${productId}/reviews/admin`);
        return response.data.data;
    },

    approveReview: async (productId: string, reviewId: string): Promise<ProductReview> => {
        const response = await apiClient.put<ApiResponse<ProductReview>>(`/products/${productId}/reviews/${reviewId}/approve`);
        return response.data.data;
    },

    deleteReview: async (productId: string, reviewId: string): Promise<void> => {
        await apiClient.delete(`/products/${productId}/reviews/${reviewId}`);
    },

    // ─────────────────────────────────────────
    // Device Compatibility
    // ─────────────────────────────────────────

    setCompatibleDevices: async (productId: string, deviceIds: string[]): Promise<Product> => {
        const response = await apiClient.post<ApiResponse<Product>>(`/products/${productId}/devices`, { deviceIds });
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Tags
    // ─────────────────────────────────────────

    setProductTags: async (productId: string, tags: string[]): Promise<Product> => {
        const response = await apiClient.post<ApiResponse<Product>>(`/products/${productId}/tags`, { tags });
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Stock Alerts
    // ─────────────────────────────────────────

    getStockAlerts: async (): Promise<StockAlert[]> => {
        const response = await apiClient.get<ApiResponse<StockAlert[]>>('/products/stock-alerts');
        return response.data.data;
    },

    createStockAlert: async (data: { productId: string; threshold: number; email?: string }): Promise<StockAlert> => {
        const response = await apiClient.post<ApiResponse<StockAlert>>('/products/stock-alerts', data);
        return response.data.data;
    },

    updateStockAlert: async (alertId: string, data: { threshold?: number; email?: string; isActive?: boolean }): Promise<StockAlert> => {
        const response = await apiClient.put<ApiResponse<StockAlert>>(`/products/stock-alerts/${alertId}`, data);
        return response.data.data;
    },

    deleteStockAlert: async (alertId: string): Promise<void> => {
        await apiClient.delete(`/products/stock-alerts/${alertId}`);
    },

    // ─────────────────────────────────────────
    // Import / Export
    // ─────────────────────────────────────────

    downloadImportTemplate: async (): Promise<Blob> => {
        const response = await apiClient.get('/products/import-export/template', {
            responseType: 'blob',
        });
        return response.data;
    },

    exportProductsExcel: async (params?: {
        brandId?: string;
        categoryId?: string;
        status?: string;
        qualityTypeId?: string;
        includeInactive?: boolean;
        includeCompatibility?: boolean;
        includeReferences?: boolean;
        search?: string;
    }): Promise<Blob> => {
        const response = await apiClient.get('/products/import-export/export', {
            params,
            responseType: 'blob',
        });
        return response.data;
    },

    validateImportFile: async (file: File): Promise<any> => {
        const formData = new FormData();
        formData.append('file', file);
        const response = await apiClient.post<ApiResponse<any>>('/products/import-export/validate', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
        });
        return response.data.data;
    },

    importProductsExcel: async (
        file: File,
        params?: { mode?: 'create' | 'update' | 'upsert'; skipValidation?: boolean },
    ): Promise<ProductsImportExportResult | any> => {
        const formData = new FormData();
        formData.append('file', file);
        const response = await apiClient.post<ApiResponse<any>>('/products/import-export/import', formData, {
            params,
            headers: { 'Content-Type': 'multipart/form-data' },
        });
        return response.data.data;
    },

    partialUpdateProductsExcel: async (file: File): Promise<ProductsImportExportResult> => {
        const formData = new FormData();
        formData.append('file', file);
        const response = await apiClient.post<ApiResponse<ProductsImportExportResult>>('/products/import-export/partial', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
        });
        return response.data.data;
    },
};

export default productsApi;
