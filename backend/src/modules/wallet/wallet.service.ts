import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { WalletTransaction, WalletTransactionDocument } from './schemas/wallet-transaction.schema';
import { LoyaltyTier, LoyaltyTierDocument } from './schemas/loyalty-tier.schema';
import { LoyaltyTransaction, LoyaltyTransactionDocument } from './schemas/loyalty-transaction.schema';
import { PointsExpiry, PointsExpiryDocument } from './schemas/points-expiry.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Wallet Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class WalletService {
    constructor(
        @InjectModel(WalletTransaction.name) private walletTxModel: Model<WalletTransactionDocument>,
        @InjectModel(LoyaltyTier.name) private loyaltyTierModel: Model<LoyaltyTierDocument>,
        @InjectModel(LoyaltyTransaction.name) private loyaltyTxModel: Model<LoyaltyTransactionDocument>,
        @InjectModel(PointsExpiry.name) private pointsExpiryModel: Model<PointsExpiryDocument>,
    ) { }

    // ═════════════════════════════════════
    // Wallet Operations
    // ═════════════════════════════════════

    /**
     * Get wallet balance
     */
    async getBalance(customerId: string): Promise<number> {
        const lastTx = await this.walletTxModel
            .findOne({ customerId, status: 'completed' })
            .sort({ createdAt: -1 });

        return lastTx?.balanceAfter || 0;
    }

    /**
     * Credit wallet (add money)
     */
    async credit(data: {
        customerId: string;
        amount: number;
        transactionType: string;
        referenceType?: string;
        referenceId?: string;
        referenceNumber?: string;
        description?: string;
        descriptionAr?: string;
        expiresAt?: Date;
        createdBy?: string;
    }): Promise<WalletTransactionDocument> {
        const balance = await this.getBalance(data.customerId);
        const transactionNumber = await this.generateWalletTxNumber();

        return this.walletTxModel.create({
            transactionNumber,
            customerId: data.customerId,
            transactionType: data.transactionType,
            amount: data.amount,
            direction: 'credit',
            balanceBefore: balance,
            balanceAfter: balance + data.amount,
            referenceType: data.referenceType,
            referenceId: data.referenceId,
            referenceNumber: data.referenceNumber,
            description: data.description,
            descriptionAr: data.descriptionAr,
            expiresAt: data.expiresAt,
            createdBy: data.createdBy,
            status: 'completed',
        });
    }

    /**
     * Debit wallet (remove money)
     */
    async debit(data: {
        customerId: string;
        amount: number;
        transactionType: string;
        referenceType?: string;
        referenceId?: string;
        referenceNumber?: string;
        description?: string;
        descriptionAr?: string;
        createdBy?: string;
    }): Promise<WalletTransactionDocument> {
        const balance = await this.getBalance(data.customerId);

        if (balance < data.amount) {
            throw new BadRequestException('Insufficient wallet balance');
        }

        const transactionNumber = await this.generateWalletTxNumber();

        return this.walletTxModel.create({
            transactionNumber,
            customerId: data.customerId,
            transactionType: data.transactionType,
            amount: data.amount,
            direction: 'debit',
            balanceBefore: balance,
            balanceAfter: balance - data.amount,
            referenceType: data.referenceType,
            referenceId: data.referenceId,
            referenceNumber: data.referenceNumber,
            description: data.description,
            descriptionAr: data.descriptionAr,
            createdBy: data.createdBy,
            status: 'completed',
        });
    }

    /**
     * Get wallet transactions
     */
    async getWalletTransactions(customerId: string, filters?: any): Promise<WalletTransactionDocument[]> {
        const query: any = { customerId, status: 'completed' };
        if (filters?.type) query.transactionType = filters.type;

        return this.walletTxModel.find(query).sort({ createdAt: -1 }).limit(filters?.limit || 50);
    }

    // ═════════════════════════════════════
    // Loyalty Operations
    // ═════════════════════════════════════

    /**
     * Get loyalty points balance
     */
    async getPointsBalance(customerId: string): Promise<number> {
        const lastTx = await this.loyaltyTxModel
            .findOne({ customerId })
            .sort({ createdAt: -1 });

        return lastTx?.pointsAfter || 0;
    }

    /**
     * Earn points
     */
    async earnPoints(data: {
        customerId: string;
        points: number;
        transactionType: string;
        orderAmount?: number;
        multiplier?: number;
        referenceType?: string;
        referenceId?: string;
        referenceNumber?: string;
        description?: string;
        expiresAt?: Date;
        createdBy?: string;
    }): Promise<LoyaltyTransactionDocument> {
        const balance = await this.getPointsBalance(data.customerId);
        const transactionNumber = await this.generateLoyaltyTxNumber();

        const transaction = await this.loyaltyTxModel.create({
            transactionNumber,
            customerId: data.customerId,
            transactionType: data.transactionType,
            points: data.points,
            direction: 'earn',
            pointsBefore: balance,
            pointsAfter: balance + data.points,
            orderAmount: data.orderAmount,
            multiplier: data.multiplier,
            referenceType: data.referenceType,
            referenceId: data.referenceId,
            referenceNumber: data.referenceNumber,
            description: data.description,
            expiresAt: data.expiresAt,
            createdBy: data.createdBy,
        });

        // Track expiry
        if (data.expiresAt) {
            await this.pointsExpiryModel.create({
                customerId: data.customerId,
                transactionId: transaction._id,
                originalPoints: data.points,
                remainingPoints: data.points,
                expiresAt: data.expiresAt,
            });
        }

        return transaction;
    }

    /**
     * Redeem points
     */
    async redeemPoints(data: {
        customerId: string;
        points: number;
        redeemedValue: number;
        referenceType?: string;
        referenceId?: string;
        referenceNumber?: string;
    }): Promise<LoyaltyTransactionDocument> {
        const balance = await this.getPointsBalance(data.customerId);

        if (balance < data.points) {
            throw new BadRequestException('Insufficient loyalty points');
        }

        const transactionNumber = await this.generateLoyaltyTxNumber();

        // Deduct from expiring points first (FIFO)
        await this.deductFromExpiringPoints(data.customerId, data.points);

        return this.loyaltyTxModel.create({
            transactionNumber,
            customerId: data.customerId,
            transactionType: 'order_redeem',
            points: data.points,
            direction: 'redeem',
            pointsBefore: balance,
            pointsAfter: balance - data.points,
            redeemedValue: data.redeemedValue,
            referenceType: data.referenceType,
            referenceId: data.referenceId,
            referenceNumber: data.referenceNumber,
        });
    }

    /**
     * Calculate points for order
     */
    async calculatePointsForOrder(customerId: string, orderAmount: number): Promise<{ points: number; multiplier: number }> {
        const tier = await this.getCustomerTier(customerId);
        const baseRate = 1; // 1 point per 10 SAR
        const multiplier = tier?.pointsMultiplier || 1;

        const points = Math.floor((orderAmount / 10) * multiplier);

        return { points, multiplier };
    }

    /**
     * Get customer tier
     */
    async getCustomerTier(customerId: string): Promise<LoyaltyTierDocument | null> {
        const points = await this.getPointsBalance(customerId);

        return this.loyaltyTierModel
            .findOne({ isActive: true, minPoints: { $lte: points } })
            .sort({ minPoints: -1 });
    }

    /**
     * Get loyalty transactions
     */
    async getLoyaltyTransactions(customerId: string): Promise<LoyaltyTransactionDocument[]> {
        return this.loyaltyTxModel.find({ customerId }).sort({ createdAt: -1 }).limit(50);
    }

    /**
     * Get expiring points
     */
    async getExpiringPoints(customerId: string, withinDays: number = 30): Promise<PointsExpiryDocument[]> {
        const cutoffDate = new Date(Date.now() + withinDays * 24 * 60 * 60 * 1000);

        return this.pointsExpiryModel.find({
            customerId,
            isExpired: false,
            remainingPoints: { $gt: 0 },
            expiresAt: { $lte: cutoffDate },
        }).sort({ expiresAt: 1 });
    }

    // ═════════════════════════════════════
    // Loyalty Tiers
    // ═════════════════════════════════════

    async getTiers(): Promise<LoyaltyTierDocument[]> {
        return this.loyaltyTierModel.find({ isActive: true }).sort({ minPoints: 1 });
    }

    async seedTiers(): Promise<void> {
        const count = await this.loyaltyTierModel.countDocuments();
        if (count > 0) return;

        console.log('Seeding loyalty tiers...');

        const tiers = [
            { name: 'Bronze', nameAr: 'برونزي', code: 'bronze', minPoints: 0, pointsMultiplier: 1, color: '#CD7F32', displayOrder: 1 },
            { name: 'Silver', nameAr: 'فضي', code: 'silver', minPoints: 1000, pointsMultiplier: 1.25, discountPercentage: 2, color: '#C0C0C0', displayOrder: 2 },
            { name: 'Gold', nameAr: 'ذهبي', code: 'gold', minPoints: 5000, pointsMultiplier: 1.5, discountPercentage: 5, freeShipping: true, color: '#FFD700', displayOrder: 3 },
            { name: 'Platinum', nameAr: 'بلاتيني', code: 'platinum', minPoints: 15000, pointsMultiplier: 2, discountPercentage: 10, freeShipping: true, prioritySupport: true, earlyAccess: true, color: '#E5E4E2', displayOrder: 4 },
        ];

        await this.loyaltyTierModel.insertMany(tiers);
        console.log('✅ Loyalty tiers seeded');
    }

    // ═════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════

    private async deductFromExpiringPoints(customerId: string, points: number): Promise<void> {
        let remaining = points;

        const expiringBatches = await this.pointsExpiryModel
            .find({ customerId, isExpired: false, remainingPoints: { $gt: 0 } })
            .sort({ expiresAt: 1 });

        for (const batch of expiringBatches) {
            if (remaining <= 0) break;

            const deduct = Math.min(batch.remainingPoints, remaining);
            batch.remainingPoints -= deduct;
            remaining -= deduct;

            await batch.save();
        }
    }

    private async generateWalletTxNumber(): Promise<string> {
        const date = new Date();
        const prefix = 'WLT';
        const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
        const count = await this.walletTxModel.countDocuments({
            createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
        });
        return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
    }

    private async generateLoyaltyTxNumber(): Promise<string> {
        const date = new Date();
        const prefix = 'LYL';
        const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
        const count = await this.loyaltyTxModel.countDocuments({
            createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
        });
        return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
    }
}
