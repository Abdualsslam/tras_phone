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
        return extractArrayData<ChatSession>(response.data.data);
    },

    getMySessions: async (): Promise<ChatSession[]> => {
        const response = await apiClient.get<ApiResponse<ChatSession[]>>('/chat/admin/my-sessions');
        return extractArrayData<ChatSession>(response.data.data);
    },

    getStats: async (): Promise<ChatStats> => {
        const response = await apiClient.get<ApiResponse<ChatStats>>('/chat/admin/stats');
        return extractData<ChatStats>(response.data.data);
    },

    acceptSession: async (sessionId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/accept`);
        return extractData<ChatSession>(response.data.data);
    },

    getSession: async (sessionId: string): Promise<{ session: ChatSession; messages: ChatMessage[] }> => {
        const response = await apiClient.get<ApiResponse<{ session: ChatSession; messages: ChatMessage[] }>>(`/chat/admin/${sessionId}`);
        const data = extractData<{ session: ChatSession; messages: ChatMessage[] } | { data: { session: ChatSession; messages: ChatMessage[] } }>(response.data.data);
        // Handle double nesting
        if (data && typeof data === 'object' && 'data' in data) {
            return (data as any).data;
        }
        // Ensure messages is an array
        if (data && typeof data === 'object' && 'messages' in data) {
            const messages = (data as any).messages;
            return {
                ...data as any,
                messages: Array.isArray(messages) ? messages : []
            };
        }
        return data as { session: ChatSession; messages: ChatMessage[] };
    },

    sendMessage: async (sessionId: string, content: string): Promise<ChatMessage> => {
        const response = await apiClient.post<ApiResponse<ChatMessage>>(`/chat/admin/${sessionId}/messages`, { content });
        return extractData<ChatMessage>(response.data.data);
    },

    transferSession: async (sessionId: string, agentId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/transfer`, { agentId });
        return extractData<ChatSession>(response.data.data);
    },

    endSession: async (sessionId: string): Promise<ChatSession> => {
        const response = await apiClient.post<ApiResponse<ChatSession>>(`/chat/admin/${sessionId}/end`);
        return extractData<ChatSession>(response.data.data);
    },

    markAsRead: async (sessionId: string): Promise<void> => {
        await apiClient.put(`/chat/admin/${sessionId}/read`);
    },
};

export default chatApi;
