import apiClient from './client';
import type { ApiResponse, Customer, PaginatedResponse } from '@/types';

export interface CreateCustomerDto {
    companyName: string;
    contactName: string;
    email: string;
    phone: string;
    address?: {
        street?: string;
        city?: string;
        state?: string;
        country?: string;
        postalCode?: string;
    };
    taxNumber?: string;
    commercialRegister?: string;
}

export interface UpdateCustomerDto extends Partial<CreateCustomerDto> {
    status?: 'pending' | 'approved' | 'rejected' | 'suspended';
}

export interface CustomersQueryParams {
    page?: number;
    limit?: number;
    search?: string;
    status?: string;
}

// Transform backend customer to frontend Customer type
const transformCustomer = (customer: any): Customer => {
    return {
        _id: customer._id || customer.id,
        companyName: customer.companyName || customer.shopName || customer.shopNameAr || '',
        contactName: customer.contactName || customer.responsiblePersonName || '',
        email: customer.contactEmail || customer.userId?.email || '',
        phone: customer.contactPhone || customer.userId?.phone || '',
        phoneNormalized: customer.phoneNormalized || '',
        status: customer.status || 'pending',
        address: customer.address,
        taxNumber: customer.taxNumber,
        commercialRegister: customer.commercialRegister,
        tier: customer.loyaltyTier,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
    };
};

export const customersApi = {
    getAll: async (params?: CustomersQueryParams): Promise<PaginatedResponse<Customer>> => {
        const response = await apiClient.get<ApiResponse<Customer[]>>('/customers', { params });

        // Transform backend response to expected format
        const customers = response.data.data || [];
        const meta = (response.data as any).meta || {};

        return {
            items: customers.map(transformCustomer),
            pagination: {
                page: Number(meta.page) || 1,
                limit: Number(meta.limit) || 20,
                total: meta.total || customers.length,
                totalPages: meta.pages || 1,
                hasNextPage: (Number(meta.page) || 1) < (meta.pages || 1),
                hasPreviousPage: (Number(meta.page) || 1) > 1,
            },
        };
    },

    getById: async (id: string): Promise<Customer> => {
        const response = await apiClient.get<ApiResponse<Customer>>(`/customers/${id}`);
        return response.data.data;
    },

    create: async (data: CreateCustomerDto): Promise<Customer> => {
        const response = await apiClient.post<ApiResponse<Customer>>('/customers', data);
        return response.data.data;
    },

    update: async (id: string, data: UpdateCustomerDto): Promise<Customer> => {
        const response = await apiClient.put<ApiResponse<Customer>>(`/customers/${id}`, data);
        return response.data.data;
    },

    approve: async (id: string): Promise<Customer> => {
        const response = await apiClient.post<ApiResponse<Customer>>(`/customers/${id}/approve`);
        return response.data.data;
    },

    reject: async (id: string): Promise<Customer> => {
        const response = await apiClient.post<ApiResponse<Customer>>(`/customers/${id}/reject`);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/customers/${id}`);
    },
};

export default customersApi;
