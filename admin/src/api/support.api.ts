import apiClient from './client';
import type { ApiResponse, Ticket, PaginatedResponse } from '@/types';

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
    search?: string;
}

export interface CreateTicketReplyDto {
    content: string;
    attachments?: string[];
}

export const supportApi = {
    // Tickets
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

    // Stats
    getStats: async (): Promise<{
        open: number;
        inProgress: number;
        resolved: number;
        avgResponseTime: number;
    }> => {
        const response = await apiClient.get<ApiResponse<any>>('/support/stats');
        return response.data.data;
    },
};

export default supportApi;
