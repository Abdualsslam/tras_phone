import apiClient from './client';
import type { ApiResponse, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface AuditLog {
    _id: string;
    action: string;
    resource: string;
    resourceId?: string;
    actorType: 'admin' | 'system' | 'customer';
    actorId?: string;
    actorName?: string;
    details?: Record<string, any>;
    ipAddress?: string;
    userAgent?: string;
    createdAt: string;
}

export interface LoginLog {
    _id: string;
    userId: string;
    userType: 'admin' | 'customer';
    userName?: string;
    email?: string;
    ipAddress: string;
    userAgent?: string;
    deviceInfo?: string;
    location?: string;
    status: 'success' | 'failed' | 'suspicious';
    failureReason?: string;
    createdAt: string;
}

export interface AuditStats {
    totalLogs: number;
    todayLogs: number;
    criticalLogs: number;
    actionBreakdown: { action: string; count: number }[];
    resourceBreakdown: { resource: string; count: number }[];
}

export interface AuditFilters {
    action?: string;
    resource?: string;
    actorType?: string;
    actorId?: string;
    startDate?: string;
    endDate?: string;
    page?: number;
    limit?: number;
}

// ══════════════════════════════════════════════════════════════
// Audit API
// ══════════════════════════════════════════════════════════════

export const auditApi = {
    // ─────────────────────────────────────────
    // Logs
    // ─────────────────────────────────────────

    getLogs: async (params?: AuditFilters): Promise<PaginatedResponse<AuditLog>> => {
        const response = await apiClient.get<ApiResponse<any>>('/audit/logs', { params });
        const data = response.data.data;
        const logs = Array.isArray(data) ? data : (data?.items || data?.logs || []);
        const meta = (response.data as any).meta || data?.pagination || {};

        return {
            items: logs,
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || logs.length,
                totalPages: meta.pages || meta.totalPages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || meta.totalPages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    getCriticalLogs: async (): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>('/audit/logs/critical');
        return response.data.data;
    },

    getResourceHistory: async (resource: string, id: string): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>(`/audit/logs/resource/${resource}/${id}`);
        return response.data.data;
    },

    getActorActivity: async (type: string, id: string): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>(`/audit/logs/actor/${type}/${id}`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Activities
    // ─────────────────────────────────────────

    getRecentActivities: async (): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>('/audit/activities');
        return response.data.data;
    },

    getMyActivities: async (): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>('/audit/activities/my');
        return response.data.data;
    },

    getAdminActivities: async (adminId: string): Promise<AuditLog[]> => {
        const response = await apiClient.get<ApiResponse<AuditLog[]>>(`/audit/activities/admin/${adminId}`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Logins
    // ─────────────────────────────────────────

    getLoginHistory: async (): Promise<LoginLog[]> => {
        const response = await apiClient.get<ApiResponse<LoginLog[]>>('/audit/logins');
        return response.data.data;
    },

    getMyLogins: async (): Promise<LoginLog[]> => {
        const response = await apiClient.get<ApiResponse<LoginLog[]>>('/audit/logins/my');
        return response.data.data;
    },

    getSuspiciousLogins: async (): Promise<LoginLog[]> => {
        const response = await apiClient.get<ApiResponse<LoginLog[]>>('/audit/logins/suspicious');
        return response.data.data;
    },

    getFailedLogins: async (): Promise<LoginLog[]> => {
        const response = await apiClient.get<ApiResponse<LoginLog[]>>('/audit/logins/failed');
        return response.data.data;
    },

    getLoginsByIp: async (ip: string): Promise<LoginLog[]> => {
        const response = await apiClient.get<ApiResponse<LoginLog[]>>(`/audit/logins/ip/${encodeURIComponent(ip)}`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    getStats: async (): Promise<AuditStats> => {
        const response = await apiClient.get<ApiResponse<AuditStats>>('/audit/stats');
        return response.data.data;
    },
};

export default auditApi;
