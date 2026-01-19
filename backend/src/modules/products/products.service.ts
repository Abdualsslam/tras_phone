import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import {
  ProductPrice,
  ProductPriceDocument,
} from './schemas/product-price.schema';
import { Wishlist, WishlistDocument } from './schemas/wishlist.schema';
import {
  ProductReview,
  ProductReviewDocument,
} from './schemas/product-review.schema';
import { PriceLevel, PriceLevelDocument } from './schemas/price-level.schema';
import {
  ProductDeviceCompatibility,
  ProductDeviceCompatibilityDocument,
} from './schemas/product-device-compatibility.schema';
import { Tag, TagDocument } from './schemas/tag.schema';
import { ProductTag, ProductTagDocument } from './schemas/product-tag.schema';
import { StockAlert, StockAlertDocument } from './schemas/stock-alert.schema';

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
    @InjectModel(ProductDeviceCompatibility.name)
    private deviceCompatibilityModel: Model<ProductDeviceCompatibilityDocument>,
    @InjectModel(Tag.name)
    private tagModel: Model<TagDocument>,
    @InjectModel(ProductTag.name)
    private productTagModel: Model<ProductTagDocument>,
    @InjectModel(StockAlert.name)
    private stockAlertModel: Model<StockAlertDocument>,
  ) {}

  /**
   * Create product
   */
  async create(data: any): Promise<ProductDocument> {
    const existing = await this.productModel.findOne({
      $or: [{ sku: data.sku }, { slug: data.slug }],
    });
    if (existing) {
      throw new ConflictException(
        'Product with this SKU or slug already exists',
      );
    }

    const product = await this.productModel.create(data);
    return product;
  }

  /**
   * Find all products with filters and pagination
   */
  async findAll(
    filters?: any,
  ): Promise<{ data: ProductDocument[]; total: number; pagination: any }> {
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
    if (deviceId) query.compatibleDevices = { $in: [deviceId] };
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
   * Find products on offer (with compareAtPrice > basePrice)
   */
  async findProductsOnOffer(
    filters?: any,
  ): Promise<{ data: any[]; total: number; pagination: any }> {
    const {
      page = 1,
      limit = 20,
      sortBy = 'discount',
      sortOrder = 'desc',
      minDiscount,
      maxDiscount,
      categoryId,
      brandId,
      status = 'active',
    } = filters || {};

    // Base query: products with direct offer (compareAtPrice > basePrice)
    const query: any = {
      compareAtPrice: { $exists: true, $ne: null },
      $expr: { $gt: ['$compareAtPrice', '$basePrice'] },
      status,
      isActive: true,
    };

    // Additional filters
    if (categoryId) query.categoryId = new Types.ObjectId(categoryId);
    if (brandId) query.brandId = new Types.ObjectId(brandId);

    // Calculate discount percentage for filtering
    const pipeline: any[] = [
      {
        $match: query,
      },
      {
        $addFields: {
          discountPercentage: {
            $multiply: [
              {
                $divide: [
                  { $subtract: ['$compareAtPrice', '$basePrice'] },
                  '$compareAtPrice',
                ],
              },
              100,
            ],
          },
        },
      },
    ];

    // Filter by discount percentage range
    if (minDiscount != null || maxDiscount != null) {
      const discountFilter: any = {};
      if (minDiscount != null) discountFilter.$gte = minDiscount;
      if (maxDiscount != null) discountFilter.$lte = maxDiscount;
      pipeline.push({
        $match: { discountPercentage: discountFilter },
      });
    }

    // Sort
    let sortField = 'discountPercentage';
    if (sortBy === 'price') sortField = 'basePrice';
    else if (sortBy === 'createdAt') sortField = 'createdAt';
    else if (sortBy === 'discount') sortField = 'discountPercentage';

    const sortDirection = sortOrder === 'desc' ? -1 : 1;
    pipeline.push({ $sort: { [sortField]: sortDirection } });

    // Count total before pagination
    const countPipeline = [...pipeline, { $count: 'total' }];
    const countResult = await this.productModel.aggregate(countPipeline);
    const total = countResult[0]?.total || 0;

    // Pagination
    const skip = (page - 1) * limit;
    pipeline.push({ $skip: skip }, { $limit: limit });

    // Populate related fields
    pipeline.push(
      {
        $lookup: {
          from: 'brands',
          localField: 'brandId',
          foreignField: '_id',
          as: 'brandId',
        },
      },
      {
        $unwind: {
          path: '$brandId',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $lookup: {
          from: 'categories',
          localField: 'categoryId',
          foreignField: '_id',
          as: 'categoryId',
        },
      },
      {
        $unwind: {
          path: '$categoryId',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $lookup: {
          from: 'quality_types',
          localField: 'qualityTypeId',
          foreignField: '_id',
          as: 'qualityTypeId',
        },
      },
      {
        $unwind: {
          path: '$qualityTypeId',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $addFields: {
          hasDirectOffer: true,
          originalPrice: '$compareAtPrice',
          currentPrice: '$basePrice',
          appliedPromotion: null,
        },
      },
    );

    const data = await this.productModel.aggregate(pipeline);

    // Convert to ProductDocument and format
    const formattedData = data.map((doc) => {
      const product = this.productModel.hydrate(doc) as any;
      // Use discountPercentage from aggregation if available, otherwise calculate
      const discountPercentage = doc.discountPercentage != null
        ? Math.round(doc.discountPercentage * 100) / 100
        : Math.round(
            ((product.compareAtPrice - product.basePrice) / product.compareAtPrice) * 100 * 100,
          ) / 100;
      
      return {
        ...product.toObject(),
        hasDirectOffer: true,
        originalPrice: product.compareAtPrice,
        currentPrice: product.basePrice,
        discountPercentage,
        appliedPromotion: null,
      };
    });

    return {
      data: formattedData,
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
    if (result.deletedCount === 0)
      throw new NotFoundException('Product not found');
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
  async setPrices(
    productId: string,
    prices: { priceLevelId: string; price: number }[],
  ): Promise<void> {
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

  async addToWishlist(
    customerId: string,
    productId: string,
  ): Promise<WishlistDocument> {
    try {
      const wishlist = await this.wishlistModel.create({
        customerId,
        productId,
      });
      await this.productModel.findByIdAndUpdate(productId, {
        $inc: { wishlistCount: 1 },
      });
      return wishlist;
    } catch (error: any) {
      if (error.code === 11000) {
        throw new ConflictException('Product already in wishlist');
      }
      throw error;
    }
  }

  async removeFromWishlist(
    customerId: string,
    productId: string,
  ): Promise<void> {
    const result = await this.wishlistModel.deleteOne({
      customerId,
      productId,
    });
    if (result.deletedCount > 0) {
      await this.productModel.findByIdAndUpdate(productId, {
        $inc: { wishlistCount: -1 },
      });
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
      {
        $match: {
          productId: new Types.ObjectId(productId),
          status: 'approved',
        },
      },
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

  // ═════════════════════════════════════
  // Device Compatibility
  // ═════════════════════════════════════

  /**
   * Add device compatibility to product
   */
  async addDeviceCompatibility(
    productId: string,
    deviceIds: string[],
    compatibilityNotes?: string,
    isVerified: boolean = false,
  ): Promise<ProductDeviceCompatibilityDocument[]> {
    const product = await this.productModel.findById(productId);
    if (!product) throw new NotFoundException('Product not found');

    const compatibilities = deviceIds.map((deviceId) => ({
      productId: new Types.ObjectId(productId),
      deviceId: new Types.ObjectId(deviceId),
      compatibilityNotes,
      isVerified,
    }));

    // Remove existing and add new
    await this.deviceCompatibilityModel.deleteMany({
      productId: new Types.ObjectId(productId),
    });
    const created =
      await this.deviceCompatibilityModel.insertMany(compatibilities);

    // Update product compatibleDevices array
    await this.productModel.findByIdAndUpdate(productId, {
      compatibleDevices: deviceIds.map((id) => new Types.ObjectId(id)),
    });

    return created;
  }

  // ═════════════════════════════════════
  // Tags
  // ═════════════════════════════════════

  /**
   * Add tags to product
   */
  async addTags(productId: string, tagIds: string[]): Promise<void> {
    const product = await this.productModel.findById(productId);
    if (!product) throw new NotFoundException('Product not found');

    // Remove existing tags
    await this.productTagModel.deleteMany({
      productId: new Types.ObjectId(productId),
    });

    // Add new tags
    if (tagIds.length > 0) {
      const productTags = tagIds.map((tagId) => ({
        productId: new Types.ObjectId(productId),
        tagId: new Types.ObjectId(tagId),
      }));
      await this.productTagModel.insertMany(productTags);
    }
  }

  /**
   * Get product tags
   */
  async getProductTags(productId: string): Promise<TagDocument[]> {
    const productTags = await this.productTagModel
      .find({ productId: new Types.ObjectId(productId) })
      .populate('tagId');

    return productTags.map((pt) => pt.tagId as unknown as TagDocument);
  }

  // ═════════════════════════════════════
  // Stock Alerts (Customer)
  // ═════════════════════════════════════

  /**
   * Create stock alert for customer
   */
  async createStockAlert(
    customerId: string,
    productId: string,
    alertType: 'back_in_stock' | 'low_stock' | 'price_drop',
    targetPrice?: number,
  ): Promise<StockAlertDocument> {
    const product = await this.productModel.findById(productId);
    if (!product) throw new NotFoundException('Product not found');

    // Check if alert already exists
    const existing = await this.stockAlertModel.findOne({
      customerId: new Types.ObjectId(customerId),
      productId: new Types.ObjectId(productId),
      alertType,
      isActive: true,
    });

    if (existing) {
      throw new ConflictException('Stock alert already exists');
    }

    const alertData: any = {
      customerId: new Types.ObjectId(customerId),
      productId: new Types.ObjectId(productId),
      alertType,
    };

    if (alertType === 'price_drop' && targetPrice) {
      alertData.targetPrice = targetPrice;
      alertData.originalPrice = product.basePrice;
    }

    return this.stockAlertModel.create(alertData);
  }

  /**
   * Get customer stock alerts
   */
  async getStockAlerts(customerId: string): Promise<StockAlertDocument[]> {
    return this.stockAlertModel
      .find({ customerId: new Types.ObjectId(customerId), isActive: true })
      .populate('productId', 'name nameAr mainImage basePrice stockQuantity')
      .sort({ createdAt: -1 });
  }

  /**
   * Delete stock alert
   */
  async deleteStockAlert(customerId: string, alertId: string): Promise<void> {
    const result = await this.stockAlertModel.deleteOne({
      _id: alertId,
      customerId: new Types.ObjectId(customerId),
    });

    if (result.deletedCount === 0) {
      throw new NotFoundException('Stock alert not found');
    }
  }

  /**
   * Update stock alert
   */
  async updateStockAlert(
    customerId: string,
    alertId: string,
    isActive: boolean,
  ): Promise<StockAlertDocument> {
    const alert = await this.stockAlertModel.findOneAndUpdate(
      { _id: alertId, customerId: new Types.ObjectId(customerId) },
      { isActive },
      { new: true },
    );

    if (!alert) {
      throw new NotFoundException('Stock alert not found');
    }

    return alert;
  }
}
