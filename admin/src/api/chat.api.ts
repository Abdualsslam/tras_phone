import apiClient from './client';
import type { ApiResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface ChatSession {
    _id: string;
    customerId: string;
    customer?: {
        _id: string;
        companyName: string;
        contactName: string;
    };
    agentId?: string;
    agent?: {
        _id: string;
        name: string;
    };
    status: 'waiting' | 'active' | 'ended';
    currentPage?: string;
    rating?: number;
    ratingComment?: string;
    startedAt: string;
    endedAt?: string;
    lastMessageAt?: string;
    unreadCount?: number;
}

export interface ChatMessage {
    _id: string;
    sessionId: string;
    sender: 'customer' | 'agent';
    senderName?: string;
    content: string;
    attachments?: string[];
    isRead: boolean;
    createdAt: string;
}

export interface ChatStats {
    waiting: number;
    active: number;
    todayEnded: number;
    avgResponseTime: number;
    avgRating: number;
}

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const chatApi = {
    // ─────────────────────────────────────────
    // Agent Operations
    // ─────────────────────────────────────────

    getWaitingSessions: async (): Promise<ChatSession[]> => {
        const response = await apiClient.get<ApiResponse<ChatSession[]>>('/chat/admin/waiting');
        return response.data.data;
    },

    getMySessions: async (): Promise<ChatSession[]> => {
        const response = await apiClient.get<ApiResponse<ChatSession[]>>('/chat/admin/my-sessions');
        return response.data.data;
    },

    getStats: async (): Promise<ChatStats> => {
        const response = await apiClient.get<ApiResponse<ChatStats>>('/chat/admin/stats');
        return response.data.data;
    },

    acceptSession: async (sessionId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/accept`);
        return response.data.data;
    },

    getSession: async (sessionId: string): Promise<{ session: ChatSession; messages: ChatMessage[] }> => {
        const response = await apiClient.get<ApiResponse<{ session: ChatSession; messages: ChatMessage[] }>>(`/chat/admin/${sessionId}`);
        return response.data.data;
    },

    sendMessage: async (sessionId: string, content: string): Promise<ChatMessage> => {
        const response = await apiClient.post<ApiResponse<ChatMessage>>(`/chat/admin/${sessionId}/messages`, { content });
        return response.data.data;
    },

    transferSession: async (sessionId: string, agentId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/transfer`, { agentId });
        return response.data.data;
    },

    endSession: async (sessionId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/end`);
        return response.data.data;
    },

    markAsRead: async (sessionId: string): Promise<void> => {
        await apiClient.put(`/chat/admin/${sessionId}/read`);
    },
};

export default chatApi;
