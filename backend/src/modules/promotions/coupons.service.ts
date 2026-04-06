import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Coupon, CouponDocument } from './schemas/coupon.schema';
import { CouponUsage, CouponUsageDocument } from './schemas/coupon-usage.schema';
import { Customer, CustomerDocument } from '@modules/customers/schemas/customer.schema';
import { Product, ProductDocument } from '@modules/products/schemas/product.schema';
import { Order, OrderDocument } from '@modules/orders/schemas/order.schema';

type CouponValidationContext = {
    productIds?: string[];
    categoryIds?: string[];
    priceLevelId?: string;
    shippingCost?: number;
};

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
        @InjectModel(Customer.name)
        private customerModel: Model<CustomerDocument>,
        @InjectModel(Product.name)
        private productModel: Model<ProductDocument>,
        @InjectModel(Order.name)
        private orderModel: Model<OrderDocument>,
    ) { }

    private normalizeObjectIdStrings(
        ids: Array<string | Types.ObjectId> | undefined,
    ): string[] {
        if (!ids || ids.length === 0) return [];
        return ids
            .map((id) => id?.toString())
            .filter((id): id is string => !!id);
    }

    private async resolveCustomerPriceLevelId(customerId: string): Promise<string | undefined> {
        const customer = await this.customerModel
            .findById(customerId)
            .select('priceLevelId')
            .lean<{ priceLevelId?: Types.ObjectId }>();
        return customer?.priceLevelId?.toString();
    }

    private async resolveCategoryIdsFromProducts(productIds: string[]): Promise<string[]> {
        if (productIds.length === 0) return [];

        const objectIds = productIds
            .filter((id) => Types.ObjectId.isValid(id))
            .map((id) => new Types.ObjectId(id));

        if (objectIds.length === 0) return [];

        const products = await this.productModel
            .find({ _id: { $in: objectIds } })
            .select('categoryId additionalCategories')
            .lean<Array<{ categoryId?: Types.ObjectId; additionalCategories?: Types.ObjectId[] }>>();

        const categoryIds = new Set<string>();
        for (const product of products) {
            if (product.categoryId) {
                categoryIds.add(product.categoryId.toString());
            }
            for (const categoryId of product.additionalCategories || []) {
                categoryIds.add(categoryId.toString());
            }
        }

        return Array.from(categoryIds);
    }

    private async validateApplicability(
        coupon: CouponDocument,
        customerId: string,
        context: CouponValidationContext = {},
    ): Promise<void> {
        const applicablePriceLevels = this.normalizeObjectIdStrings(
            coupon.applicablePriceLevels as Array<string | Types.ObjectId> | undefined,
        );
        if (applicablePriceLevels.length > 0) {
            const priceLevelId =
                context.priceLevelId || (await this.resolveCustomerPriceLevelId(customerId));
            if (!priceLevelId || !applicablePriceLevels.includes(priceLevelId)) {
                throw new BadRequestException('Coupon is not applicable for your price level');
            }
        }

        const applicableProducts = this.normalizeObjectIdStrings(
            coupon.applicableProducts as Array<string | Types.ObjectId> | undefined,
        );
        const productIds = this.normalizeObjectIdStrings(
            context.productIds as Array<string | Types.ObjectId> | undefined,
        );
        if (applicableProducts.length > 0) {
            const hasMatchingProduct = productIds.some((id) =>
                applicableProducts.includes(id),
            );
            if (!hasMatchingProduct) {
                throw new BadRequestException('Coupon is not applicable to cart products');
            }
        }

        const applicableCategories = this.normalizeObjectIdStrings(
            coupon.applicableCategories as Array<string | Types.ObjectId> | undefined,
        );
        if (applicableCategories.length > 0) {
            const explicitCategoryIds = this.normalizeObjectIdStrings(
                context.categoryIds as Array<string | Types.ObjectId> | undefined,
            );
            const categoryIds =
                explicitCategoryIds.length > 0
                    ? explicitCategoryIds
                    : await this.resolveCategoryIdsFromProducts(productIds);

            const hasMatchingCategory = categoryIds.some((id) =>
                applicableCategories.includes(id),
            );
            if (!hasMatchingCategory) {
                throw new BadRequestException('Coupon is not applicable to cart categories');
            }
        }
    }

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
        context: CouponValidationContext = {},
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
        if (coupon.firstOrderOnly) {
            const previousOrdersCount = await this.orderModel.countDocuments({
                customerId: new Types.ObjectId(customerId),
                status: { $ne: 'cancelled' },
            });
            if (previousOrdersCount > 0) {
                throw new BadRequestException('Coupon is for first orders only');
            }
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

        await this.validateApplicability(coupon, customerId, context);

        // Calculate discount
        const orderDiscount = this.calculateDiscount(coupon, orderAmount);
        const shippingDiscount = this.calculateShippingDiscount(
            coupon,
            context.shippingCost,
        );
        const discountAmount = Math.round((orderDiscount + shippingDiscount) * 100) / 100;

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

    private calculateShippingDiscount(
        coupon: CouponDocument,
        shippingCost?: number,
    ): number {
        if (coupon.discountType !== 'free_shipping') return 0;
        const amount = Math.max(0, Number(shippingCost || 0));
        return Math.round(amount * 100) / 100;
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
        const existingUsage = await this.couponUsageModel
            .findOne({ couponId: data.couponId, orderId: data.orderId })
            .select('_id')
            .lean();
        if (existingUsage) return;

        await this.couponUsageModel.create(data);
        await this.couponModel.findByIdAndUpdate(data.couponId, {
            $inc: { usedCount: 1 },
        });
    }

    /**
     * Revert coupon usage for an order (used when cancelled before shipping)
     */
    async revertUsageForOrder(orderId: string, couponId?: string): Promise<boolean> {
        const query: Record<string, any> = {
            orderId: new Types.ObjectId(orderId),
        };
        if (couponId) {
            query.couponId = new Types.ObjectId(couponId);
        }

        const usage = await this.couponUsageModel.findOneAndDelete(query);
        if (!usage) return false;

        await this.couponModel.updateOne(
            { _id: usage.couponId, usedCount: { $gt: 0 } },
            { $inc: { usedCount: -1 } },
        );

        return true;
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
        if (!Types.ObjectId.isValid(couponId)) {
            throw new BadRequestException('Invalid coupon ID');
        }
        const couponObjectId = new Types.ObjectId(couponId);

        const [usages, totalDiscount] = await Promise.all([
            this.couponUsageModel.countDocuments({ couponId: couponObjectId }),
            this.couponUsageModel.aggregate([
                { $match: { couponId: couponObjectId } },
                { $group: { _id: null, total: { $sum: '$discountAmount' } } },
            ]),
        ]);

        return {
            usages,
            totalDiscount: totalDiscount[0]?.total || 0,
        };
    }
}
