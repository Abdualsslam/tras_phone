import apiClient from './client';
import type { ApiResponse, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface ReturnReason {
    _id: string;
    name: string;
    nameAr: string;
    description?: string;
    isActive: boolean;
    requireImage: boolean;
}

export interface ReturnItem {
    _id: string;
    productId: string;
    productName: string;
    productImage?: string;
    sku: string;
    quantity: number;
    unitPrice: number;
    returnReason: string;
    condition?: 'unopened' | 'opened' | 'damaged' | 'defective';
    inspectionNotes?: string;
    inspectionStatus?: 'pending' | 'approved' | 'rejected';
    inspectedAt?: string;
    inspectedBy?: {
        _id: string;
        name: string;
    };
}

export interface Return {
    _id: string;
    returnNumber: string;
    orderIds: string[];
    orderNumbers: string[];
    // Backward compatibility
    orderId?: string;
    orderNumber?: string;
    customerId: string;
    customerName: string;
    status: 'pending' | 'approved' | 'rejected' | 'processing' | 'refunded' | 'completed' | 'cancelled';
    items: ReturnItem[];
    subtotal: number;
    refundAmount: number;
    refundMethod?: 'original_payment' | 'store_credit' | 'bank_transfer';
    refundStatus?: 'pending' | 'processing' | 'completed' | 'failed';
    notes?: string;
    adminNotes?: string;
    createdAt: string;
    updatedAt: string;
}

export interface CreateReturnDto {
    orderId: string;
    items: {
        productId: string;
        quantity: number;
        returnReason: string;
        notes?: string;
    }[];
    notes?: string;
}

export interface UpdateReturnStatusDto {
    status: string;
    adminNotes?: string;
}

export interface InspectItemDto {
    condition: 'unopened' | 'opened' | 'damaged' | 'defective';
    inspectionNotes?: string;
    approved: boolean;
}

export interface ProcessRefundDto {
    refundAmount: number;
    notes?: string;
}

// ══════════════════════════════════════════════════════════════
// Returns API
// ══════════════════════════════════════════════════════════════

export const returnsApi = {
    // ─────────────────────────────────────────
    // Return Reasons
    // ─────────────────────────────────────────

    getReasons: async (): Promise<ReturnReason[]> => {
        const response = await apiClient.get<ApiResponse<ReturnReason[]>>('/returns/reasons');
        return response.data.data;
    },

    createReason: async (data: Omit<ReturnReason, '_id'>): Promise<ReturnReason> => {
        const response = await apiClient.post<ApiResponse<ReturnReason>>('/returns/reasons', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Returns Management
    // ─────────────────────────────────────────

    getAll: async (params?: {
        status?: string;
        customerId?: string;
        page?: number;
        limit?: number;
    }): Promise<PaginatedResponse<Return>> => {
        const response = await apiClient.get<ApiResponse<any>>('/returns', { params });
        const data = response.data.data;
        const returns = Array.isArray(data) ? data : (data?.items || data?.returns || []);
        const meta = (response.data as any).meta || data?.pagination || {};

        return {
            items: returns,
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || returns.length,
                totalPages: meta.pages || meta.totalPages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || meta.totalPages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    getById: async (id: string): Promise<Return> => {
        const response = await apiClient.get<ApiResponse<Return>>(`/returns/${id}`);
        return response.data.data;
    },

    updateStatus: async (id: string, data: UpdateReturnStatusDto): Promise<Return> => {
        const response = await apiClient.put<ApiResponse<Return>>(`/returns/${id}/status`, data);
        return response.data.data;
    },

    inspectItem: async (returnId: string, itemId: string, data: InspectItemDto): Promise<ReturnItem> => {
        const response = await apiClient.put<ApiResponse<ReturnItem>>(`/returns/${returnId}/items/${itemId}/inspect`, data);
        return response.data.data;
    },

    processRefund: async (id: string, data: ProcessRefundDto): Promise<Return> => {
        const response = await apiClient.post<ApiResponse<Return>>(`/returns/${id}/refund`, data);
        return response.data.data;
    },

    completeRefund: async (returnId: string): Promise<Return> => {
        const response = await apiClient.post<ApiResponse<Return>>(`/returns/${returnId}/refund/complete`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Return Reasons Management
    // ─────────────────────────────────────────

    updateReason: async (id: string, data: Partial<ReturnReason>): Promise<ReturnReason> => {
        const response = await apiClient.put<ApiResponse<ReturnReason>>(`/returns/reasons/${id}`, data);
        return response.data.data;
    },

    deleteReason: async (id: string): Promise<void> => {
        await apiClient.delete(`/returns/reasons/${id}`);
    },

    // ─────────────────────────────────────────
    // Supplier Return Batches
    // ─────────────────────────────────────────

    getSupplierReturnBatches: async (params?: any): Promise<SupplierReturnBatch[]> => {
        const response = await apiClient.get<ApiResponse<SupplierReturnBatch[]>>('/returns/supplier-returns', { params });
        return response.data.data;
    },

    createSupplierReturnBatch: async (data: any): Promise<SupplierReturnBatch> => {
        const response = await apiClient.post<ApiResponse<SupplierReturnBatch>>('/returns/supplier-returns', data);
        return response.data.data;
    },

    updateSupplierBatchStatus: async (id: string, data: {
        status: string;
        acknowledgedDate?: string;
        supplierReference?: string;
        creditNoteNumber?: string;
        actualCreditAmount?: number;
        supplierNotes?: string;
    }): Promise<SupplierReturnBatch> => {
        const response = await apiClient.put<ApiResponse<SupplierReturnBatch>>(`/returns/supplier-returns/${id}/status`, data);
        return response.data.data;
    },

    linkReturnToSupplier: async (itemId: string, batchId: string): Promise<any> => {
        const response = await apiClient.post<ApiResponse<any>>(`/returns/items/${itemId}/link-supplier`, { batchId });
        return response.data.data;
    },
};

export interface SupplierReturnBatch {
    _id: string;
    supplierId: string;
    supplierName?: string;
    items: ReturnItem[];
    status: 'pending' | 'shipped' | 'acknowledged' | 'credited' | 'completed';
    totalAmount: number;
    creditAmount?: number;
    shippedAt?: string;
    acknowledgedAt?: string;
    creditNoteNumber?: string;
    supplierReference?: string;
    notes?: string;
    createdAt: string;
    updatedAt: string;
}

export default returnsApi;
