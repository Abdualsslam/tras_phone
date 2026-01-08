import apiClient from './client';
import type { ApiResponse, Notification, PaginatedResponse } from '@/types';

export interface NotificationTemplate {
    _id: string;
    name: string;
    nameAr: string;
    type: 'order' | 'promotion' | 'system' | 'stock';
    channel: 'push' | 'email' | 'sms';
    titleTemplate: string;
    bodyTemplate: string;
    isActive: boolean;
    createdAt: string;
}

export interface NotificationCampaign {
    _id: string;
    title: string;
    body: string;
    type: 'push' | 'email' | 'sms';
    status: 'draft' | 'scheduled' | 'sent' | 'failed';
    scheduledAt?: string;
    sentAt?: string;
    targetAudience: 'all' | 'segment' | 'specific';
    targetCustomers?: string[];
    stats: {
        sent: number;
        delivered: number;
        opened: number;
        clicked: number;
    };
    createdAt: string;
}

export interface NotificationsQueryParams {
    page?: number;
    limit?: number;
    type?: string;
    isRead?: boolean;
}

export const notificationsApi = {
    // User notifications
    getNotifications: async (params?: NotificationsQueryParams): Promise<PaginatedResponse<Notification>> => {
        // Clean up empty params
        const cleanParams: Record<string, any> = {};
        if (params) {
            if (params.page) cleanParams.page = params.page;
            if (params.limit) cleanParams.limit = params.limit;
            if (params.type) cleanParams.type = params.type;
            if (params.isRead !== undefined) cleanParams.isRead = params.isRead;
        }

        const response = await apiClient.get<ApiResponse<any>>('/notifications/my', { params: cleanParams });

        // Transform response to expected format
        const data = response.data.data;
        const notifications = Array.isArray(data) ? data : (data?.items || []);
        const meta = (response.data as any).meta || {};

        return {
            items: notifications,
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || notifications.length,
                totalPages: meta.pages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    markAsRead: async (id: string): Promise<void> => {
        await apiClient.put(`/notifications/${id}/read`);
    },

    markAllAsRead: async (): Promise<void> => {
        await apiClient.put('/notifications/read-all');
    },

    // Templates (admin only)
    getTemplates: async (): Promise<NotificationTemplate[]> => {
        const response = await apiClient.get<ApiResponse<NotificationTemplate[]>>('/notifications/templates');
        return response.data.data;
    },

    createTemplate: async (data: any): Promise<NotificationTemplate> => {
        const response = await apiClient.post<ApiResponse<NotificationTemplate>>('/notifications/templates', data);
        return response.data.data;
    },

    updateTemplate: async (id: string, data: any): Promise<NotificationTemplate> => {
        const response = await apiClient.put<ApiResponse<NotificationTemplate>>(`/notifications/templates/${id}`, data);
        return response.data.data;
    },

    // Campaigns (admin only)
    getCampaigns: async (): Promise<NotificationCampaign[]> => {
        const response = await apiClient.get<ApiResponse<NotificationCampaign[]>>('/notifications/campaigns');
        return response.data.data;
    },

    createCampaign: async (data: any): Promise<NotificationCampaign> => {
        const response = await apiClient.post<ApiResponse<NotificationCampaign>>('/notifications/campaigns', data);
        return response.data.data;
    },

    sendCampaign: async (id: string): Promise<NotificationCampaign> => {
        const response = await apiClient.post<ApiResponse<NotificationCampaign>>(`/notifications/campaigns/${id}/send`);
        return response.data.data;
    },

    // Send notification to specific customers
    sendToCustomers: async (data: { title: string; body: string; customerIds: string[] }): Promise<void> => {
        await apiClient.post('/notifications/send', data);
    },
};

export default notificationsApi;
