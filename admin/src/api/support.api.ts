import apiClient from './client';
import type { ApiResponse, Ticket, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface TicketMessage {
    _id: string;
    content: string;
    sender: 'customer' | 'admin';
    senderName: string;
    attachments?: string[];
    createdAt: string;
}

export interface TicketDetails extends Ticket {
    messages: TicketMessage[];
}

export interface TicketsQueryParams {
    page?: number;
    limit?: number;
    status?: string;
    priority?: string;
    category?: string;
    search?: string;
}

export interface CreateTicketReplyDto {
    content: string;
    attachments?: string[];
}

export interface TicketCategory {
    _id: string;
    name: string;
    nameAr: string;
    description?: string;
    icon?: string;
    isActive: boolean;
    order: number;
}

export interface CannedResponse {
    _id: string;
    title: string;
    content: string;
    category?: string;
    isActive: boolean;
    usageCount: number;
    createdBy: string;
    createdAt: string;
}

export interface SupportStats {
    open: number;
    inProgress: number;
    resolved: number;
    avgResponseTime: number;
    todayTickets: number;
    satisfactionRate: number;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const supportApi = {
    // ─────────────────────────────────────────
    // Tickets
    // ─────────────────────────────────────────

    getAllTickets: async (params?: TicketsQueryParams): Promise<PaginatedResponse<Ticket>> => {
        const response = await apiClient.get<any>('/support/tickets', { params });
        // Handle double-wrapped response: data may be { success, data: { tickets, total } } or directly { tickets, total }
        let data = response.data?.data;
        if (data?.data && typeof data.data === 'object' && 'tickets' in data.data) {
            data = data.data;
        }
        if (data && 'tickets' in data) {
            const total = data.total ?? 0;
            const limit = (params?.limit as number) ?? 20;
            const page = (params?.page as number) ?? 1;
            return {
                items: Array.isArray(data.tickets) ? data.tickets : [],
                pagination: {
                    total,
                    page,
                    limit,
                    totalPages: limit > 0 ? Math.ceil(total / limit) : 0,
                    hasNextPage: page * limit < total,
                    hasPreviousPage: page > 1,
                },
            };
        }
        return { items: [] as Ticket[], pagination: { total: 0, page: 1, limit: 20, totalPages: 0, hasNextPage: false, hasPreviousPage: false } };
    },

    getTicket: async (id: string): Promise<TicketDetails> => {
        const response = await apiClient.get<ApiResponse<TicketDetails>>(`/support/tickets/${id}`);
        return response.data.data;
    },

    updateTicketStatus: async (id: string, status: string): Promise<Ticket> => {
        const response = await apiClient.put<ApiResponse<Ticket>>(`/support/tickets/${id}/status`, { status });
        return response.data.data;
    },

    assignTicket: async (id: string, adminId: string): Promise<Ticket> => {
        const response = await apiClient.put<ApiResponse<Ticket>>(`/support/tickets/${id}/assign`, { adminId });
        return response.data.data;
    },

    replyToTicket: async (id: string, data: CreateTicketReplyDto): Promise<TicketMessage> => {
        const response = await apiClient.post<ApiResponse<TicketMessage>>(`/support/tickets/${id}/reply`, data);
        return response.data.data;
    },

    closeTicket: async (id: string): Promise<Ticket> => {
        const response = await apiClient.put<ApiResponse<Ticket>>(`/support/tickets/${id}/close`);
        return response.data.data;
    },

    updatePriority: async (id: string, priority: string): Promise<Ticket> => {
        const response = await apiClient.put<ApiResponse<Ticket>>(`/support/tickets/${id}/priority`, { priority });
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Categories
    // ─────────────────────────────────────────

    getCategories: async (): Promise<TicketCategory[]> => {
        const response = await apiClient.get<any>('/support/categories');
        const data = response.data?.data;
        const arr = data?.data ?? data;
        return Array.isArray(arr) ? arr : [];
    },

    createCategory: async (data: Omit<TicketCategory, '_id'>): Promise<TicketCategory> => {
        const response = await apiClient.post<ApiResponse<TicketCategory>>('/support/categories', data);
        return response.data.data;
    },

    updateCategory: async (id: string, data: Partial<TicketCategory>): Promise<TicketCategory> => {
        const response = await apiClient.put<ApiResponse<TicketCategory>>(`/support/categories/${id}`, data);
        return response.data.data;
    },

    deleteCategory: async (id: string): Promise<void> => {
        await apiClient.delete(`/support/categories/${id}`);
    },

    // ─────────────────────────────────────────
    // Canned Responses
    // ─────────────────────────────────────────

    getCannedResponses: async (): Promise<CannedResponse[]> => {
        const response = await apiClient.get<any>('/support/canned-responses');
        const data = response.data?.data;
        const arr = data?.data ?? data;
        return Array.isArray(arr) ? arr : [];
    },

    createCannedResponse: async (data: Omit<CannedResponse, '_id' | 'usageCount' | 'createdBy' | 'createdAt'>): Promise<CannedResponse> => {
        const response = await apiClient.post<ApiResponse<CannedResponse>>('/support/canned-responses', data);
        return response.data.data;
    },

    updateCannedResponse: async (id: string, data: Partial<CannedResponse>): Promise<CannedResponse> => {
        const response = await apiClient.put<ApiResponse<CannedResponse>>(`/support/canned-responses/${id}`, data);
        return response.data.data;
    },

    deleteCannedResponse: async (id: string): Promise<void> => {
        await apiClient.delete(`/support/canned-responses/${id}`);
    },

    useCannedResponse: async (id: string): Promise<CannedResponse> => {
        const response = await apiClient.post<ApiResponse<CannedResponse>>(`/support/canned-responses/${id}/use`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    getStats: async (): Promise<SupportStats> => {
        const response = await apiClient.get<any>('/support/stats');
        let data = response.data?.data;
        if (data?.data && typeof data.data === 'object') {
            data = data.data;
        }
        if (!data || typeof data !== 'object') {
            return { open: 0, inProgress: 0, resolved: 0, avgResponseTime: 0, todayTickets: 0, satisfactionRate: 0 };
        }
        const byStatus = data.byStatus ?? {};
        return {
            open: byStatus.open ?? 0,
            inProgress: byStatus.in_progress ?? 0,
            resolved: byStatus.resolved ?? 0,
            avgResponseTime: data.avgResolutionTimeMinutes ?? data.avgResponseTime ?? 0,
            todayTickets: data.todayTickets ?? 0,
            satisfactionRate: data.satisfactionRate ?? 0,
        };
    },
};

export default supportApi;

