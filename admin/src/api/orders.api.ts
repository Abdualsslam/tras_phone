import apiClient from './client';
import type { ApiResponse, Order, PaginatedResponse } from '@/types';

export interface OrdersQueryParams {
    page?: number;
    limit?: number;
    orderNumber?: string;
    status?: string;
    paymentStatus?: string;
    customerId?: string;
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

export const ordersApi = {
    getAll: async (params?: OrdersQueryParams): Promise<PaginatedResponse<Order>> => {
        // Clean up empty params to avoid validation errors
        const cleanParams: Record<string, any> = {};
        if (params) {
            if (params.page) cleanParams.page = params.page;
            if (params.limit) cleanParams.limit = params.limit;
            if (params.orderNumber) cleanParams.orderNumber = params.orderNumber;
            if (params.status) cleanParams.status = params.status;
            if (params.paymentStatus) cleanParams.paymentStatus = params.paymentStatus;
            if (params.customerId) cleanParams.customerId = params.customerId;
        }

        const response = await apiClient.get<ApiResponse<any>>('/orders', { params: cleanParams });

        // Transform response to expected format
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

    createShipment: async (id: string, data: CreateShipmentDto): Promise<Order> => {
        const response = await apiClient.post<ApiResponse<Order>>(`/orders/${id}/shipments`, data);
        return response.data.data;
    },

    recordPayment: async (id: string, amount: number): Promise<Order> => {
        const response = await apiClient.post<ApiResponse<Order>>(`/orders/${id}/payments`, { amount });
        return response.data.data;
    },
};

export default ordersApi;
