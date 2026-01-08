import apiClient from './client';
import type { ApiResponse, LoginRequest, LoginResponse, Admin } from '@/types';

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
};

export default authApi;
