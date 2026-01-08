import apiClient from './client';
import type { ApiResponse, Admin, PaginatedResponse, Role } from '@/types';

export interface CreateAdminDto {
    name: string;
    email: string;
    password: string;
    phone?: string;
    department?: string;
}

export interface UpdateAdminDto {
    name?: string;
    email?: string;
    phone?: string;
    department?: string;
    employmentStatus?: 'active' | 'inactive' | 'suspended';
}

export interface AdminsQueryParams {
    page?: number;
    limit?: number;
    search?: string;
    department?: string;
    employmentStatus?: string;
}

export const adminsApi = {
    getAll: async (params?: AdminsQueryParams): Promise<PaginatedResponse<Admin>> => {
        const response = await apiClient.get<ApiResponse<PaginatedResponse<Admin>>>('/admins', { params });
        return response.data.data;
    },

    getById: async (id: string): Promise<Admin> => {
        const response = await apiClient.get<ApiResponse<Admin>>(`/admins/${id}`);
        return response.data.data;
    },

    create: async (data: CreateAdminDto): Promise<Admin> => {
        const response = await apiClient.post<ApiResponse<Admin>>('/admins', data);
        return response.data.data;
    },

    update: async (id: string, data: UpdateAdminDto): Promise<Admin> => {
        const response = await apiClient.put<ApiResponse<Admin>>(`/admins/${id}`, data);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/admins/${id}`);
    },

    getRoles: async (id: string): Promise<Role[]> => {
        const response = await apiClient.get<ApiResponse<Role[]>>(`/admins/${id}/roles`);
        return response.data.data;
    },

    assignRole: async (id: string, roleId: string): Promise<void> => {
        await apiClient.post(`/admins/${id}/roles`, { roleId });
    },

    removeRole: async (id: string, roleId: string): Promise<void> => {
        await apiClient.delete(`/admins/${id}/roles/${roleId}`);
    },
};

export default adminsApi;
