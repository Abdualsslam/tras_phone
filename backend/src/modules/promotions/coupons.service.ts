import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Coupon, CouponDocument } from './schemas/coupon.schema';
import { CouponUsage, CouponUsageDocument } from './schemas/coupon-usage.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎟️ Coupons Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CouponsService {
    constructor(
        @InjectModel(Coupon.name)
        private couponModel: Model<CouponDocument>,
        @InjectModel(CouponUsage.name)
        private couponUsageModel: Model<CouponUsageDocument>,
    ) { }

    /**
     * Create coupon
     */
    async create(data: any): Promise<CouponDocument> {
        return this.couponModel.create({
            ...data,
            code: data.code.toUpperCase(),
        });
    }

    /**
     * Find all coupons (admin)
     */
    async findAll(): Promise<CouponDocument[]> {
        return this.couponModel.find().sort({ createdAt: -1 });
    }

    /**
     * Find public coupons (customer)
     */
    async findPublic(): Promise<CouponDocument[]> {
        const now = new Date();
        return this.couponModel.find({
            isActive: true,
            isPublic: true,
            startDate: { $lte: now },
            expiryDate: { $gte: now },
        });
    }

    /**
     * Find coupon by code
     */
    async findByCode(code: string): Promise<CouponDocument> {
        const coupon = await this.couponModel.findOne({
            code: code.toUpperCase(),
        });
        if (!coupon) throw new NotFoundException('Coupon not found');
        return coupon;
    }

    /**
     * Validate and apply coupon
     */
    async validate(
        code: string,
        customerId: string,
        orderAmount: number,
        isFirstOrder: boolean = false,
    ): Promise<{ coupon: CouponDocument; discountAmount: number }> {
        const coupon = await this.findByCode(code);
        const now = new Date();

        // Check if active
        if (!coupon.isActive) {
            throw new BadRequestException('Coupon is not active');
        }

        // Check validity period
        if (now < coupon.startDate || now > coupon.expiryDate) {
            throw new BadRequestException('Coupon has expired or not yet valid');
        }

        // Check minimum order amount
        if (coupon.minOrderAmount && orderAmount < coupon.minOrderAmount) {
            throw new BadRequestException(
                `Minimum order amount is ${coupon.minOrderAmount}`,
            );
        }

        // Check first order only
        if (coupon.firstOrderOnly && !isFirstOrder) {
            throw new BadRequestException('Coupon is for first orders only');
        }

        // Check total usage limit
        if (coupon.usageLimit && coupon.usedCount >= coupon.usageLimit) {
            throw new BadRequestException('Coupon usage limit reached');
        }

        // Check per-customer limit
        const customerUsages = await this.couponUsageModel.countDocuments({
            couponId: coupon._id,
            customerId,
        });
        if (customerUsages >= coupon.usageLimitPerCustomer) {
            throw new BadRequestException('You have already used this coupon');
        }

        // Calculate discount
        const discountAmount = this.calculateDiscount(coupon, orderAmount);

        return { coupon, discountAmount };
    }

    /**
     * Calculate discount amount
     */
    calculateDiscount(coupon: CouponDocument, orderAmount: number): number {
        let discount = 0;

        switch (coupon.discountType) {
            case 'percentage':
                discount = (orderAmount * (coupon.discountValue || 0)) / 100;
                if (coupon.maxDiscountAmount) {
                    discount = Math.min(discount, coupon.maxDiscountAmount);
                }
                break;

            case 'fixed_amount':
                const fixedDiscount = coupon.discountValue || 0;
                discount = Math.min(fixedDiscount, orderAmount);
                break;

            case 'free_shipping':
                // Return 0, handled in shipping calculation
                break;
        }

        return Math.round(discount * 100) / 100;
    }

    /**
     * Record coupon usage
     */
    async recordUsage(data: {
        couponId: string;
        customerId: string;
        orderId: string;
        discountAmount: number;
        orderAmount: number;
    }): Promise<void> {
        await this.couponUsageModel.create(data);
        await this.couponModel.findByIdAndUpdate(data.couponId, {
            $inc: { usedCount: 1 },
        });
    }

    /**
     * Update coupon
     */
    async update(id: string, data: any): Promise<CouponDocument> {
        const coupon = await this.couponModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!coupon) throw new NotFoundException('Coupon not found');
        return coupon;
    }

    /**
     * Delete coupon
     */
    async delete(id: string): Promise<void> {
        const result = await this.couponModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Coupon not found');
    }

    /**
     * Get coupon usage statistics
     */
    async getStatistics(couponId: string) {
        const [usages, totalDiscount] = await Promise.all([
            this.couponUsageModel.countDocuments({ couponId }),
            this.couponUsageModel.aggregate([
                { $match: { couponId } },
                { $group: { _id: null, total: { $sum: '$discountAmount' } } },
            ]),
        ]);

        return {
            usages,
            totalDiscount: totalDiscount[0]?.total || 0,
        };
    }
}
