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
    nameAr?: string;
    minPoints: number;
    maxPoints?: number;
    benefits: string[];
    multiplier: number;
    isActive: boolean;
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
};

export default walletApi;
