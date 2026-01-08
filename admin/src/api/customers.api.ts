import apiClient from './client';
import type { ApiResponse, Customer, PaginatedResponse } from '@/types';

// Backend-aligned CreateCustomerDto
export interface CreateCustomerDto {
    userId: string;
    responsiblePersonName: string;
    shopName: string;
    shopNameAr?: string;
    businessType?: 'shop' | 'technician' | 'distributor' | 'other';
    cityId: string;
    marketId?: string;
    address?: string;
    latitude?: number;
    longitude?: number;
    commercialLicenseFile?: string;
    commercialLicenseNumber?: string;
    commercialLicenseExpiry?: string;
    taxNumber?: string;
    nationalId?: string;
    priceLevelId: string;
    creditLimit?: number;
    preferredPaymentMethod?: 'cod' | 'bank_transfer' | 'wallet';
    preferredShippingTime?: string;
    preferredContactMethod?: 'phone' | 'whatsapp' | 'email';
    instagramHandle?: string;
    twitterHandle?: string;
    birthDate?: string;
    internalNotes?: string;
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

// Lookup types
export interface City {
    _id: string;
    name: string;
    nameAr: string;
}

export interface PriceLevel {
    _id: string;
    name: string;
    nameAr: string;
    code: string;
    discountPercentage: number;
    isDefault?: boolean;
}

export interface AvailableUser {
    _id: string;
    phone: string;
    email?: string;
    createdAt: string;
}

export interface RegisterUserDto {
    phone: string;
    email?: string;
    password: string;
    userType: 'customer';
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
        commercialRegister: customer.commercialLicenseNumber,
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
        return transformCustomer(response.data.data);
    },

    update: async (id: string, data: UpdateCustomerDto): Promise<Customer> => {
        const response = await apiClient.put<ApiResponse<Customer>>(`/customers/${id}`, data);
        return response.data.data;
    },

    approve: async (id: string): Promise<Customer> => {
        const response = await apiClient.patch<ApiResponse<Customer>>(`/customers/${id}/approve`);
        return response.data.data;
    },

    reject: async (id: string): Promise<Customer> => {
        const response = await apiClient.patch<ApiResponse<Customer>>(`/customers/${id}/reject`);
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/customers/${id}`);
    },

    // ═════════════════════════════════════
    // Lookup methods for Add Customer dialog
    // ═════════════════════════════════════

    getCities: async (): Promise<City[]> => {
        const response = await apiClient.get<ApiResponse<City[]>>('/locations/cities');
        return response.data.data || [];
    },

    getPriceLevels: async (): Promise<PriceLevel[]> => {
        const response = await apiClient.get<ApiResponse<PriceLevel[]>>('/products/price-levels');
        return response.data.data || [];
    },

    getAvailableUsers: async (): Promise<AvailableUser[]> => {
        const response = await apiClient.get<ApiResponse<AvailableUser[]>>('/customers/available-users');
        return response.data.data || [];
    },

    registerUser: async (data: RegisterUserDto): Promise<{ user: { _id: string } }> => {
        const response = await apiClient.post<ApiResponse<{ user: { _id: string } }>>('/auth/register', data);
        return response.data.data;
    },
};

export default customersApi;

