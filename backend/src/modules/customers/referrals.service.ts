import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Referral, ReferralDocument } from './schemas/referral.schema';
import { CustomersService } from './customers.service';
import { CreateReferralDto } from './dto/create-referral.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Referrals Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ReferralsService {
    constructor(
        @InjectModel(Referral.name)
        private referralModel: Model<ReferralDocument>,
        private customersService: CustomersService,
    ) { }

    /**
     * Create referral
     */
    async create(createReferralDto: CreateReferralDto): Promise<ReferralDocument> {
        // Verify both customers exist
        const [referrer, referred] = await Promise.all([
            this.customersService.findById(createReferralDto.referrerId),
            this.customersService.findById(createReferralDto.referredId),
        ]);

        if (!referrer || !referred) {
            throw new NotFoundException('Customer not found');
        }

        // Create referral
        const referral = await this.referralModel.create({
            ...createReferralDto,
            status: 'pending',
            expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
        });

        return referral;
    }

    /**
     * Get referrals by customer (as referrer)
     */
    async findByReferrer(referrerId: string): Promise<ReferralDocument[]> {
        return this.referralModel
            .find({ referrerId })
            .populate('referredId', 'shopName customerCode')
            .sort({ createdAt: -1 });
    }

    /**
     * Complete referral (when referred customer makes qualifying order)
     */
    async complete(
        referralId: string,
        orderId: string,
    ): Promise<ReferralDocument> {
        const referral = await this.referralModel.findById(referralId);

        if (!referral) {
            throw new NotFoundException('Referral not found');
        }

        if (referral.status !== 'pending') {
            throw new Error('Referral is not pending');
        }

        referral.status = 'completed';
        referral.qualifyingOrderId = orderId as any;

        // Set reward amounts (example: 100 SAR for referrer, 50 SAR for referred)
        referral.referrerRewardAmount = 100;
        referral.referredRewardAmount = 50;
        referral.referrerRewardedAt = new Date();
        referral.referredRewardedAt = new Date();

        await referral.save();

        // TODO: Add rewards to customer wallets
        // await this.walletService.addCredit(referral.referrerId, 100, 'referral_reward');
        // await this.walletService.addCredit(referral.referredId, 50, 'referral_reward');

        return referral;
    }

    /**
     * Get referral statistics for customer
     */
    async getStatistics(customerId: string) {
        const [total, completed, pending] = await Promise.all([
            this.referralModel.countDocuments({ referrerId: customerId }),
            this.referralModel.countDocuments({
                referrerId: customerId,
                status: 'completed',
            }),
            this.referralModel.countDocuments({
                referrerId: customerId,
                status: 'pending',
            }),
        ]);

        const totalRewards = await this.referralModel.aggregate([
            {
                $match: {
                    referrerId: customerId,
                    status: 'completed',
                },
            },
            {
                $group: {
                    _id: null,
                    total: { $sum: '$referrerRewardAmount' },
                },
            },
        ]);

        return {
            total,
            completed,
            pending,
            totalRewards: totalRewards[0]?.total || 0,
        };
    }
}
