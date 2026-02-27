import apiClient from './client';
import type { ApiResponse, PaginatedResponse, PaginationMeta } from '@/types';

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface WalletBalance {
    balance: number;
    currency: string;
    points: number;
    tier: string;
}

export interface WalletTransaction {
    _id: string;
    transactionNumber?: string;
    customerId: string;
    customerName?: string;
    type: 'credit' | 'debit';
    direction?: 'credit' | 'debit';
    transactionType?: string;
    amount: number;
    balanceBefore: number;
    balanceAfter: number;
    description: string;
    reference?: string;
    referenceNumber?: string;
    createdAt: string;
}

export interface LoyaltyTier {
    _id: string;
    name: string;
    nameAr: string;
    code: string;
    description?: string;
    descriptionAr?: string;
    minPoints: number;
    minSpend?: number;
    minOrders?: number;
    pointsMultiplier: number;
    discountPercentage: number;
    freeShipping: boolean;
    prioritySupport: boolean;
    earlyAccess: boolean;
    customBenefits?: string[];
    icon?: string;
    color?: string;
    badgeImage?: string;
    displayOrder: number;
    isActive: boolean;
    createdAt?: string;
    updatedAt?: string;
}

export interface CreditDebitDto {
    customerId: string;
    amount: number;
    description: string;
    reference?: string;
}

export interface GrantPointsDto {
    customerId: string;
    points: number;
    reason: string;
}

export interface LoyaltyPointsTransaction {
    _id: string;
    transactionNumber?: string;
    points: number;
    pointsBefore?: number;
    pointsAfter?: number;
    description?: string;
    createdAt?: string;
}

export interface AdminTransactionsParams {
    customerId?: string;
    type?: 'credit' | 'debit';
    transactionType?: string;
    search?: string;
    reference?: string;
    startDate?: string;
    endDate?: string;
    page?: number;
    limit?: number;
}

const fallbackPagination = (page: number, limit: number, total: number): PaginationMeta => {
    const totalPages = Math.max(1, Math.ceil(total / Math.max(1, limit)));
    return {
        page,
        limit,
        total,
        totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
    };
};

const mapWalletTransaction = (tx: any): WalletTransaction => ({
    _id: tx._id,
    transactionNumber: tx.transactionNumber,
    customerId: tx.customerId,
    customerName: tx.customerName,
    type: tx.type || tx.direction,
    direction: tx.direction,
    transactionType: tx.transactionType,
    amount: tx.amount,
    balanceBefore: tx.balanceBefore,
    balanceAfter: tx.balanceAfter,
    description: tx.description || tx.transactionType || '-',
    reference: tx.reference || tx.referenceNumber,
    referenceNumber: tx.referenceNumber,
    createdAt: tx.createdAt,
});

// ══════════════════════════════════════════════════════════════
// Wallet API
// ══════════════════════════════════════════════════════════════

export const walletApi = {
    // ─────────────────────────────────────────
    // Customer Wallet Operations
    // ─────────────────────────────────────────

    getCustomerBalance: async (customerId: string): Promise<WalletBalance> => {
        const response = await apiClient.get<ApiResponse<WalletBalance>>(`/wallet/balance/${customerId}`);
        return response.data.data;
    },

    getCustomerTransactions: async (customerId: string): Promise<WalletTransaction[]> => {
        const response = await apiClient.get<ApiResponse<any[]>>(`/wallet/transactions/${customerId}`);
        return (response.data.data || []).map(mapWalletTransaction);
    },

    // ─────────────────────────────────────────
    // Admin Operations
    // ─────────────────────────────────────────

    creditWallet: async (data: CreditDebitDto): Promise<WalletTransaction> => {
        const response = await apiClient.post<ApiResponse<any>>('/wallet/credit', data);
        return mapWalletTransaction(response.data.data);
    },

    debitWallet: async (data: CreditDebitDto): Promise<WalletTransaction> => {
        const response = await apiClient.post<ApiResponse<any>>('/wallet/debit', data);
        return mapWalletTransaction(response.data.data);
    },

    grantPoints: async (data: GrantPointsDto): Promise<LoyaltyPointsTransaction> => {
        const response = await apiClient.post<ApiResponse<LoyaltyPointsTransaction>>('/wallet/points/grant', data);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Loyalty Tiers
    // ─────────────────────────────────────────

    getTiers: async (): Promise<LoyaltyTier[]> => {
        const response = await apiClient.get<ApiResponse<LoyaltyTier[]>>('/wallet/tiers');
        return response.data.data;
    },

    getAllTiers: async (): Promise<LoyaltyTier[]> => {
        const response = await apiClient.get<ApiResponse<LoyaltyTier[]>>('/wallet/admin/tiers');
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Admin: All Transactions
    // ─────────────────────────────────────────

    getAllTransactions: async (
        params?: AdminTransactionsParams,
    ): Promise<PaginatedResponse<WalletTransaction>> => {
        const response = await apiClient.get<ApiResponse<any[]>>('/wallet/admin/transactions', { params });
        const items = (response.data.data || []).map(mapWalletTransaction);
        const pagination = response.data.meta?.pagination ||
            fallbackPagination(params?.page || 1, params?.limit || items.length || 1, items.length);

        return {
            items,
            pagination,
        };
    },

    getWalletStats: async (): Promise<WalletStats> => {
        const response = await apiClient.get<ApiResponse<WalletStats>>('/wallet/admin/stats');
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Loyalty Tiers Management
    // ─────────────────────────────────────────

    createTier: async (data: Omit<LoyaltyTier, '_id'>): Promise<LoyaltyTier> => {
        const response = await apiClient.post<ApiResponse<LoyaltyTier>>('/wallet/admin/tiers', data);
        return response.data.data;
    },

    updateTier: async (id: string, data: Partial<LoyaltyTier>): Promise<LoyaltyTier> => {
        const response = await apiClient.put<ApiResponse<LoyaltyTier>>(`/wallet/admin/tiers/${id}`, data);
        return response.data.data;
    },

    deleteTier: async (id: string): Promise<void> => {
        await apiClient.delete(`/wallet/admin/tiers/${id}`);
    },
};

export interface WalletStats {
    totalBalance: number;
    totalCredits: number;
    totalDebits: number;
    transactionCount: number;
    activeWallets: number;
    totalPoints: number;
    averageBalance: number;
}

export default walletApi;
