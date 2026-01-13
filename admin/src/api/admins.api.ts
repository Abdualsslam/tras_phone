import apiClient from './client';
import type { ApiResponse, Admin, PaginatedResponse, Role } from '@/types';

export interface CreateAdminDto {
    userId: string;
    fullName: string;
    fullNameAr?: string;
    department?: string;
    position?: string;
    directPhone?: string;
    extension?: string;
    isSuperAdmin?: boolean;
    canAccessMobile?: boolean;
    canAccessWeb?: boolean;
}

export interface CreateAdminWithUserDto {
    phone: string;
    email?: string;
    password: string;
    fullName: string;
    fullNameAr?: string;
    department?: string;
    position?: string;
    directPhone?: string;
    extension?: string;
    isSuperAdmin?: boolean;
    canAccessMobile?: boolean;
    canAccessWeb?: boolean;
}

export interface UpdateAdminDto {
    fullName?: string;
    fullNameAr?: string;
    department?: string;
    position?: string;
    directPhone?: string;
    extension?: string;
    isSuperAdmin?: boolean;
    canAccessMobile?: boolean;
    canAccessWeb?: boolean;
    employmentStatus?: 'active' | 'on_leave' | 'suspended' | 'terminated';
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
        const response = await apiClient.get('/admins', { params });

        // Transform the response to match expected structure
        return {
            items: response.data.data, // array of admins
            pagination: {
                total: response.data.meta.pagination.total,
                page: response.data.meta.pagination.page,
                limit: response.data.meta.pagination.limit,
                totalPages: response.data.meta.pagination.totalPages,
                hasNextPage: response.data.meta.pagination.hasNextPage,
                hasPreviousPage: response.data.meta.pagination.hasPreviousPage,
            }
        };
    },

    getById: async (id: string): Promise<Admin> => {
        const response = await apiClient.get<ApiResponse<Admin>>(`/admins/${id}`);
        return response.data.data;
    },

    create: async (data: CreateAdminDto): Promise<Admin> => {
        const response = await apiClient.post<ApiResponse<Admin>>('/admins', data);
        return response.data.data;
    },

    createWithUser: async (data: CreateAdminWithUserDto): Promise<Admin> => {
        const response = await apiClient.post<ApiResponse<Admin>>('/admins/create-with-user', data);
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
