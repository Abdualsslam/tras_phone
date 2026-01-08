import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import { ProductPrice, ProductPriceDocument } from './schemas/product-price.schema';
import { Wishlist, WishlistDocument } from './schemas/wishlist.schema';
import { ProductReview, ProductReviewDocument } from './schemas/product-review.schema';
import { PriceLevel, PriceLevelDocument } from './schemas/price-level.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Products Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ProductsService {
    constructor(
        @InjectModel(Product.name)
        private productModel: Model<ProductDocument>,
        @InjectModel(ProductPrice.name)
        private productPriceModel: Model<ProductPriceDocument>,
        @InjectModel(Wishlist.name)
        private wishlistModel: Model<WishlistDocument>,
        @InjectModel(ProductReview.name)
        private productReviewModel: Model<ProductReviewDocument>,
        @InjectModel(PriceLevel.name)
        private priceLevelModel: Model<PriceLevelDocument>,
    ) { }

    /**
     * Create product
     */
    async create(data: any): Promise<ProductDocument> {
        const existing = await this.productModel.findOne({
            $or: [{ sku: data.sku }, { slug: data.slug }],
        });
        if (existing) {
            throw new ConflictException('Product with this SKU or slug already exists');
        }

        const product = await this.productModel.create(data);
        return product;
    }

    /**
     * Find all products with filters and pagination
     */
    async findAll(filters?: any): Promise<{ data: ProductDocument[]; total: number; pagination: any }> {
        const {
            page = 1,
            limit = 20,
            search,
            categoryId,
            brandId,
            qualityTypeId,
            deviceId,
            minPrice,
            maxPrice,
            status = 'active',
            featured,
            newArrival,
            bestSeller,
            sort = 'createdAt',
            order = 'desc',
        } = filters || {};

        const query: any = {};

        if (search) {
            query.$text = { $search: search };
        }

        if (categoryId) query.categoryId = categoryId;
        if (brandId) query.brandId = brandId;
        if (qualityTypeId) query.qualityTypeId = qualityTypeId;
        if (deviceId) query.compatibleDevices = deviceId;
        if (status) query.status = status;
        if (featured) query.isFeatured = true;
        if (newArrival) query.isNewArrival = true;
        if (bestSeller) query.isBestSeller = true;

        if (minPrice || maxPrice) {
            query.basePrice = {};
            if (minPrice) query.basePrice.$gte = minPrice;
            if (maxPrice) query.basePrice.$lte = maxPrice;
        }

        const skip = (page - 1) * limit;
        const sortObj: any = { [sort]: order === 'desc' ? -1 : 1 };

        const [data, total] = await Promise.all([
            this.productModel
                .find(query)
                .populate('brandId', 'name nameAr slug')
                .populate('categoryId', 'name nameAr slug')
                .populate('qualityTypeId', 'name nameAr code color')
                .skip(skip)
                .limit(limit)
                .sort(sortObj),
            this.productModel.countDocuments(query),
        ]);

        return {
            data,
            total,
            pagination: {
                page,
                limit,
                pages: Math.ceil(total / limit),
            },
        };
    }

    /**
     * Find product by ID or slug
     */
    async findByIdOrSlug(identifier: string): Promise<ProductDocument> {
        const query = Types.ObjectId.isValid(identifier)
            ? { _id: identifier }
            : { slug: identifier };

        const product = await this.productModel
            .findOne(query)
            .populate('brandId')
            .populate('categoryId')
            .populate('qualityTypeId')
            .populate('compatibleDevices');

        if (!product) {
            throw new NotFoundException('Product not found');
        }

        // Increment views
        await this.productModel.findByIdAndUpdate(product._id, {
            $inc: { viewsCount: 1 },
        });

        return product;
    }

    /**
     * Update product
     */
    async update(id: string, data: any): Promise<ProductDocument> {
        const product = await this.productModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!product) throw new NotFoundException('Product not found');
        return product;
    }

    /**
     * Delete product
     */
    async delete(id: string): Promise<void> {
        const result = await this.productModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Product not found');
    }

    /**
     * Get product price for customer's price level
     */
    async getPrice(productId: string, priceLevelId: string): Promise<number> {
        const productPrice = await this.productPriceModel.findOne({
            productId,
            priceLevelId,
            isActive: true,
        });

        if (productPrice) {
            return productPrice.price;
        }

        // Fallback to base price
        const product = await this.productModel.findById(productId);
        return product?.basePrice || 0;
    }

    /**
     * Set product prices for all levels
     */
    async setPrices(productId: string, prices: { priceLevelId: string; price: number }[]): Promise<void> {
        for (const priceData of prices) {
            await this.productPriceModel.findOneAndUpdate(
                { productId, priceLevelId: priceData.priceLevelId },
                { $set: { price: priceData.price, isActive: true } },
                { upsert: true },
            );
        }
    }

    // ═════════════════════════════════════
    // Wishlist
    // ═════════════════════════════════════

    async addToWishlist(customerId: string, productId: string): Promise<WishlistDocument> {
        try {
            const wishlist = await this.wishlistModel.create({ customerId, productId });
            await this.productModel.findByIdAndUpdate(productId, { $inc: { wishlistCount: 1 } });
            return wishlist;
        } catch (error: any) {
            if (error.code === 11000) {
                throw new ConflictException('Product already in wishlist');
            }
            throw error;
        }
    }

    async removeFromWishlist(customerId: string, productId: string): Promise<void> {
        const result = await this.wishlistModel.deleteOne({ customerId, productId });
        if (result.deletedCount > 0) {
            await this.productModel.findByIdAndUpdate(productId, { $inc: { wishlistCount: -1 } });
        }
    }

    async getWishlist(customerId: string): Promise<WishlistDocument[]> {
        return this.wishlistModel.find({ customerId }).populate('productId');
    }

    // ═════════════════════════════════════
    // Reviews
    // ═════════════════════════════════════

    async addReview(data: any): Promise<ProductReviewDocument> {
        const review = await this.productReviewModel.create(data);
        await this.updateProductRating(data.productId);
        return review;
    }

    async getReviews(productId: string): Promise<ProductReviewDocument[]> {
        return this.productReviewModel
            .find({ productId, status: 'approved' })
            .populate('customerId', 'responsiblePersonName shopName')
            .sort({ createdAt: -1 });
    }

    private async updateProductRating(productId: string): Promise<void> {
        const result = await this.productReviewModel.aggregate([
            { $match: { productId: new Types.ObjectId(productId), status: 'approved' } },
            { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } },
        ]);

        const stats = result[0] || { avg: 0, count: 0 };

        await this.productModel.findByIdAndUpdate(productId, {
            averageRating: Math.round(stats.avg * 10) / 10,
            reviewsCount: stats.count,
        });
    }

    // ═════════════════════════════════════
    // Price Levels
    // ═════════════════════════════════════

    /**
     * Get all active price levels
     */
    async findAllPriceLevels(): Promise<PriceLevelDocument[]> {
        return this.priceLevelModel
            .find({ isActive: true })
            .sort({ displayOrder: 1, name: 1 });
    }
}
