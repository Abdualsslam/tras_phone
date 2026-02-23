import apiClient from './client';
import type { ApiResponse } from '@/types';

// Helper function to extract data from nested API response
function extractData<T>(responseData: any): T {
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

export interface DashboardStats {
    overview: {
        orders: {
            today: number;
            thisMonth: number;
            lastMonth: number;
            change: number;
        };
        revenue: {
            today: number;
            thisMonth: number;
            lastMonth: number;
            change: number;
        };
        customers: {
            total: number;
            newThisMonth: number;
        };
        products: {
            total: number;
            active: number;
        };
    };
    salesChart: any[];
    topProducts: any[];
    topCustomers: any[];
    lowStock: any[];
    recentOrders: any[];
    pendingActions: {
        pendingOrders: number;
        pendingPayments: number;
        pendingReturns: number;
        pendingApprovals: number;
        lowStockCount: number;
        total: number;
    };
}

export interface ChartDataPoint {
    date: string;
    value: number;
    label?: string;
}

export interface TopProduct {
    _id: string;
    name: string;
    sku: string;
    sales: number;
    revenue: number;
    image?: string;
}

export interface TopCustomer {
    _id: string;
    companyName: string;
    contactName: string;
    orders: number;
    totalSpent: number;
}

export interface CategoryStats {
    categoryId: string;
    categoryName: string;
    productCount: number;
    sales: number;
    revenue: number;
    percentage: number;
}

export interface ReportConfig {
    name: string;
    type: 'sales' | 'orders' | 'customers' | 'products' | 'inventory';
    startDate: string;
    endDate: string;
    groupBy: 'day' | 'week' | 'month';
    filters?: Record<string, any>;
}

export interface SavedReport {
    _id: string;
    name: string;
    config: ReportConfig;
    createdBy: string;
    createdAt: string;
    lastRunAt?: string;
}

export interface ComparisonData {
    current: { revenue: number; orders: number; customers: number };
    previous: { revenue: number; orders: number; customers: number };
    changes: { revenue: number; orders: number; customers: number };
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const analyticsApi = {
    // ─────────────────────────────────────────
    // Dashboard
    // ─────────────────────────────────────────

    getDashboard: async (): Promise<DashboardStats> => {
        const response = await apiClient.get<ApiResponse<DashboardStats>>('/analytics/dashboard');
        return response.data.data as DashboardStats;
    },

    // ─────────────────────────────────────────
    // Charts
    // ─────────────────────────────────────────

    getRevenueChart: async (startDate: string, endDate: string, groupBy = 'day'): Promise<ChartDataPoint[]> => {
        const response = await apiClient.get<ApiResponse<ChartDataPoint[]>>('/analytics/revenue-chart', {
            params: { startDate, endDate, groupBy }
        });
        return extractArrayData<ChartDataPoint>(response.data.data);
    },

    getOrdersChart: async (startDate: string, endDate: string): Promise<ChartDataPoint[]> => {
        const response = await apiClient.get<ApiResponse<ChartDataPoint[]>>('/analytics/orders-chart', {
            params: { startDate, endDate }
        });
        return extractArrayData<ChartDataPoint>(response.data.data);
    },

    getCustomersChart: async (startDate: string, endDate: string): Promise<ChartDataPoint[]> => {
        const response = await apiClient.get<ApiResponse<ChartDataPoint[]>>('/analytics/customers-chart', {
            params: { startDate, endDate }
        });
        return extractArrayData<ChartDataPoint>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Rankings
    // ─────────────────────────────────────────

    getTopProducts: async (startDate: string, endDate: string, limit = 10): Promise<TopProduct[]> => {
        const response = await apiClient.get<ApiResponse<TopProduct[]>>('/analytics/products/top', {
            params: { startDate, endDate, limit }
        });
        return extractArrayData<TopProduct>(response.data.data);
    },

    getTopCustomers: async (startDate: string, endDate: string, limit = 10): Promise<TopCustomer[]> => {
        const response = await apiClient.get<ApiResponse<TopCustomer[]>>('/analytics/customers/top', {
            params: { startDate, endDate, limit }
        });
        return extractArrayData<TopCustomer>(response.data.data);
    },

    getTopSearches: async (startDate: string, endDate: string, limit = 20): Promise<any[]> => {
        const response = await apiClient.get<ApiResponse<any[]>>('/analytics/search/top', {
            params: { startDate, endDate, limit }
        });
        return extractArrayData<any>(response.data.data);
    },

    getCategoryStats: async (startDate: string, endDate: string): Promise<CategoryStats[]> => {
        const response = await apiClient.get<ApiResponse<CategoryStats[]>>('/analytics/categories', {
            params: { startDate, endDate }
        });
        return extractArrayData<CategoryStats>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Reports
    // ─────────────────────────────────────────

    getSalesReport: async (startDate: string, endDate: string, groupBy = 'day'): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>('/analytics/sales-report', {
            params: { startDate, endDate, groupBy }
        });
        return extractData<any>(response.data.data);
    },

    getCustomerReport: async (startDate: string, endDate: string): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>('/analytics/customer-report', {
            params: { startDate, endDate }
        });
        return extractData<any>(response.data.data);
    },

    getInventoryReport: async (): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>('/analytics/inventory-report');
        return extractData<any>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Comparison
    // ─────────────────────────────────────────

    getComparison: async (currentStart: string, currentEnd: string, previousStart: string, previousEnd: string): Promise<ComparisonData> => {
        const response = await apiClient.get<ApiResponse<ComparisonData>>('/analytics/comparison', {
            params: { currentStart, currentEnd, previousStart, previousEnd }
        });
        return extractData<ComparisonData>(response.data.data);
    },

    // ─────────────────────────────────────────
    // Saved Reports
    // ─────────────────────────────────────────

    getSavedReports: async (): Promise<SavedReport[]> => {
        const response = await apiClient.get<ApiResponse<SavedReport[]>>('/analytics/reports');
        return extractArrayData<SavedReport>(response.data.data);
    },

    saveReport: async (config: ReportConfig): Promise<SavedReport> => {
        const response = await apiClient.post<ApiResponse<SavedReport>>('/analytics/reports', config);
        return extractData<SavedReport>(response.data.data);
    },

    runReport: async (reportId: string): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>(`/analytics/reports/${reportId}/run`);
        return extractData<any>(response.data.data);
    },

    deleteReport: async (reportId: string): Promise<void> => {
        await apiClient.delete(`/analytics/reports/${reportId}`);
    },

    // ─────────────────────────────────────────
    // Export
    // ─────────────────────────────────────────

    exportReport: async (type: string, startDate: string, endDate: string, format: 'csv' | 'xlsx' = 'xlsx'): Promise<Blob> => {
        const response = await apiClient.get('/analytics/export', {
            params: { type, startDate, endDate, format },
            responseType: 'blob',
        });
        return response.data;
    },
};

export default analyticsApi;

