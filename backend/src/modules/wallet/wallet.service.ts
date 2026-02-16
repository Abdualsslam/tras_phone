import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { WalletTransaction, WalletTransactionDocument } from './schemas/wallet-transaction.schema';
import { LoyaltyTier, LoyaltyTierDocument } from './schemas/loyalty-tier.schema';
import { LoyaltyTransaction, LoyaltyTransactionDocument } from './schemas/loyalty-transaction.schema';
import { PointsExpiry, PointsExpiryDocument } from './schemas/points-expiry.schema';
import { Customer, CustomerDocument } from '@modules/customers/schemas/customer.schema';
import { CreateTierDto } from './dto/create-tier.dto';
import { UpdateTierDto } from './dto/update-tier.dto';

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
        @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
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

        if (lastTx) {
            const balance = lastTx.balanceAfter || 0;
            // Sync to customer doc
            await this.customerModel.findByIdAndUpdate(
                customerId,
                { $set: { walletBalance: balance } },
                { new: false },
            );
            return balance;
        }

        // Fallback: read directly from customer document
        // (handles cases where balance was set via admin without creating transactions)
        const customer = await this.customerModel.findById(customerId).lean();
        return customer?.walletBalance ?? 0;
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
        idempotencyKey?: string;
    }): Promise<WalletTransactionDocument> {
        if (data.idempotencyKey) {
            const existingTx = await this.walletTxModel.findOne({
                customerId: data.customerId,
                idempotencyKey: data.idempotencyKey,
            });
            if (existingTx) return existingTx;
        }

        const balance = await this.getBalance(data.customerId);
        const transactionNumber = await this.generateWalletTxNumber();

        let transaction: WalletTransactionDocument;
        try {
            transaction = await this.walletTxModel.create({
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
                idempotencyKey: data.idempotencyKey,
                status: 'completed',
            });
        } catch (error: any) {
            if (data.idempotencyKey && error?.code === 11000) {
                const existingTx = await this.walletTxModel.findOne({
                    customerId: data.customerId,
                    idempotencyKey: data.idempotencyKey,
                });
                if (existingTx) return existingTx;
            }

            throw error;
        }

        await this.customerModel.findByIdAndUpdate(data.customerId, {
            $set: { walletBalance: transaction.balanceAfter },
        });

        return transaction;
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
        idempotencyKey?: string;
    }): Promise<WalletTransactionDocument> {
        if (data.idempotencyKey) {
            const existingTx = await this.walletTxModel.findOne({
                customerId: data.customerId,
                idempotencyKey: data.idempotencyKey,
            });
            if (existingTx) return existingTx;
        }

        // Atomic balance deduction: prevents race conditions by using $inc with a floor check.
        // If two concurrent requests try to debit, only one will succeed.
        const updatedCustomer = await this.customerModel.findOneAndUpdate(
            {
                _id: data.customerId,
                walletBalance: { $gte: data.amount },
            },
            { $inc: { walletBalance: -data.amount } },
            { new: true },
        );

        if (!updatedCustomer) {
            throw new BadRequestException('Insufficient wallet balance');
        }

        const balanceBefore = updatedCustomer.walletBalance + data.amount;
        const balanceAfter = updatedCustomer.walletBalance;
        const transactionNumber = await this.generateWalletTxNumber();

        let transaction: WalletTransactionDocument;
        try {
            transaction = await this.walletTxModel.create({
                transactionNumber,
                customerId: data.customerId,
                transactionType: data.transactionType,
                amount: data.amount,
                direction: 'debit',
                balanceBefore,
                balanceAfter,
                referenceType: data.referenceType,
                referenceId: data.referenceId,
                referenceNumber: data.referenceNumber,
                description: data.description,
                descriptionAr: data.descriptionAr,
                createdBy: data.createdBy,
                idempotencyKey: data.idempotencyKey,
                status: 'completed',
            });
        } catch (error: any) {
            // Rollback the balance deduction if transaction logging fails
            await this.customerModel.findByIdAndUpdate(data.customerId, {
                $inc: { walletBalance: data.amount },
            });

            if (data.idempotencyKey && error?.code === 11000) {
                const existingTx = await this.walletTxModel.findOne({
                    customerId: data.customerId,
                    idempotencyKey: data.idempotencyKey,
                });
                if (existingTx) return existingTx;
            }

            throw error;
        }

        return transaction;
    }

    /**
     * Get wallet transactions
     */
    async getWalletTransactions(customerId: string, filters?: any): Promise<WalletTransactionDocument[]> {
        const query: any = { customerId, status: 'completed' };
        if (filters?.type) query.transactionType = filters.type;

        return this.walletTxModel.find(query).sort({ createdAt: -1 }).limit(filters?.limit || 50);
    }

    async getAdminCustomerBalance(customerId: string): Promise<{
        balance: number;
        currency: string;
        points: number;
        tier: string;
    }> {
        const [balance, points, tier] = await Promise.all([
            this.getBalance(customerId),
            this.getPointsBalance(customerId),
            this.getCustomerTier(customerId),
        ]);

        return {
            balance,
            currency: 'SAR',
            points,
            tier: tier?.name || 'Bronze',
        };
    }

    async getAdminCustomerTransactions(customerId: string, filters?: any): Promise<any[]> {
        const transactions = await this.getWalletTransactions(customerId, filters);
        return transactions.map((tx: any) => ({
            _id: tx._id,
            customerId: tx.customerId,
            type: tx.direction,
            direction: tx.direction,
            transactionType: tx.transactionType,
            amount: tx.amount,
            balanceBefore: tx.balanceBefore,
            balanceAfter: tx.balanceAfter,
            description: tx.description || tx.descriptionAr || tx.transactionType,
            reference: tx.referenceNumber,
            referenceNumber: tx.referenceNumber,
            createdAt: tx.createdAt,
        }));
    }

    async getAdminTransactions(filters?: {
        customerId?: string;
        type?: 'credit' | 'debit';
        startDate?: string;
        endDate?: string;
        page?: number;
        limit?: number;
    }): Promise<any[]> {
        const query: any = { status: 'completed' };

        if (filters?.customerId) query.customerId = filters.customerId;
        if (filters?.type) query.direction = filters.type;

        if (filters?.startDate || filters?.endDate) {
            query.createdAt = {};
            if (filters.startDate) query.createdAt.$gte = new Date(filters.startDate);
            if (filters.endDate) query.createdAt.$lte = new Date(filters.endDate);
        }

        const page = Math.max(1, Number(filters?.page || 1));
        const limit = Math.max(1, Math.min(200, Number(filters?.limit || 50)));
        const skip = (page - 1) * limit;

        const transactions = await this.walletTxModel
            .find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .lean();

        const customerIds = Array.from(
            new Set(
                transactions
                    .map((tx: any) => tx.customerId?.toString())
                    .filter((id: string | undefined): id is string => Boolean(id)),
            ),
        );

        const customers = customerIds.length
            ? await this.customerModel
                .find({ _id: { $in: customerIds } })
                .select('_id shopName responsiblePersonName')
                .lean()
            : [];

        const customerNameById = new Map(
            customers.map((customer: any) => [
                customer._id.toString(),
                customer.shopName || customer.responsiblePersonName,
            ]),
        );

        return transactions.map((tx: any) => {
            const customerId = tx.customerId?.toString();
            return {
                _id: tx._id,
                customerId,
                customerName: customerId ? customerNameById.get(customerId) : undefined,
                type: tx.direction,
                direction: tx.direction,
                transactionType: tx.transactionType,
                amount: tx.amount,
                balanceBefore: tx.balanceBefore,
                balanceAfter: tx.balanceAfter,
                description: tx.description || tx.descriptionAr || tx.transactionType,
                reference: tx.referenceNumber,
                referenceNumber: tx.referenceNumber,
                createdAt: tx.createdAt,
            };
        });
    }

    async getWalletStats(): Promise<{
        totalBalance: number;
        totalCredits: number;
        totalDebits: number;
        transactionCount: number;
        activeWallets: number;
        totalPoints: number;
        averageBalance: number;
    }> {
        const [customerStats, txStats] = await Promise.all([
            this.customerModel.aggregate([
                {
                    $group: {
                        _id: null,
                        totalBalance: { $sum: { $ifNull: ['$walletBalance', 0] } },
                        activeWallets: {
                            $sum: {
                                $cond: [{ $gt: [{ $ifNull: ['$walletBalance', 0] }, 0] }, 1, 0],
                            },
                        },
                        totalPoints: { $sum: { $ifNull: ['$loyaltyPoints', 0] } },
                        customersCount: { $sum: 1 },
                    },
                },
            ]),
            this.walletTxModel.aggregate([
                { $match: { status: 'completed' } },
                {
                    $group: {
                        _id: null,
                        totalCredits: {
                            $sum: {
                                $cond: [{ $eq: ['$direction', 'credit'] }, '$amount', 0],
                            },
                        },
                        totalDebits: {
                            $sum: {
                                $cond: [{ $eq: ['$direction', 'debit'] }, '$amount', 0],
                            },
                        },
                        transactionCount: { $sum: 1 },
                    },
                },
            ]),
        ]);

        const customerRow = customerStats[0] || {
            totalBalance: 0,
            activeWallets: 0,
            totalPoints: 0,
            customersCount: 0,
        };
        const txRow = txStats[0] || {
            totalCredits: 0,
            totalDebits: 0,
            transactionCount: 0,
        };

        return {
            totalBalance: customerRow.totalBalance || 0,
            totalCredits: txRow.totalCredits || 0,
            totalDebits: txRow.totalDebits || 0,
            transactionCount: txRow.transactionCount || 0,
            activeWallets: customerRow.activeWallets || 0,
            totalPoints: customerRow.totalPoints || 0,
            averageBalance:
                (customerRow.customersCount || 0) > 0
                    ? (customerRow.totalBalance || 0) / customerRow.customersCount
                    : 0,
        };
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

    async hasLoyaltyTransaction(data: {
        customerId: string;
        transactionType: string;
        referenceType?: string;
        referenceId?: string;
    }): Promise<boolean> {
        const query: any = {
            customerId: data.customerId,
            transactionType: data.transactionType,
        };

        if (data.referenceType) query.referenceType = data.referenceType;
        if (data.referenceId) query.referenceId = data.referenceId;

        const existing = await this.loyaltyTxModel.exists(query);
        return !!existing;
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

    async getTiers(includeInactive: boolean = false): Promise<LoyaltyTierDocument[]> {
        const query = includeInactive ? {} : { isActive: true };
        return this.loyaltyTierModel.find(query).sort({ minPoints: 1 });
    }

    /**
     * Get all tiers (including inactive) - for admin management
     */
    async getAllTiers(): Promise<LoyaltyTierDocument[]> {
        return this.loyaltyTierModel.find({}).sort({ minPoints: 1 });
    }

    /**
     * Seed initial loyalty tiers (for first-time setup only)
     * Note: After initial setup, tiers should be managed through admin panel
     */
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

    /**
     * Create a new loyalty tier
     */
    async createTier(data: CreateTierDto): Promise<LoyaltyTierDocument> {
        // Check if code already exists
        const existingTier = await this.loyaltyTierModel.findOne({ code: data.code });
        if (existingTier) {
            throw new BadRequestException(`Tier with code '${data.code}' already exists`);
        }

        // Set defaults
        const tierData = {
            ...data,
            pointsMultiplier: data.pointsMultiplier ?? 1,
            discountPercentage: data.discountPercentage ?? 0,
            freeShipping: data.freeShipping ?? false,
            prioritySupport: data.prioritySupport ?? false,
            earlyAccess: data.earlyAccess ?? false,
            displayOrder: data.displayOrder ?? 0,
            isActive: data.isActive ?? true,
        };

        return this.loyaltyTierModel.create(tierData);
    }

    /**
     * Update an existing loyalty tier
     */
    async updateTier(id: string, data: UpdateTierDto): Promise<LoyaltyTierDocument> {
        const tier = await this.loyaltyTierModel.findById(id);
        if (!tier) {
            throw new NotFoundException('Loyalty tier not found');
        }

        // If code is being changed, check if new code already exists
        if (data.code && data.code !== tier.code) {
            const existingTier = await this.loyaltyTierModel.findOne({ code: data.code });
            if (existingTier) {
                throw new BadRequestException(`Tier with code '${data.code}' already exists`);
            }
        }

        // Update tier
        Object.assign(tier, data);
        return tier.save();
    }

    /**
     * Delete a loyalty tier
     */
    async deleteTier(id: string): Promise<void> {
        const tier = await this.loyaltyTierModel.findById(id);
        if (!tier) {
            throw new NotFoundException('Loyalty tier not found');
        }

        // Check if this is the only tier (prevent deleting all tiers)
        const totalTiers = await this.loyaltyTierModel.countDocuments({ isActive: true });
        if (totalTiers === 1 && tier.isActive) {
            throw new BadRequestException('Cannot delete the only active tier. At least one tier must remain active.');
        }

        // Check if any customers are using this tier
        // Note: We need to import Customer model if available, otherwise we'll use a different approach
        // For now, we'll check if tier code is 'bronze' (default tier) and prevent deletion
        if (tier.code === 'bronze') {
            const bronzeCount = await this.loyaltyTierModel.countDocuments({ code: 'bronze', isActive: true });
            if (bronzeCount === 1) {
                throw new BadRequestException('Cannot delete the default Bronze tier. Please deactivate it instead.');
            }
        }

        // Soft delete by setting isActive to false, or hard delete
        // We'll use soft delete to preserve data
        tier.isActive = false;
        await tier.save();
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
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        const count = await this.walletTxModel.countDocuments({
            createdAt: { $gte: startOfDay },
        });
        return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
    }

    private async generateLoyaltyTxNumber(): Promise<string> {
        const date = new Date();
        const prefix = 'LYL';
        const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        const count = await this.loyaltyTxModel.countDocuments({
            createdAt: { $gte: startOfDay },
        });
        return `${prefix}${dateStr}${(count + 1).toString().padStart(4, '0')}`;
    }
}
