import apiClient from './client';
import type { ApiResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface Warehouse {
    _id: string;
    name: string;
    nameAr?: string;
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

export interface WarehouseLocation {
    _id: string;
    warehouseId: string;
    name: string;
    code: string;
    type: 'shelf' | 'bin' | 'zone' | 'rack';
    isActive: boolean;
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
    locationId?: string;
    quantity: number;
    reservedQuantity: number;
    availableQuantity: number;
    minStockLevel: number;
    maxStockLevel?: number;
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
    alertType: 'low_stock' | 'out_of_stock' | 'overstock';
    status: 'pending' | 'acknowledged' | 'resolved';
    acknowledgedBy?: string;
    acknowledgedAt?: string;
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
    fromWarehouseName?: string;
    toWarehouse?: string;
    toWarehouseName?: string;
    reason?: string;
    reference?: string;
    createdAt: string;
    createdBy: string;
    createdByName?: string;
}

export interface InventoryStats {
    totalWarehouses: number;
    totalProducts: number;
    totalStock: number;
    lowStockItems: number;
    outOfStockItems: number;
    pendingAlerts: number;
    todayMovements: number;
}

export interface StockTransferDto {
    productId: string;
    fromWarehouseId: string;
    toWarehouseId: string;
    quantity: number;
    reason?: string;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const inventoryApi = {
    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    getStats: async (): Promise<InventoryStats> => {
        const response = await apiClient.get<ApiResponse<InventoryStats>>('/inventory/stats');
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Warehouses
    // ─────────────────────────────────────────

    getWarehouses: async (): Promise<Warehouse[]> => {
        const response = await apiClient.get<ApiResponse<Warehouse[]>>('/inventory/warehouses');
        return response.data.data;
    },

    getWarehouse: async (id: string): Promise<Warehouse> => {
        const response = await apiClient.get<ApiResponse<Warehouse>>(`/inventory/warehouses/${id}`);
        return response.data.data;
    },

    createWarehouse: async (data: Omit<Warehouse, '_id' | 'totalProducts' | 'totalStock'>): Promise<Warehouse> => {
        const response = await apiClient.post<ApiResponse<Warehouse>>('/inventory/warehouses', data);
        return response.data.data;
    },

    updateWarehouse: async (id: string, data: Partial<Warehouse>): Promise<Warehouse> => {
        const response = await apiClient.put<ApiResponse<Warehouse>>(`/inventory/warehouses/${id}`, data);
        return response.data.data;
    },

    deleteWarehouse: async (id: string): Promise<void> => {
        await apiClient.delete(`/inventory/warehouses/${id}`);
    },

    // ─────────────────────────────────────────
    // Warehouse Locations
    // ─────────────────────────────────────────

    getLocations: async (warehouseId?: string): Promise<WarehouseLocation[]> => {
        const response = await apiClient.get<ApiResponse<WarehouseLocation[]>>('/inventory/locations', {
            params: warehouseId ? { warehouseId } : undefined,
        });
        return response.data.data;
    },

    createLocation: async (data: Omit<WarehouseLocation, '_id'>): Promise<WarehouseLocation> => {
        const response = await apiClient.post<ApiResponse<WarehouseLocation>>('/inventory/locations', data);
        return response.data.data;
    },

    updateLocation: async (id: string, data: Partial<WarehouseLocation>): Promise<WarehouseLocation> => {
        const response = await apiClient.put<ApiResponse<WarehouseLocation>>(`/inventory/locations/${id}`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Stock
    // ─────────────────────────────────────────

    getStock: async (params?: { warehouseId?: string; status?: string }): Promise<StockItem[]> => {
        const response = await apiClient.get<ApiResponse<StockItem[]>>('/inventory/stock', { params });
        return response.data.data;
    },

    getProductStock: async (productId: string): Promise<StockItem[]> => {
        const response = await apiClient.get<ApiResponse<StockItem[]>>(`/inventory/stock/${productId}`);
        return response.data.data;
    },

    adjustStock: async (data: { productId: string; warehouseId: string; quantity: number; type: 'add' | 'subtract' | 'set'; reason?: string }): Promise<StockItem> => {
        const response = await apiClient.post<ApiResponse<StockItem>>('/inventory/stock/adjust', data);
        return response.data.data;
    },

    transferStock: async (data: StockTransferDto): Promise<void> => {
        await apiClient.post('/inventory/stock/transfer', data);
    },

    updateStockLevels: async (productId: string, data: { minStockLevel?: number; maxStockLevel?: number }): Promise<StockItem> => {
        const response = await apiClient.put<ApiResponse<StockItem>>(`/inventory/stock/${productId}/levels`, data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Alerts
    // ─────────────────────────────────────────

    getAlerts: async (status?: string): Promise<StockAlert[]> => {
        const response = await apiClient.get<ApiResponse<StockAlert[]>>('/inventory/alerts', {
            params: status ? { status } : undefined
        });
        return response.data.data;
    },

    acknowledgeAlert: async (id: string): Promise<StockAlert> => {
        const response = await apiClient.put<ApiResponse<StockAlert>>(`/inventory/alerts/${id}/acknowledge`);
        return response.data.data;
    },

    resolveAlert: async (id: string): Promise<StockAlert> => {
        const response = await apiClient.put<ApiResponse<StockAlert>>(`/inventory/alerts/${id}/resolve`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Movements
    // ─────────────────────────────────────────

    getMovements: async (params?: { productId?: string; warehouseId?: string; type?: string; startDate?: string; endDate?: string }): Promise<StockMovement[]> => {
        const response = await apiClient.get<ApiResponse<StockMovement[]>>('/inventory/movements', { params });
        return response.data.data;
    },
};

export default inventoryApi;

