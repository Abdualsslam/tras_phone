import apiClient from './client';
import type { ApiResponse } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface UploadedFile {
    url: string;
    key: string;
    filename: string;
    mimetype: string;
    size: number;
}

export interface UploadSingleDto {
    base64: string;
    filename: string;
    folder?: string;
}

export interface UploadMultipleDto {
    files: Array<{ base64: string; filename: string }>;
    folder?: string;
}

// ══════════════════════════════════════════════════════════════
// Helper Functions
// ══════════════════════════════════════════════════════════════

/**
 * Convert a File to base64 string with data URI prefix
 */
export const fileToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result as string);
        reader.onerror = (error) => reject(error);
    });
};

/**
 * Validate file type
 */
export const isValidImageType = (file: File): boolean => {
    const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
    return validTypes.includes(file.type);
};

export const isValidVideoType = (file: File): boolean => {
    const validTypes = ['video/mp4', 'video/webm', 'video/quicktime'];
    return validTypes.includes(file.type);
};

/**
 * Validate file size (max 10MB)
 */
export const isValidFileSize = (file: File, maxSizeMB: number = 10): boolean => {
    return file.size <= maxSizeMB * 1024 * 1024;
};

// ══════════════════════════════════════════════════════════════
// API
// ══════════════════════════════════════════════════════════════

export const uploadsApi = {
    /**
     * Upload a single file
     */
    uploadSingle: async (file: File, folder: string = 'products'): Promise<UploadedFile> => {
        const base64 = await fileToBase64(file);
        const response = await apiClient.post<ApiResponse<UploadedFile>>('/uploads/single', {
            base64,
            filename: file.name,
            folder,
        });
        // Handle nested response: response.data.data.data
        const data = response.data.data;
        if (data && typeof data === 'object' && 'data' in data) {
            return (data as any).data as UploadedFile;
        }
        return data as UploadedFile;
    },

    /**
     * Upload a single file from base64
     */
    uploadBase64: async (base64: string, filename: string, folder: string = 'products'): Promise<UploadedFile> => {
        const response = await apiClient.post<ApiResponse<UploadedFile>>('/uploads/single', {
            base64,
            filename,
            folder,
        });
        // Handle nested response: response.data.data.data
        const data = response.data.data;
        if (data && typeof data === 'object' && 'data' in data) {
            return (data as any).data as UploadedFile;
        }
        return data as UploadedFile;
    },

    /**
     * Upload multiple files
     */
    uploadMultiple: async (files: File[], folder: string = 'products'): Promise<UploadedFile[]> => {
        const filesData = await Promise.all(
            files.map(async (file) => ({
                base64: await fileToBase64(file),
                filename: file.name,
            }))
        );
        const response = await apiClient.post<ApiResponse<UploadedFile[]>>('/uploads/multiple', {
            files: filesData,
            folder,
        });
        // Handle nested response: response.data.data.data
        const data = response.data.data;
        if (data && typeof data === 'object' && 'data' in data) {
            const files = (data as any).data;
            return Array.isArray(files) ? files : [];
        }
        return Array.isArray(data) ? data : [];
    },

    /**
     * Delete a file by key
     */
    deleteFile: async (key: string): Promise<void> => {
        await apiClient.delete(`/uploads/${encodeURIComponent(key)}`);
    },
};

export default uploadsApi;
