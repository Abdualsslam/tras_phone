import apiClient from './client';
import type { ApiResponse, LoginRequest, LoginResponse, Admin, PaginatedResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Password Reset Request Types
// ══════════════════════════════════════════════════════════════

export interface PasswordResetRequest {
    _id: string;
    requestNumber: string;
    customerId: {
        _id: string;
        phone: string;
        email?: string;
    };
    phone: string;
    status: 'pending' | 'completed' | 'rejected';
    temporaryPassword?: string;
    temporaryPasswordPlain?: string;
    processedBy?: {
        _id: string;
        fullName: string;
        email: string;
    };
    processedAt?: string;
    rejectionReason?: string;
    customerNotes?: string;
    adminNotes?: string;
    createdAt: string;
    updatedAt: string;
}

export interface ProcessPasswordResetDto {
    adminNotes?: string;
}

export interface RejectPasswordResetDto {
    rejectionReason: string;
    adminNotes?: string;
}

export const authApi = {
    login: async (data: LoginRequest): Promise<LoginResponse> => {
        const response = await apiClient.post<ApiResponse<LoginResponse>>('/auth/admin/login', data);
        return response.data.data;
    },

    logout: async (): Promise<void> => {
        await apiClient.post('/auth/logout');
    },

    refreshToken: async (refreshToken: string): Promise<{ accessToken: string; refreshToken: string }> => {
        const response = await apiClient.post<ApiResponse<{ accessToken: string; refreshToken: string }>>(
            '/auth/refresh',
            { refreshToken }
        );
        return response.data.data;
    },

    getProfile: async (): Promise<Admin> => {
        const response = await apiClient.get<ApiResponse<Admin>>('/auth/me');
        return response.data.data;
    },

    // ══════════════════════════════════════════════════════════════
    // Password Reset Requests (Admin)
    // ══════════════════════════════════════════════════════════════

    getPasswordResetRequests: async (params?: {
        status?: string;
        customerId?: string;
        page?: number;
        limit?: number;
    }): Promise<PaginatedResponse<PasswordResetRequest>> => {
        const response = await apiClient.get<ApiResponse<any>>('/auth/admin/password-reset-requests', { params });
        const data = response.data.data;
        const requests = Array.isArray(data) ? data : (data?.items || data?.data || []);
        const total = data?.total || requests.length;

        return {
            items: requests,
            pagination: {
                page: params?.page || 1,
                limit: params?.limit || 20,
                total,
                totalPages: Math.ceil(total / (params?.limit || 20)),
                hasNextPage: (params?.page || 1) * (params?.limit || 20) < total,
                hasPreviousPage: (params?.page || 1) > 1,
            },
        };
    },

    getPasswordResetRequestById: async (id: string): Promise<PasswordResetRequest> => {
        const response = await apiClient.get<ApiResponse<PasswordResetRequest>>(`/auth/admin/password-reset-requests/${id}`);
        return response.data.data;
    },

    processPasswordResetRequest: async (id: string, data: ProcessPasswordResetDto): Promise<{ request: PasswordResetRequest; temporaryPassword: string }> => {
        const response = await apiClient.post<ApiResponse<{ request: PasswordResetRequest; temporaryPassword: string }>>(
            `/auth/admin/password-reset-requests/${id}/process`,
            data
        );
        return response.data.data;
    },

    rejectPasswordResetRequest: async (id: string, data: RejectPasswordResetDto): Promise<PasswordResetRequest> => {
        const response = await apiClient.post<ApiResponse<PasswordResetRequest>>(
            `/auth/admin/password-reset-requests/${id}/reject`,
            data
        );
        return response.data.data;
    },
};

export default authApi;
