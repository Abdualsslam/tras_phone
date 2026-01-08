import apiClient from './client';
import type { ApiResponse } from '@/types';

export interface Warehouse {
    _id: string;
    name: string;
    code: string;
    address: {
        street?: string;
        city?: string;
        state?: string;
        country?: string;
    };
    isActive: boolean;
    isDefault: boolean;
    totalProducts?: number;
    totalStock?: number;
}

export interface StockItem {
    _id: string;
    productId: string;
    product: {
        name: string;
        sku: string;
        image?: string;
    };
    warehouseId: string;
    warehouse: {
        name: string;
    };
    quantity: number;
    reservedQuantity: number;
    availableQuantity: number;
    minStockLevel: number;
    status: 'in_stock' | 'low_stock' | 'out_of_stock';
}

export interface StockAlert {
    _id: string;
    productId: string;
    product: {
        name: string;
        sku: string;
    };
    warehouseId: string;
    warehouse: {
        name: string;
    };
    currentStock: number;
    minStockLevel: number;
    status: 'pending' | 'acknowledged' | 'resolved';
    createdAt: string;
}

export interface StockMovement {
    _id: string;
    type: 'in' | 'out' | 'transfer' | 'adjustment';
    productId: string;
    product: {
        name: string;
        sku: string;
    };
    quantity: number;
    fromWarehouse?: string;
    toWarehouse?: string;
    reason?: string;
    createdAt: string;
    createdBy: string;
}

export const inventoryApi = {
    // Warehouses
    getWarehouses: async (): Promise<Warehouse[]> => {
        const response = await apiClient.get<ApiResponse<Warehouse[]>>('/inventory/warehouses');
        return response.data.data;
    },

    getWarehouse: async (id: string): Promise<Warehouse> => {
        const response = await apiClient.get<ApiResponse<Warehouse>>(`/inventory/warehouses/${id}`);
        return response.data.data;
    },

    createWarehouse: async (data: any): Promise<Warehouse> => {
        const response = await apiClient.post<ApiResponse<Warehouse>>('/inventory/warehouses', data);
        return response.data.data;
    },

    updateWarehouse: async (id: string, data: any): Promise<Warehouse> => {
        const response = await apiClient.put<ApiResponse<Warehouse>>(`/inventory/warehouses/${id}`, data);
        return response.data.data;
    },

    // Stock
    getProductStock: async (productId: string): Promise<StockItem[]> => {
        const response = await apiClient.get<ApiResponse<StockItem[]>>(`/inventory/stock/${productId}`);
        return response.data.data;
    },

    adjustStock: async (data: { productId: string; warehouseId: string; quantity: number; type: string; reason?: string }): Promise<any> => {
        const response = await apiClient.post<ApiResponse<any>>('/inventory/stock/adjust', data);
        return response.data.data;
    },

    // Alerts
    getAlerts: async (status?: string): Promise<StockAlert[]> => {
        const response = await apiClient.get<ApiResponse<StockAlert[]>>('/inventory/alerts', {
            params: status ? { status } : undefined
        });
        return response.data.data;
    },

    // Movements
    getMovements: async (params?: { productId?: string; warehouseId?: string; type?: string }): Promise<StockMovement[]> => {
        const response = await apiClient.get<ApiResponse<StockMovement[]>>('/inventory/movements', { params });
        return response.data.data;
    },
};

export default inventoryApi;
