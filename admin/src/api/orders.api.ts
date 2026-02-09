import apiClient from './client';
import type { ApiResponse, Order, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface OrdersQueryParams {
    page?: number;
    limit?: number;
    orderNumber?: string;
    status?: string;
    paymentStatus?: string;
    customerId?: string;
    startDate?: string;
    endDate?: string;
}

export interface UpdateOrderStatusDto {
    status: string;
    note?: string;
}

export interface CreateShipmentDto {
    trackingNumber?: string;
    carrier?: string;
    items: {
        productId: string;
        quantity: number;
    }[];
}

export interface OrderNote {
    _id: string;
    orderId: string;
    content: string;
    type: 'internal' | 'customer';
    createdBy: string;
    createdByName?: string;
    createdAt: string;
}

export interface OrderShipment {
    _id: string;
    orderId: string;
    trackingNumber?: string;
    carrier?: string;
    status: 'pending' | 'shipped' | 'in_transit' | 'delivered' | 'returned';
    items: { productId: string; productName?: string; quantity: number }[];
    shippedAt?: string;
    deliveredAt?: string;
    createdAt: string;
}

export interface OrderStats {
    totalOrders: number;
    pendingOrders: number;
    processingOrders: number;
    shippedOrders: number;
    deliveredOrders: number;
    cancelledOrders: number;
    totalRevenue: number;
    todayOrders: number;
    todayRevenue?: number;
    thisMonthOrders?: number;
    thisMonthRevenue?: number;
    totalPaid?: number;
    totalUnpaid?: number;
    byStatus?: Record<string, number>;
    byPaymentStatus?: Record<string, number>;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const ordersApi = {
    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    getStats: async (): Promise<OrderStats> => {
        const response = await apiClient.get<ApiResponse<any>>('/orders/stats');
        const d = response.data.data;
        // API returns: total, byStatus, byPaymentStatus, totalRevenue, todayOrders, etc.
        return {
            totalOrders: d?.total ?? 0,
            pendingOrders: d?.byStatus?.pending ?? 0,
            processingOrders: d?.byStatus?.processing ?? 0,
            shippedOrders: d?.byStatus?.shipped ?? 0,
            deliveredOrders: d?.byStatus?.delivered ?? 0,
            cancelledOrders: d?.byStatus?.cancelled ?? 0,
            totalRevenue: d?.totalRevenue ?? 0,
            todayOrders: d?.todayOrders ?? 0,
            todayRevenue: d?.todayRevenue,
            thisMonthOrders: d?.thisMonthOrders,
            thisMonthRevenue: d?.thisMonthRevenue,
            totalPaid: d?.totalPaid,
            totalUnpaid: d?.totalUnpaid,
            byStatus: d?.byStatus,
            byPaymentStatus: d?.byPaymentStatus,
        };
    },

    // ─────────────────────────────────────────
    // Orders CRUD
    // ─────────────────────────────────────────

    getAll: async (params?: OrdersQueryParams): Promise<PaginatedResponse<Order>> => {
        const cleanParams: Record<string, any> = {};
        if (params) {
            if (params.page) cleanParams.page = params.page;
            if (params.limit) cleanParams.limit = params.limit;
            if (params.orderNumber) cleanParams.orderNumber = params.orderNumber;
            if (params.status) cleanParams.status = params.status;
            if (params.paymentStatus) cleanParams.paymentStatus = params.paymentStatus;
            if (params.customerId) cleanParams.customerId = params.customerId;
            if (params.startDate) cleanParams.startDate = params.startDate;
            if (params.endDate) cleanParams.endDate = params.endDate;
        }

        const response = await apiClient.get<ApiResponse<any>>('/orders', { params: cleanParams });
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

    getById: async (id: string): Promise<Order> => {
        const response = await apiClient.get<ApiResponse<Order>>(`/orders/${id}`);
        return response.data.data;
    },

    updateStatus: async (id: string, data: UpdateOrderStatusDto): Promise<Order> => {
        const response = await apiClient.put<ApiResponse<Order>>(`/orders/${id}/status`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Order Notes
    // ─────────────────────────────────────────

    getNotes: async (orderId: string): Promise<OrderNote[]> => {
        const response = await apiClient.get<ApiResponse<OrderNote[]>>(`/orders/${orderId}/notes`);
        return response.data.data;
    },

    addNote: async (orderId: string, data: { content: string; type: 'internal' | 'customer' }): Promise<OrderNote> => {
        const response = await apiClient.post<ApiResponse<OrderNote>>(`/orders/${orderId}/notes`, data);
        return response.data.data;
    },

    deleteNote: async (orderId: string, noteId: string): Promise<void> => {
        await apiClient.delete(`/orders/${orderId}/notes/${noteId}`);
    },

    // ─────────────────────────────────────────
    // Shipments
    // ─────────────────────────────────────────

    getShipments: async (orderId: string): Promise<OrderShipment[]> => {
        const response = await apiClient.get<ApiResponse<OrderShipment[]>>(`/orders/${orderId}/shipments`);
        return response.data.data;
    },

    createShipment: async (id: string, data: CreateShipmentDto): Promise<OrderShipment> => {
        const response = await apiClient.post<ApiResponse<OrderShipment>>(`/orders/${id}/shipments`, data);
        return response.data.data;
    },

    updateShipmentStatus: async (orderId: string, shipmentId: string, status: string): Promise<OrderShipment> => {
        const response = await apiClient.put<ApiResponse<OrderShipment>>(`/orders/${orderId}/shipments/${shipmentId}/status`, { status });
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Payments
    // ─────────────────────────────────────────

    recordPayment: async (id: string, data: { amount: number; method?: string; reference?: string }): Promise<Order> => {
        const response = await apiClient.post<ApiResponse<Order>>(`/orders/${id}/payments`, data);
        return response.data.data;
    },

    refundPayment: async (id: string, data: { amount: number; reason?: string }): Promise<Order> => {
        const response = await apiClient.post<ApiResponse<Order>>(`/orders/${id}/refund`, data);
        return response.data.data;
    },

    verifyPayment: async (orderId: string, data: { verified: boolean; note?: string }): Promise<Order> => {
        const response = await apiClient.post<ApiResponse<Order>>(`/admin/orders/${orderId}/verify-payment`, data);
        return response.data.data;
    },

    getPendingPaymentOrders: async (): Promise<Order[]> => {
        const response = await apiClient.get<ApiResponse<Order[]>>('/orders/pending-payment');
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Export
    // ─────────────────────────────────────────

    exportOrders: async (params?: OrdersQueryParams): Promise<Blob> => {
        const response = await apiClient.get('/orders/export', {
            params,
            responseType: 'blob',
        });
        return response.data;
    },
};

export default ordersApi;

