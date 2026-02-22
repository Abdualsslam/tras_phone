import apiClient from './client';
import type { ApiResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface Permission {
    _id: string;
    name: string;
    description: string;
    module: string;
    action: string;
}

export interface Role {
    _id: string;
    name: string;
    nameAr?: string;
    description?: string;
    descriptionAr?: string;
    permissions?: string[] | Permission[];
    isSystem: boolean;
    isActive: boolean;
    createdAt: string;
    updatedAt: string;
}

export interface CreateRoleDto {
    name: string;
    nameAr?: string;
    description?: string;
    permissions?: string[];
    isActive?: boolean;
}

// ══════════════════════════════════════════════════════════════
// Roles API
// ══════════════════════════════════════════════════════════════

export const rolesApi = {
    // ─────────────────────────────────────────
    // Roles CRUD
    // ─────────────────────────────────────────

    getAll: async (): Promise<Role[]> => {
        const response = await apiClient.get<ApiResponse<Role[]>>('/roles');
        return response.data.data;
    },

    getById: async (id: string): Promise<Role> => {
        const response = await apiClient.get<ApiResponse<Role>>(`/roles/${id}`);
        return response.data.data;
    },

    create: async (data: CreateRoleDto): Promise<Role> => {
        const response = await apiClient.post<ApiResponse<Role>>('/roles', data);
        return response.data.data;
    },

    update: async (id: string, data: Partial<CreateRoleDto>): Promise<Role> => {
        const response = await apiClient.put<ApiResponse<Role>>(`/roles/${id}`, data);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/roles/${id}`);
    },

    // ─────────────────────────────────────────
    // Permissions
    // ─────────────────────────────────────────

    getPermissions: async (roleId: string): Promise<Permission[]> => {
        const response = await apiClient.get<ApiResponse<Permission[]>>(`/roles/${roleId}/permissions`);
        return response.data.data;
    },

    setPermissions: async (roleId: string, permissions: string[]): Promise<Role> => {
        const response = await apiClient.post<ApiResponse<Role>>(`/roles/${roleId}/permissions`, { permissionIds: permissions });
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // All Permissions
    // ─────────────────────────────────────────

    getAllPermissions: async (): Promise<Permission[]> => {
        const response = await apiClient.get<ApiResponse<Permission[]>>('/roles/permissions');
        return response.data.data;
    },
};

export default rolesApi;
