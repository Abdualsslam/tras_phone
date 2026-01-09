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
        const response = await apiClient.get<ApiResponse<PaginatedResponse<Ticket>>>('/support/tickets', { params });
        return response.data.data;
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
        const response = await apiClient.get<ApiResponse<TicketCategory[]>>('/support/categories');
        return response.data.data;
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
        const response = await apiClient.get<ApiResponse<CannedResponse[]>>('/support/canned-responses');
        return response.data.data;
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
        const response = await apiClient.get<ApiResponse<SupportStats>>('/support/stats');
        return response.data.data;
    },
};

export default supportApi;

