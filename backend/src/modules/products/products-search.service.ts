import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import { AdvancedSearchQueryDto } from './dto/advanced-search-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Products Search Service - Advanced Search Implementation
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ProductsSearchService {
  constructor(
    @InjectModel(Product.name)
    private productModel: Model<ProductDocument>,
  ) {}

  /**
   * Advanced search with multiple search strategies
   */
  async advancedSearch(
    queryDto: AdvancedSearchQueryDto,
  ): Promise<{ data: ProductDocument[]; total: number; pagination: any }> {
    const {
      query,
      searchFields = ['name', 'nameAr', 'tags', 'description', 'shortDescription', 'sku'],
      tags = [],
      tagMode = 'OR',
      fuzzy = false,
      sortBy = 'relevance',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
      categoryId,
      brandId,
      qualityTypeId,
      deviceId,
      minPrice,
      maxPrice,
      status = 'active',
      isActive = true,
      featured,
      newArrival,
      bestSeller,
    } = queryDto;

    const skip = (page - 1) * limit;

    // Build base query
    const baseQuery: any = {};

    if (status) baseQuery.status = status;
    if (isActive !== undefined) baseQuery.isActive = isActive;
    if (categoryId) baseQuery.categoryId = new Types.ObjectId(categoryId);
    if (brandId) baseQuery.brandId = new Types.ObjectId(brandId);
    if (qualityTypeId) baseQuery.qualityTypeId = new Types.ObjectId(qualityTypeId);
    if (deviceId) {
      baseQuery.compatibleDevices = {
        $in: [new Types.ObjectId(deviceId), deviceId as any],
      };
    }
    if (featured) baseQuery.isFeatured = true;
    if (newArrival) baseQuery.isNewArrival = true;
    if (bestSeller) baseQuery.isBestSeller = true;

    // Price filter
    if (minPrice || maxPrice) {
      baseQuery.basePrice = {};
      if (minPrice) baseQuery.basePrice.$gte = minPrice;
      if (maxPrice) baseQuery.basePrice.$lte = maxPrice;
    }

    // Build search query
    const searchQuery = this.buildSearchQuery(query, searchFields, fuzzy);
    
    // Build tag query
    const tagQuery = this.buildTagQuery(tags, tagMode);

    // Combine queries
    const finalQuery: any = {
      ...baseQuery,
      ...(searchQuery && { $and: [searchQuery] }),
      ...(tagQuery && tagQuery),
    };

    // Build aggregation pipeline for relevance scoring
    const pipeline: any[] = [
      { $match: finalQuery },
      {
        $addFields: {
          relevanceScore: this.buildRelevanceScore(query, searchFields, tags),
        },
      },
    ];

    // Determine sort
    let sortObj: any = {};
    if (sortBy === 'relevance') {
      sortObj = { relevanceScore: sortOrder === 'desc' ? -1 : 1 };
    } else {
      sortObj = { [sortBy]: sortOrder === 'desc' ? -1 : 1 };
      // Add secondary sort by relevance score for non-relevance sorts
      pipeline.push({
        $sort: { relevanceScore: -1 },
      });
    }

    // Add sorting
    pipeline.push({ $sort: sortObj });

    // Add pagination
    pipeline.push(
      { $skip: skip },
      { $limit: limit },
    );

    // Populate relations
    pipeline.push(
      {
        $lookup: {
          from: 'brands',
          localField: 'brandId',
          foreignField: '_id',
          as: 'brandId',
        },
      },
      { $unwind: { path: '$brandId', preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: 'categories',
          localField: 'categoryId',
          foreignField: '_id',
          as: 'categoryId',
        },
      },
      { $unwind: { path: '$categoryId', preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: 'qualitytypes',
          localField: 'qualityTypeId',
          foreignField: '_id',
          as: 'qualityTypeId',
        },
      },
      { $unwind: { path: '$qualityTypeId', preserveNullAndEmptyArrays: true } },
    );

    // Project only needed fields from populated relations
    pipeline.push({
      $project: {
        'brandId.name': 1,
        'brandId.nameAr': 1,
        'brandId.slug': 1,
        'categoryId.name': 1,
        'categoryId.nameAr': 1,
        'categoryId.slug': 1,
        'qualityTypeId.name': 1,
        'qualityTypeId.nameAr': 1,
        'qualityTypeId.code': 1,
        'qualityTypeId.color': 1,
      },
    });

    // Execute aggregation
    const [results, countResult] = await Promise.all([
      this.productModel.aggregate(pipeline),
      this.productModel.countDocuments(finalQuery),
    ]);

    // Convert to ProductDocument[]
    const data = results.map((doc) => 
      this.productModel.hydrate(doc) as ProductDocument
    );

    return {
      data,
      total: countResult,
      pagination: {
        page,
        limit,
        pages: Math.ceil(countResult / limit),
      },
    };
  }

  /**
   * Build search query based on search fields and fuzzy option
   */
  private buildSearchQuery(
    query: string,
    searchFields: string[],
    fuzzy: boolean,
  ): any {
    if (!query || query.trim().length === 0) {
      return null;
    }

    const trimmedQuery = query.trim();
    const searchConditions: any[] = [];

    // Exact match (highest priority)
    searchFields.forEach((field) => {
      searchConditions.push({
        [field]: { $regex: `^${this.escapeRegex(trimmedQuery)}$`, $options: 'i' },
      });
    });

    // Starts with (high priority)
    searchFields.forEach((field) => {
      searchConditions.push({
        [field]: { $regex: `^${this.escapeRegex(trimmedQuery)}`, $options: 'i' },
      });
    });

    // Contains (normal priority)
    if (fuzzy) {
      // Fuzzy search: allow for typos
      const fuzzyPattern = trimmedQuery.split('').map(char => 
        this.escapeRegex(char)
      ).join('.*?');
      searchFields.forEach((field) => {
        searchConditions.push({
          [field]: { $regex: fuzzyPattern, $options: 'i' },
        });
      });
    } else {
      // Regular contains
      searchFields.forEach((field) => {
        searchConditions.push({
          [field]: { $regex: this.escapeRegex(trimmedQuery), $options: 'i' },
        });
      });
    }

    // Use $or for search fields and $and for combining with other conditions
    return { $or: searchConditions };
  }

  /**
   * Build tag query
   */
  private buildTagQuery(tags: string[], tagMode: 'AND' | 'OR'): any {
    if (!tags || tags.length === 0) {
      return null;
    }

    if (tagMode === 'AND') {
      // All tags must match
      return {
        tags: { $all: tags },
      };
    } else {
      // Any tag can match (OR)
      return {
        tags: { $in: tags },
      };
    }
  }

  /**
   * Build relevance score expression for aggregation
   */
  private buildRelevanceScore(
    query: string,
    searchFields: string[],
    tags: string[],
  ): any {
    if (!query) {
      return { $literal: 0 };
    }

    const trimmedQuery = query.trim().toLowerCase();
    const scoreConditions: any[] = [];

    // Exact match score (100 points)
    searchFields.forEach((field) => {
      scoreConditions.push({
        $cond: [
          { $eq: [{ $toLower: { $ifNull: [`$${field}`, ''] } }, trimmedQuery] },
          100,
          0,
        ],
      });
    });

    // Starts with score (50 points)
    searchFields.forEach((field) => {
      scoreConditions.push({
        $cond: [
          {
            $regexMatch: {
              input: { $toLower: { $ifNull: [`$${field}`, ''] } },
              regex: `^${this.escapeRegex(trimmedQuery)}`,
              options: 'i',
            },
          },
          50,
          0,
        ],
      });
    });

    // Contains score (25 points)
    searchFields.forEach((field) => {
      scoreConditions.push({
        $cond: [
          {
            $regexMatch: {
              input: { $toLower: { $ifNull: [`$${field}`, ''] } },
              regex: this.escapeRegex(trimmedQuery),
              options: 'i',
            },
          },
          25,
          0,
        ],
      });
    });

    // Tag match score (10 points per tag)
    if (tags && tags.length > 0) {
      scoreConditions.push({
        $multiply: [
          {
            $size: {
              $setIntersection: ['$tags', tags],
            },
          },
          10,
        ],
      });
    }

    return {
      $add: scoreConditions.length > 0 ? scoreConditions : [{ $literal: 0 }],
    };
  }

  /**
   * Escape special regex characters
   */
  private escapeRegex(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  /**
   * Simple text search (backward compatible)
   */
  async simpleSearch(
    query: string,
    filters?: any,
  ): Promise<{ data: ProductDocument[]; total: number; pagination: any }> {
    return this.advancedSearch({
      query,
      ...filters,
    } as AdvancedSearchQueryDto);
  }
}
