import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Promotion, PromotionDocument } from './schemas/promotion.schema';
import { PromotionProduct, PromotionProductDocument } from './schemas/promotion-product.schema';
import { PromotionCategory, PromotionCategoryDocument } from './schemas/promotion-category.schema';
import { PromotionBrand, PromotionBrandDocument } from './schemas/promotion-brand.schema';
import { PromotionUsage, PromotionUsageDocument } from './schemas/promotion-usage.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Promotions Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class PromotionsService {
    constructor(
        @InjectModel(Promotion.name)
        private promotionModel: Model<PromotionDocument>,
        @InjectModel(PromotionProduct.name)
        private promotionProductModel: Model<PromotionProductDocument>,
        @InjectModel(PromotionCategory.name)
        private promotionCategoryModel: Model<PromotionCategoryDocument>,
        @InjectModel(PromotionBrand.name)
        private promotionBrandModel: Model<PromotionBrandDocument>,
        @InjectModel(PromotionUsage.name)
        private promotionUsageModel: Model<PromotionUsageDocument>,
    ) { }

    /**
     * Create promotion
     */
    async create(data: any): Promise<PromotionDocument> {
        const promotion = await this.promotionModel.create(data);

        // Handle scope-specific mappings
        if (data.productIds?.length) {
            await this.addProducts(promotion._id.toString(), data.productIds);
        }
        if (data.categoryIds?.length) {
            await this.addCategories(promotion._id.toString(), data.categoryIds);
        }
        if (data.brandIds?.length) {
            await this.addBrands(promotion._id.toString(), data.brandIds);
        }

        return promotion;
    }

    /**
     * Find active promotions
     */
    async findActive(): Promise<PromotionDocument[]> {
        const now = new Date();
        return this.promotionModel.find({
            isActive: true,
            startDate: { $lte: now },
            endDate: { $gte: now },
        }).sort({ priority: -1 });
    }

    /**
     * Find auto-apply promotions
     */
    async findAutoApply(): Promise<PromotionDocument[]> {
        const now = new Date();
        return this.promotionModel.find({
            isActive: true,
            isAutoApply: true,
            startDate: { $lte: now },
            endDate: { $gte: now },
        }).sort({ priority: -1 });
    }

    /**
     * Get promotion by ID
     */
    async findById(id: string): Promise<PromotionDocument> {
        const promotion = await this.promotionModel.findById(id);
        if (!promotion) throw new NotFoundException('Promotion not found');
        return promotion;
    }

    /**
     * Update promotion
     */
    async update(id: string, data: any): Promise<PromotionDocument> {
        const promotion = await this.promotionModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!promotion) throw new NotFoundException('Promotion not found');
        return promotion;
    }

    /**
     * Delete promotion
     */
    async delete(id: string): Promise<void> {
        await Promise.all([
            this.promotionModel.deleteOne({ _id: id }),
            this.promotionProductModel.deleteMany({ promotionId: id }),
            this.promotionCategoryModel.deleteMany({ promotionId: id }),
            this.promotionBrandModel.deleteMany({ promotionId: id }),
        ]);
    }

    /**
     * Add products to promotion
     */
    async addProducts(promotionId: string, productIds: string[]): Promise<void> {
        const docs = productIds.map(productId => ({ promotionId, productId }));
        await this.promotionProductModel.insertMany(docs, { ordered: false }).catch(() => { });
    }

    /**
     * Add categories to promotion
     */
    async addCategories(promotionId: string, categoryIds: string[]): Promise<void> {
        const docs = categoryIds.map(categoryId => ({ promotionId, categoryId }));
        await this.promotionCategoryModel.insertMany(docs, { ordered: false }).catch(() => { });
    }

    /**
     * Add brands to promotion
     */
    async addBrands(promotionId: string, brandIds: string[]): Promise<void> {
        const docs = brandIds.map(brandId => ({ promotionId, brandId }));
        await this.promotionBrandModel.insertMany(docs, { ordered: false }).catch(() => { });
    }

    /**
     * Get promotions applicable to a product
     */
    async getPromotionsForProduct(productId: string, categoryId: string, brandId: string): Promise<PromotionDocument[]> {
        const now = new Date();
        const baseQuery = {
            isActive: true,
            startDate: { $lte: now },
            endDate: { $gte: now },
        };

        // Get promotion IDs from mappings
        const [productPromoIds, categoryPromoIds, brandPromoIds] = await Promise.all([
            this.promotionProductModel.find({ productId }).distinct('promotionId'),
            this.promotionCategoryModel.find({ categoryId }).distinct('promotionId'),
            this.promotionBrandModel.find({ brandId }).distinct('promotionId'),
        ]);

        const allPromoIds = [...new Set([
            ...productPromoIds.map(id => id.toString()),
            ...categoryPromoIds.map(id => id.toString()),
            ...brandPromoIds.map(id => id.toString()),
        ])];

        // Get all applicable promotions
        return this.promotionModel.find({
            ...baseQuery,
            $or: [
                { scope: 'all' },
                { _id: { $in: allPromoIds } },
            ],
        }).sort({ priority: -1 });
    }

    /**
     * Calculate discount amount
     */
    calculateDiscount(promotion: PromotionDocument, orderAmount: number, quantity: number = 1): number {
        let discount = 0;

        const discountValue = promotion.discountValue ?? 0;
        const buyQuantity = promotion.buyQuantity ?? 0;
        const getQuantity = promotion.getQuantity ?? 0;
        const getDiscountPercentage = promotion.getDiscountPercentage ?? 0;

        switch (promotion.discountType) {
            case 'percentage':
                discount = (orderAmount * discountValue) / 100;
                if (promotion.maxDiscountAmount) {
                    discount = Math.min(discount, promotion.maxDiscountAmount);
                }
                break;

            case 'fixed_amount':
                discount = discountValue;
                break;

            case 'buy_x_get_y':
                if (quantity >= buyQuantity + getQuantity) {
                    const freeItems = Math.floor(quantity / (buyQuantity + getQuantity)) * getQuantity;
                    const itemPrice = orderAmount / quantity;
                    discount = freeItems * itemPrice * (getDiscountPercentage / 100);
                }
                break;

            case 'free_shipping':
                // Handled separately in shipping calculation
                break;
        }

        return Math.round(discount * 100) / 100;
    }

    /**
     * Record promotion usage
     */
    async recordUsage(data: {
        promotionId: string;
        customerId: string;
        orderId: string;
        discountAmount: number;
        orderAmount: number;
    }): Promise<void> {
        await this.promotionUsageModel.create(data);
        await this.promotionModel.findByIdAndUpdate(data.promotionId, {
            $inc: { usedCount: 1 },
        });
    }

    /**
     * Check if customer can use promotion
     */
    async canCustomerUse(promotionId: string, customerId: string): Promise<boolean> {
        const promotion = await this.findById(promotionId);

        // Check total usage limit
        if (promotion.usageLimit && promotion.usedCount >= promotion.usageLimit) {
            return false;
        }

        // Check per-customer limit
        if (promotion.usageLimitPerCustomer) {
            const customerUsages = await this.promotionUsageModel.countDocuments({
                promotionId,
                customerId,
            });
            if (customerUsages >= promotion.usageLimitPerCustomer) {
                return false;
            }
        }

        return true;
    }
}
