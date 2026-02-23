import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import {
  ProductPrice,
  ProductPriceDocument,
} from './schemas/product-price.schema';
import { Favorite, FavoriteDocument } from './schemas/favorite.schema';
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
import {
  Customer,
  CustomerDocument,
} from '@modules/customers/schemas/customer.schema';
import { CustomersService } from '@modules/customers/customers.service';
import {
  ProductStock,
  ProductStockDocument,
} from '@modules/inventory/schemas/product-stock.schema';
import {
  Warehouse,
  WarehouseDocument,
} from '@modules/inventory/schemas/warehouse.schema';

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
    @Inject(forwardRef(() => CustomersService))
    private customersService: CustomersService,
    @InjectModel(ProductPrice.name)
    private productPriceModel: Model<ProductPriceDocument>,
    @InjectModel(Favorite.name)
    private favoriteModel: Model<FavoriteDocument>,
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
    @InjectModel(Customer.name)
    private customerModel: Model<CustomerDocument>,
    @InjectModel(ProductStock.name)
    private productStockModel: Model<ProductStockDocument>,
    @InjectModel(Warehouse.name)
    private warehouseModel: Model<WarehouseDocument>,
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

    // Convert relatedProducts from string[] to ObjectId[]
    if (data.relatedProducts && Array.isArray(data.relatedProducts)) {
      // Remove duplicates
      const uniqueIds = [...new Set(data.relatedProducts)];
      data.relatedProducts = uniqueIds.map(
        (id: string) => new Types.ObjectId(id),
      );
    }

    const product = await this.productModel.create(data);

    await this.syncDefaultWarehouseStock(product, {
      stockQuantity: data.stockQuantity,
      lowStockThreshold: data.lowStockThreshold,
      trackInventory: data.trackInventory,
    });

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
      tags,
      minPrice,
      maxPrice,
      minRating,
      maxRating,
      inStock,
      color,
      hasOffer,
      status = 'active',
      isFeatured,
      isNewArrival,
      isBestSeller,
      sort = 'createdAt',
      order = 'desc',
    } = filters || {};

    const query: any = {};

    if (search) {
      query.$text = { $search: search };
    }

    if (categoryId) query.categoryId = new Types.ObjectId(categoryId);
    if (brandId) query.brandId = new Types.ObjectId(brandId);
    if (qualityTypeId) query.qualityTypeId = new Types.ObjectId(qualityTypeId);
    if (deviceId) {
      query.compatibleDevices = {
        $in: [
          new Types.ObjectId(deviceId),
          deviceId as any,
        ],
      };
    }
    if (status) query.status = status;
    if (isFeatured) query.isFeatured = true;
    if (isNewArrival) query.isNewArrival = true;
    if (isBestSeller) query.isBestSeller = true;

    if (tags && tags.length > 0) {
      query.tags = { $in: tags };
    }

    if (minRating !== undefined || maxRating !== undefined) {
      query.averageRating = {};
      if (minRating !== undefined) query.averageRating.$gte = minRating;
      if (maxRating !== undefined) query.averageRating.$lte = maxRating;
    }

    if (inStock === true) {
      query.stockQuantity = { $gt: 0 };
    } else if (inStock === false) {
      query.stockQuantity = { $lte: 0 };
    }

    if (color) {
      query.color = { $regex: new RegExp(`^${color}$`, 'i') };
    }

    if (hasOffer === true) {
      query.compareAtPrice = { $exists: true, $ne: null };
      query.$expr = { $gt: ['$compareAtPrice', '$basePrice'] };
    } else if (hasOffer === false) {
      query.$or = [
        { compareAtPrice: { $exists: false } },
        { compareAtPrice: null },
        { $expr: { $lte: ['$compareAtPrice', '$basePrice'] } },
      ];
    }

    if (minPrice || maxPrice) {
      query.basePrice = {};
      if (minPrice) query.basePrice.$gte = minPrice;
      if (maxPrice) query.basePrice.$lte = maxPrice;
    }

    const skip = (page - 1) * limit;
    let sortField = sort;
    if (sort === 'price') sortField = 'basePrice';

    const sortObj: any = { [sortField]: order === 'desc' ? -1 : 1 };

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

    let enrichedData = data;
    if (filters?.priceLevelId) {
      enrichedData = await this.enrichWithCustomerPrice(
        data,
        filters.priceLevelId,
      );
    } else {
      // No price level: use default/base price only
      enrichedData = data.map((p) => {
        const doc = (p.toObject ? p.toObject() : { ...p }) as Record<
          string,
          any
        >;
        doc.price = doc.basePrice ?? 0;
        return doc;
      }) as unknown as typeof data;
    }

    return {
      data: enrichedData,
      total,
      pagination: {
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get price level ID for a customer (returns null if not found)
   * When customer has no price level, use default/base price only
   */
  async getPriceLevelIdForCustomer(customerId: string): Promise<string | null> {
    try {
      const customer = await this.customersService.findById(customerId);
      const pl = customer?.priceLevelId;
      if (!pl) return null;
      // When populated by findById, pl is { _id, name, discount }; when not populated, it's ObjectId
      if (typeof pl === 'object' && pl !== null && '_id' in pl) {
        return (pl as any)._id?.toString() ?? null;
      }
      return (pl as any).toString?.() ?? null;
    } catch {
      return null;
    }
  }

  /**
   * Add price field to products based on customer's price level
   */
  private async enrichWithCustomerPrice(
    products: any[],
    priceLevelId: string,
  ): Promise<any[]> {
    if (!products?.length || !priceLevelId) return products;
    return Promise.all(
      products.map(async (p) => {
        const doc = p.toObject ? p.toObject() : { ...p };
        doc.price = await this.getPrice(
          (p._id || p.id).toString(),
          priceLevelId,
        );
        return doc;
      }),
    );
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
      const discountPercentage =
        doc.discountPercentage != null
          ? Math.round(doc.discountPercentage * 100) / 100
          : Math.round(
              ((product.compareAtPrice - product.basePrice) /
                product.compareAtPrice) *
                100 *
                100,
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

    let enrichedData = formattedData;
    if (filters?.priceLevelId) {
      enrichedData = await Promise.all(
        formattedData.map(async (doc) => ({
          ...doc,
          price: await this.getPrice(doc._id.toString(), filters.priceLevelId),
        })),
      );
    } else {
      // No price level: use default/base price only
      enrichedData = formattedData.map((doc) => ({
        ...doc,
        price: doc.currentPrice ?? doc.basePrice ?? 0,
      }));
    }

    return {
      data: enrichedData,
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
  async findByIdOrSlug(
    identifier: string,
    priceLevelId?: string,
  ): Promise<ProductDocument | any> {
    const query = Types.ObjectId.isValid(identifier)
      ? { _id: identifier }
      : { slug: identifier };

    const product = await this.productModel
      .findOne(query)
      .populate('brandId')
      .populate('categoryId')
      .populate('qualityTypeId')
      .populate('compatibleDevices')
      .populate({
        path: 'relatedProducts',
        select:
          'name nameAr slug mainImage basePrice compareAtPrice isActive status',
        match: { isActive: true, status: 'active' },
      });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    // Filter out null values from relatedProducts (products that don't match the match condition)
    if (product.relatedProducts && Array.isArray(product.relatedProducts)) {
      product.relatedProducts = product.relatedProducts.filter(
        (p: any) => p !== null && p.isActive === true && p.status === 'active',
      );
    }

    // Increment views
    await this.productModel.findByIdAndUpdate(product._id, {
      $inc: { viewsCount: 1 },
    });

    const doc: Record<string, any> = product.toObject
      ? product.toObject()
      : { ...product };
    if (priceLevelId) {
      doc.price = await this.getPrice(product._id.toString(), priceLevelId);
    } else {
      doc.price = doc.basePrice ?? 0;
    }
    if (doc.brandId && typeof doc.brandId === 'object') {
      doc.brandName = doc.brandId.name;
      doc.brandNameAr = doc.brandId.nameAr;
    }
    return doc;
  }

  /**
   * Update product
   */
  async update(id: string, data: any): Promise<ProductDocument> {
    // Convert relatedProducts from string[] to ObjectId[] if provided
    if (data.relatedProducts !== undefined) {
      if (Array.isArray(data.relatedProducts)) {
        // Remove duplicates and filter out self-reference
        const uniqueIds = [...new Set(data.relatedProducts)].filter(
          (relatedId: string) => relatedId !== id,
        );

        // Validate: prevent adding the product itself to relatedProducts
        if (data.relatedProducts.includes(id)) {
          throw new BadRequestException(
            'Product cannot be related to itself',
            'لا يمكن إضافة المنتج نفسه في المنتجات المشابهة',
          );
        }

        data.relatedProducts = uniqueIds.map(
          (relatedId: string) => new Types.ObjectId(relatedId),
        );
      } else {
        data.relatedProducts = [];
      }
    }

    const product = await this.productModel.findByIdAndUpdate(
      id,
      { $set: data },
      { new: true },
    );
    if (!product) throw new NotFoundException('Product not found');

    if (
      data.stockQuantity !== undefined ||
      data.lowStockThreshold !== undefined ||
      data.trackInventory !== undefined
    ) {
      await this.syncDefaultWarehouseStock(product, {
        stockQuantity: data.stockQuantity,
        lowStockThreshold: data.lowStockThreshold,
        trackInventory: data.trackInventory,
      });
    }

    return product;
  }

  private async syncDefaultWarehouseStock(
    product: ProductDocument,
    payload: {
      stockQuantity?: number;
      lowStockThreshold?: number;
      trackInventory?: boolean;
    },
  ): Promise<void> {
    const trackInventory = payload.trackInventory ?? product.trackInventory;
    if (!trackInventory) return;

    const shouldSyncQuantity = payload.stockQuantity !== undefined;
    const shouldSyncThreshold = payload.lowStockThreshold !== undefined;

    if (!shouldSyncQuantity && !shouldSyncThreshold) {
      return;
    }

    const defaultWarehouse =
      (await this.warehouseModel.findOne({ isDefault: true, isActive: true })) ||
      (await this.warehouseModel.findOne({ isActive: true }));

    if (!defaultWarehouse) {
      return;
    }

    const lowStockThreshold = Math.max(
      0,
      Number(payload.lowStockThreshold ?? product.lowStockThreshold ?? 0),
    );
    const update: Record<string, unknown> = {
      lowStockThreshold,
      criticalStockThreshold: Math.max(0, Math.min(2, lowStockThreshold || 2)),
    };

    if (shouldSyncQuantity) {
      update.quantity = Math.max(0, Number(payload.stockQuantity ?? 0));
    }

    await this.productStockModel.findOneAndUpdate(
      {
        productId: product._id,
        warehouseId: defaultWarehouse._id,
      },
      {
        $set: update,
        $setOnInsert: {
          productId: product._id,
          warehouseId: defaultWarehouse._id,
          reservedQuantity: 0,
          damagedQuantity: 0,
        },
      },
      { upsert: true, new: true },
    );
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
   * Uses ProductPrice if set; otherwise applies PriceLevel.discountPercentage to basePrice
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

    // Fallback: apply price level discount to base price
    const [product, priceLevel] = await Promise.all([
      this.productModel.findById(productId),
      this.priceLevelModel.findById(priceLevelId),
    ]);

    const basePrice = product?.basePrice ?? 0;
    const discountPercentage = priceLevel?.discountPercentage ?? 0;
    if (discountPercentage <= 0) {
      return basePrice;
    }
    return basePrice * (1 - discountPercentage / 100);
  }

  /**
   * Get product prices for all price levels
   */
  async getPrices(productId: string): Promise<ProductPriceDocument[]> {
    return this.productPriceModel
      .find({ productId, isActive: true })
      .sort({ priceLevelId: 1 });
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
  // Favorite
  // ═════════════════════════════════════

  async addToFavorites(
    customerId: string,
    productId: string,
  ): Promise<FavoriteDocument> {
    try {
      const favorite = await this.favoriteModel.create({
        customerId,
        productId,
      });
      await this.productModel.findByIdAndUpdate(productId, {
        $inc: { favoriteCount: 1 },
      });
      return favorite;
    } catch (error: any) {
      if (error.code === 11000) {
        throw new ConflictException('Product already in favorites');
      }
      throw error;
    }
  }

  async removeFromFavorites(
    customerId: string,
    productId: string,
  ): Promise<void> {
    const result = await this.favoriteModel.deleteOne({
      customerId,
      productId,
    });
    if (result.deletedCount > 0) {
      await this.productModel.findByIdAndUpdate(productId, {
        $inc: { favoriteCount: -1 },
      });
    }
  }

  async getFavorites(customerId: string): Promise<FavoriteDocument[]> {
    return this.favoriteModel.find({ customerId }).populate('productId');
  }

  /**
   * Check if a product is in the customer's favorites.
   * Used by the app to show correct heart state without fetching full favorites.
   */
  async isFavorite(
    customerId: string,
    productId: string,
  ): Promise<boolean> {
    const count = await this.favoriteModel.countDocuments({
      customerId,
      productId,
    });
    return count > 0;
  }

  // ═════════════════════════════════════
  // Reviews
  // ═════════════════════════════════════

  async getMyReview(
    productId: string,
    customerId: string,
  ): Promise<ProductReviewDocument | null> {
    return this.productReviewModel
      .findOne({ productId, customerId })
      .populate('customerId', 'responsiblePersonName shopName')
      .exec();
  }

  async addReview(data: any): Promise<ProductReviewDocument> {
    const existing = await this.productReviewModel.findOne({
      productId: data.productId,
      customerId: data.customerId,
    });
    if (existing) {
      throw new BadRequestException('You have already reviewed this product');
    }
    const review = await this.productReviewModel.create(data);
    await this.updateProductRating(data.productId);
    return review;
  }

  async updateReview(
    productId: string,
    reviewId: string,
    customerId: string,
    data: { rating?: number; title?: string; comment?: string; images?: string[] },
  ): Promise<ProductReviewDocument> {
    const review = await this.productReviewModel.findOne({
      _id: reviewId,
      productId,
      customerId,
    });
    if (!review) throw new NotFoundException('Review not found');
    if (data.rating != null) review.rating = data.rating;
    if (data.title !== undefined) review.title = data.title;
    if (data.comment !== undefined) review.comment = data.comment;
    if (data.images !== undefined) review.images = data.images ?? [];
    await review.save();
    await this.updateProductRating(productId);
    return this.productReviewModel
      .findById(reviewId)
      .populate('customerId', 'responsiblePersonName shopName')
      .exec() as Promise<ProductReviewDocument>;
  }

  async getReviews(productId: string): Promise<ProductReviewDocument[]> {
    return this.productReviewModel
      .find({ productId, status: 'approved' })
      .populate('customerId', 'responsiblePersonName shopName')
      .sort({ createdAt: -1 });
  }

  async getReviewsForAdmin(productId: string): Promise<ProductReviewDocument[]> {
    return this.productReviewModel
      .find({ productId })
      .populate('customerId', 'responsiblePersonName shopName companyName')
      .sort({ createdAt: -1 });
  }

  async approveReview(
    productId: string,
    reviewId: string,
    adminId: string,
  ): Promise<ProductReviewDocument> {
    const review = await this.productReviewModel.findOneAndUpdate(
      { _id: reviewId, productId },
      {
        status: 'approved',
        moderatedBy: new Types.ObjectId(adminId),
        moderatedAt: new Date(),
      },
      { new: true },
    )
      .populate('customerId', 'responsiblePersonName shopName companyName')
      .exec();
    if (!review) throw new NotFoundException('Review not found');
    await this.updateProductRating(productId);
    return review;
  }

  async deleteReview(
    productId: string,
    reviewId: string,
  ): Promise<void> {
    const review = await this.productReviewModel.findOneAndDelete({
      _id: reviewId,
      productId,
    });
    if (!review) throw new NotFoundException('Review not found');
    await this.updateProductRating(productId);
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

  /**
   * Get all price levels (including inactive) - for admin
   */
  async findAllPriceLevelsAdmin(): Promise<PriceLevelDocument[]> {
    return this.priceLevelModel.find().sort({ displayOrder: 1, name: 1 });
  }

  /**
   * Get price level by ID
   */
  async findPriceLevelById(id: string): Promise<PriceLevelDocument> {
    const priceLevel = await this.priceLevelModel.findById(id);
    if (!priceLevel) {
      throw new NotFoundException('Price level not found');
    }
    return priceLevel;
  }

  /**
   * Create price level
   */
  async createPriceLevel(createDto: any): Promise<PriceLevelDocument> {
    // Check if code already exists
    const existing = await this.priceLevelModel.findOne({
      code: createDto.code,
    });
    if (existing) {
      throw new ConflictException('Price level with this code already exists');
    }

    // If this is set as default, unset other defaults
    if (createDto.isDefault) {
      await this.priceLevelModel.updateMany(
        { isDefault: true },
        { $set: { isDefault: false } },
      );
    }

    const priceLevel = await this.priceLevelModel.create(createDto);
    return priceLevel;
  }

  /**
   * Update price level
   */
  async updatePriceLevel(
    id: string,
    updateDto: any,
  ): Promise<PriceLevelDocument> {
    const priceLevel = await this.priceLevelModel.findById(id);
    if (!priceLevel) {
      throw new NotFoundException('Price level not found');
    }

    // Check if code is being changed and if it's unique
    if (updateDto.code && updateDto.code !== priceLevel.code) {
      const existing = await this.priceLevelModel.findOne({
        code: updateDto.code,
      });
      if (existing) {
        throw new ConflictException(
          'Price level with this code already exists',
        );
      }
    }

    // If this is being set as default, unset other defaults
    if (updateDto.isDefault === true) {
      await this.priceLevelModel.updateMany(
        { isDefault: true, _id: { $ne: id } },
        { $set: { isDefault: false } },
      );
    }

    Object.assign(priceLevel, updateDto);
    await priceLevel.save();

    return priceLevel;
  }

  /**
   * Get default price level
   */
  async getDefaultPriceLevel(): Promise<PriceLevelDocument> {
    const priceLevel = await this.priceLevelModel.findOne({
      isDefault: true,
      isActive: true,
    });

    if (!priceLevel) {
      // Fallback: get first active price level
      const fallback = await this.priceLevelModel
        .findOne({ isActive: true })
        .sort({ displayOrder: 1, name: 1 });

      if (!fallback) {
        throw new NotFoundException('No price level found');
      }

      return fallback;
    }

    return priceLevel;
  }

  /**
   * Delete price level
   */
  async deletePriceLevel(id: string): Promise<void> {
    const priceLevel = await this.priceLevelModel.findById(id);
    if (!priceLevel) {
      throw new NotFoundException('Price level not found');
    }

    // Check if used in product prices
    const usedInProducts = await this.productPriceModel.countDocuments({
      priceLevelId: new Types.ObjectId(id),
    });

    if (usedInProducts > 0) {
      throw new BadRequestException(
        `Cannot delete price level. It is used in ${usedInProducts} product price(s).`,
      );
    }

    // Check if used in customers
    const usedInCustomers = await this.customerModel.countDocuments({
      priceLevelId: new Types.ObjectId(id),
    });

    if (usedInCustomers > 0) {
      throw new BadRequestException(
        `Cannot delete price level. It is used by ${usedInCustomers} customer(s).`,
      );
    }

    // Check if it's the default level
    if (priceLevel.isDefault) {
      throw new BadRequestException(
        'Cannot delete the default price level. Please set another level as default first.',
      );
    }

    await this.priceLevelModel.findByIdAndDelete(id);
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
