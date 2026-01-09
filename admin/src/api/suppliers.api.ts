import apiClient from './client';
import type { ApiResponse, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface Supplier {
    _id: string;
    name: string;
    nameAr?: string;
    code: string;
    contactPerson?: string;
    email?: string;
    phone?: string;
    address?: {
        street?: string;
        city?: string;
        country?: string;
        postalCode?: string;
    };
    taxNumber?: string;
    paymentTerms?: string;
    notes?: string;
    isActive: boolean;
    balance: number;
    totalPurchases: number;
    createdAt: string;
    updatedAt: string;
}

export interface SupplierProduct {
    _id: string;
    productId: string;
    productName: string;
    supplierSku?: string;
    costPrice: number;
    leadTime?: number;
    minOrderQuantity?: number;
    isPreferred: boolean;
}

export interface SupplierPayment {
    _id: string;
    amount: number;
    paymentMethod: string;
    reference?: string;
    notes?: string;
    createdBy: {
        _id: string;
        name: string;
    };
    createdAt: string;
}

export interface PurchaseOrder {
    _id: string;
    orderNumber: string;
    supplier: {
        _id: string;
        name: string;
    };
    status: 'draft' | 'pending' | 'approved' | 'ordered' | 'partial' | 'received' | 'cancelled';
    items: PurchaseOrderItem[];
    subtotal: number;
    taxAmount: number;
    shippingCost: number;
    total: number;
    notes?: string;
    expectedDeliveryDate?: string;
    createdBy: {
        _id: string;
        name: string;
    };
    createdAt: string;
    updatedAt: string;
}

export interface PurchaseOrderItem {
    _id: string;
    productId: string;
    productName: string;
    sku: string;
    quantity: number;
    receivedQuantity: number;
    damagedQuantity: number;
    unitPrice: number;
    total: number;
}

export interface CreateSupplierDto {
    name: string;
    nameAr?: string;
    code?: string;
    contactPerson?: string;
    email?: string;
    phone?: string;
    address?: {
        street?: string;
        city?: string;
        country?: string;
        postalCode?: string;
    };
    taxNumber?: string;
    paymentTerms?: string;
    notes?: string;
    isActive?: boolean;
}

export interface CreatePurchaseOrderDto {
    supplierId: string;
    items: {
        productId: string;
        quantity: number;
        unitPrice: number;
    }[];
    taxAmount?: number;
    shippingCost?: number;
    notes?: string;
    expectedDeliveryDate?: string;
}

export interface ReceiveItemDto {
    itemId: string;
    receivedQuantity: number;
    damagedQuantity?: number;
}

// ══════════════════════════════════════════════════════════════
// Suppliers API
// ══════════════════════════════════════════════════════════════

export const suppliersApi = {
    // ─────────────────────────────────────────
    // Suppliers CRUD
    // ─────────────────────────────────────────

    getAll: async (params?: { search?: string; isActive?: boolean }): Promise<Supplier[]> => {
        const response = await apiClient.get<ApiResponse<Supplier[]>>('/suppliers', { params });
        return response.data.data;
    },

    getById: async (id: string): Promise<Supplier> => {
        const response = await apiClient.get<ApiResponse<Supplier>>(`/suppliers/${id}`);
        return response.data.data;
    },

    create: async (data: CreateSupplierDto): Promise<Supplier> => {
        const response = await apiClient.post<ApiResponse<Supplier>>('/suppliers', data);
        return response.data.data;
    },

    update: async (id: string, data: Partial<CreateSupplierDto>): Promise<Supplier> => {
        const response = await apiClient.put<ApiResponse<Supplier>>(`/suppliers/${id}`, data);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/suppliers/${id}`);
    },

    // ─────────────────────────────────────────
    // Supplier Products
    // ─────────────────────────────────────────

    getProducts: async (supplierId: string): Promise<SupplierProduct[]> => {
        const response = await apiClient.get<ApiResponse<SupplierProduct[]>>(`/suppliers/${supplierId}/products`);
        return response.data.data;
    },

    addProduct: async (supplierId: string, data: {
        productId: string;
        supplierSku?: string;
        costPrice: number;
        leadTime?: number;
        minOrderQuantity?: number;
        isPreferred?: boolean;
    }): Promise<SupplierProduct> => {
        const response = await apiClient.post<ApiResponse<SupplierProduct>>(`/suppliers/${supplierId}/products`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Supplier Payments
    // ─────────────────────────────────────────

    getPayments: async (supplierId: string): Promise<SupplierPayment[]> => {
        const response = await apiClient.get<ApiResponse<SupplierPayment[]>>(`/suppliers/${supplierId}/payments`);
        return response.data.data;
    },

    createPayment: async (supplierId: string, data: {
        amount: number;
        paymentMethod: string;
        reference?: string;
        notes?: string;
    }): Promise<SupplierPayment> => {
        const response = await apiClient.post<ApiResponse<SupplierPayment>>(`/suppliers/${supplierId}/payments`, data);
        return response.data.data;
    },
};

// ══════════════════════════════════════════════════════════════
// Purchase Orders API
// ══════════════════════════════════════════════════════════════

export const purchaseOrdersApi = {
    getAll: async (params?: {
        status?: string;
        supplierId?: string;
        page?: number;
        limit?: number;
    }): Promise<PaginatedResponse<PurchaseOrder>> => {
        const response = await apiClient.get<ApiResponse<any>>('/purchase-orders', { params });
        const data = response.data.data;
        const orders = Array.isArray(data) ? data : (data?.items || data?.orders || []);
        const meta = (response.data as any).meta || data?.pagination || {};

        return {
            items: orders,
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || orders.length,
                totalPages: meta.pages || meta.totalPages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || meta.totalPages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    getById: async (id: string): Promise<PurchaseOrder> => {
        const response = await apiClient.get<ApiResponse<PurchaseOrder>>(`/purchase-orders/${id}`);
        return response.data.data;
    },

    create: async (data: CreatePurchaseOrderDto): Promise<PurchaseOrder> => {
        const payload = {
            order: {
                supplierId: data.supplierId,
                taxAmount: data.taxAmount || 0,
                shippingCost: data.shippingCost || 0,
                notes: data.notes,
                expectedDeliveryDate: data.expectedDeliveryDate,
            },
            items: data.items,
        };
        const response = await apiClient.post<ApiResponse<PurchaseOrder>>('/purchase-orders', payload);
        return response.data.data;
    },

    updateStatus: async (id: string, status: string): Promise<PurchaseOrder> => {
        const response = await apiClient.put<ApiResponse<PurchaseOrder>>(`/purchase-orders/${id}/status`, { status });
        return response.data.data;
    },

    receive: async (id: string, items: ReceiveItemDto[]): Promise<PurchaseOrder> => {
        const response = await apiClient.post<ApiResponse<PurchaseOrder>>(`/purchase-orders/${id}/receive`, items);
        return response.data.data;
    },
};

export default { ...suppliersApi, purchaseOrders: purchaseOrdersApi };
