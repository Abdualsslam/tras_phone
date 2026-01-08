import apiClient from './client';
import type { ApiResponse } from '@/types';

export interface DashboardStats {
    totalRevenue: number;
    totalOrders: number;
    totalCustomers: number;
    totalProducts: number;
    revenueChange: number;
    ordersChange: number;
    customersChange: number;
    productsChange: number;
    recentOrders: any[];
    lowStockProducts: any[];
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

export const analyticsApi = {
    getDashboard: async (): Promise<DashboardStats> => {
        const response = await apiClient.get<ApiResponse<DashboardStats>>('/analytics/dashboard');
        return response.data.data;
    },

    getRevenueChart: async (startDate: string, endDate: string, groupBy = 'day'): Promise<ChartDataPoint[]> => {
        const response = await apiClient.get<ApiResponse<ChartDataPoint[]>>('/analytics/revenue-chart', {
            params: { startDate, endDate, groupBy }
        });
        return response.data.data;
    },

    getOrdersChart: async (startDate: string, endDate: string): Promise<ChartDataPoint[]> => {
        const response = await apiClient.get<ApiResponse<ChartDataPoint[]>>('/analytics/orders-chart', {
            params: { startDate, endDate }
        });
        return response.data.data;
    },

    getTopProducts: async (startDate: string, endDate: string, limit = 10): Promise<TopProduct[]> => {
        const response = await apiClient.get<ApiResponse<TopProduct[]>>('/analytics/products/top', {
            params: { startDate, endDate, limit }
        });
        return response.data.data;
    },

    getTopSearches: async (startDate: string, endDate: string, limit = 20): Promise<any[]> => {
        const response = await apiClient.get<ApiResponse<any[]>>('/analytics/search/top', {
            params: { startDate, endDate, limit }
        });
        return response.data.data;
    },

    getSalesReport: async (startDate: string, endDate: string, groupBy = 'day'): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>('/analytics/sales-report', {
            params: { startDate, endDate, groupBy }
        });
        return response.data.data;
    },

    getCustomerReport: async (startDate: string, endDate: string): Promise<any> => {
        const response = await apiClient.get<ApiResponse<any>>('/analytics/customer-report', {
            params: { startDate, endDate }
        });
        return response.data.data;
    },
};

export default analyticsApi;
