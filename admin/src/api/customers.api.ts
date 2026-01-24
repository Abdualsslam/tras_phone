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
    // User fields
    phone?: string;
    email?: string;
    userStatus?: 'pending' | 'active' | 'suspended' | 'deleted';
    
    // Customer status (for approve/reject)
    status?: 'pending' | 'approved' | 'rejected' | 'suspended';
    
    // Additional Customer fields
    walletBalance?: number;
    loyaltyPoints?: number;
    loyaltyTier?: 'bronze' | 'silver' | 'gold' | 'platinum';
    assignedSalesRepId?: string;
    riskScore?: number;
    isFlagged?: boolean;
    flagReason?: string;
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
        status: customer.status || (customer.approvedAt ? 'approved' : customer.rejectionReason ? 'rejected' : 'pending'),
        address: customer.address,
        taxNumber: customer.taxNumber,
        commercialRegister: customer.commercialLicenseNumber,
        tier: customer.loyaltyTier,
        customerCode: customer.customerCode,
        businessType: customer.businessType,
        cityId: customer.cityId,
        priceLevelId: customer.priceLevelId,
        creditLimit: customer.creditLimit,
        creditUsed: customer.creditUsed,
        availableCredit: customer.availableCredit,
        walletBalance: customer.walletBalance,
        loyaltyPoints: customer.loyaltyPoints,
        loyaltyTier: customer.loyaltyTier,
        totalOrders: customer.totalOrders,
        totalSpent: customer.totalSpent,
        averageOrderValue: customer.averageOrderValue,
        lastOrderAt: customer.lastOrderAt,
        nationalId: customer.nationalId,
        approvedAt: customer.approvedAt,
        internalNotes: customer.internalNotes,
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
        const response = await apiClient.get<ApiResponse<any>>(`/customers/${id}`);
        return transformCustomer(response.data.data);
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

    reject: async (id: string, reason?: string): Promise<Customer> => {
        const response = await apiClient.patch<ApiResponse<Customer>>(
            `/customers/${id}/reject`,
            { reason: reason || 'تم الرفض من قبل الإدارة' }
        );
        return response.data.data;
    },

    delete: async (id: string): Promise<void> => {
        await apiClient.delete(`/customers/${id}`);
    },

    // ═════════════════════════════════════
    // Lookup methods for Add Customer dialog
    // ═════════════════════════════════════

    getCities: async (): Promise<City[]> => {
        try {
            // Try settings endpoint first (admin - returns all cities)
            const response = await apiClient.get<ApiResponse<City[]>>('/settings/admin/cities');
            const data = response.data.data;
            // Handle nested response: response.data.data.data
            if (data && typeof data === 'object' && 'data' in data) {
                const cities = (data as any).data;
                return Array.isArray(cities) ? cities : [];
            }
            const cities = Array.isArray(data) ? data : [];
            if (cities.length > 0) return cities;
        } catch (error) {
            // Fallback to locations endpoint if settings endpoint fails
            console.warn('Settings cities endpoint failed, trying locations endpoint', error);
        }
        
        // Fallback to locations endpoint (public - returns only active cities)
        try {
            const response = await apiClient.get<ApiResponse<City[]>>('/locations/cities');
            const data = response.data.data;
            // Handle nested response: response.data.data.data
            if (data && typeof data === 'object' && 'data' in data) {
                const cities = (data as any).data;
                return Array.isArray(cities) ? cities : [];
            }
            return Array.isArray(data) ? data : [];
        } catch (error) {
            console.error('Both cities endpoints failed', error);
            return [];
        }
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

    // ═════════════════════════════════════
    // Customer Addresses
    // ═════════════════════════════════════

    getAddresses: async (customerId: string): Promise<CustomerAddress[]> => {
        const response = await apiClient.get<ApiResponse<CustomerAddress[]>>(`/customers/${customerId}/addresses`);
        return response.data.data;
    },

    createAddress: async (customerId: string, data: CreateAddressDto): Promise<CustomerAddress> => {
        const response = await apiClient.post<ApiResponse<CustomerAddress>>(`/customers/${customerId}/addresses`, data);
        return response.data.data;
    },

    updateAddress: async (customerId: string, addressId: string, data: Partial<CreateAddressDto>): Promise<CustomerAddress> => {
        const response = await apiClient.put<ApiResponse<CustomerAddress>>(`/customers/${customerId}/addresses/${addressId}`, data);
        return response.data.data;
    },

    deleteAddress: async (customerId: string, addressId: string): Promise<void> => {
        await apiClient.delete(`/customers/${customerId}/addresses/${addressId}`);
    },

    // ═════════════════════════════════════
    // Customer Statistics
    // ═════════════════════════════════════

    getStats: async (): Promise<CustomerStats> => {
        const response = await apiClient.get<ApiResponse<CustomerStats>>('/customers/stats');
        return response.data.data;
    },
};

// Additional Types
export interface CustomerAddress {
    _id: string;
    label: string;
    type: 'shipping' | 'billing' | 'both';
    addressLine1: string;
    addressLine2?: string;
    city: string;
    cityId?: string;
    country: string;
    countryId?: string;
    postalCode?: string;
    phone?: string;
    latitude?: number;
    longitude?: number;
    isDefault: boolean;
    createdAt: string;
}

export interface CreateAddressDto {
    label: string;
    type: 'shipping' | 'billing' | 'both';
    addressLine1: string;
    addressLine2?: string;
    city: string;
    cityId?: string;
    country: string;
    countryId?: string;
    postalCode?: string;
    phone?: string;
    latitude?: number;
    longitude?: number;
    isDefault?: boolean;
}

export interface CustomerStats {
    total: number;
    pending: number;
    approved: number;
    rejected: number;
    suspended: number;
    newThisMonth: number;
    activeThisMonth: number;
}

export default customersApi;

