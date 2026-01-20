import apiClient from './client';
import type { ApiResponse } from '@/types';

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
    customerId: string;
    customerName?: string;
    type: 'credit' | 'debit';
    amount: number;
    balanceBefore: number;
    balanceAfter: number;
    description: string;
    reference?: string;
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
        const response = await apiClient.get<ApiResponse<WalletTransaction[]>>(`/wallet/transactions/${customerId}`);
        return response.data.data;
    },

    // ─────────────────────────────────────────
    // Admin Operations
    // ─────────────────────────────────────────

    creditWallet: async (data: CreditDebitDto): Promise<WalletTransaction> => {
        const response = await apiClient.post<ApiResponse<WalletTransaction>>('/wallet/credit', data);
        return response.data.data;
    },

    debitWallet: async (data: CreditDebitDto): Promise<WalletTransaction> => {
        const response = await apiClient.post<ApiResponse<WalletTransaction>>('/wallet/debit', data);
        return response.data.data;
    },

    grantPoints: async (data: GrantPointsDto): Promise<void> => {
        await apiClient.post('/wallet/points/grant', data);
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

    getAllTransactions: async (params?: {
        customerId?: string;
        type?: 'credit' | 'debit';
        startDate?: string;
        endDate?: string;
        page?: number;
        limit?: number;
    }): Promise<WalletTransaction[]> => {
        const response = await apiClient.get<ApiResponse<WalletTransaction[]>>('/wallet/admin/transactions', { params });
        return response.data.data;
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
