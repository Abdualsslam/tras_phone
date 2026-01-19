import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import { SearchSuggestionsQueryDto, AutocompleteQueryDto } from './dto/advanced-search-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Products Search Suggestions Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ProductsSearchSuggestionsService {
  constructor(
    @InjectModel(Product.name)
    private productModel: Model<ProductDocument>,
  ) {}

  /**
   * Get search suggestions based on query
   */
  async getSuggestions(
    queryDto: SearchSuggestionsQueryDto,
  ): Promise<{ suggestions: string[]; tags: string[]; products: any[] }> {
    const { query, limit = 10 } = queryDto;

    if (!query || query.trim().length < 2) {
      return { suggestions: [], tags: [], products: [] };
    }

    const trimmedQuery = query.trim();

    // Get product name suggestions
    const productSuggestions = await this.productModel
      .find({
        $and: [
          { status: 'active' },
          { isActive: true },
          {
            $or: [
              { name: { $regex: trimmedQuery, $options: 'i' } },
              { nameAr: { $regex: trimmedQuery, $options: 'i' } },
              { tags: { $in: [new RegExp(trimmedQuery, 'i')] } },
            ],
          },
        ],
      })
      .select('name nameAr tags')
      .limit(limit)
      .lean();

    // Extract unique suggestions from names
    const nameSuggestions = new Set<string>();
    productSuggestions.forEach((product) => {
      if (product.name && product.name.toLowerCase().includes(trimmedQuery.toLowerCase())) {
        nameSuggestions.add(product.name);
      }
      if (product.nameAr && product.nameAr.includes(trimmedQuery)) {
        nameSuggestions.add(product.nameAr);
      }
    });

    // Extract tags that match query
    const matchingTags = new Set<string>();
    productSuggestions.forEach((product) => {
      if (product.tags && Array.isArray(product.tags)) {
        product.tags.forEach((tag: string) => {
          if (tag.toLowerCase().includes(trimmedQuery.toLowerCase())) {
            matchingTags.add(tag);
          }
        });
      }
    });

    return {
      suggestions: Array.from(nameSuggestions).slice(0, limit),
      tags: Array.from(matchingTags).slice(0, limit),
      products: productSuggestions.slice(0, 5).map((p) => ({
        id: p._id,
        name: p.name,
        nameAr: p.nameAr,
      })),
    };
  }

  /**
   * Get autocomplete suggestions
   */
  async getAutocomplete(
    queryDto: AutocompleteQueryDto,
  ): Promise<string[]> {
    const { query, limit = 5 } = queryDto;

    if (!query || query.trim().length === 0) {
      return [];
    }

    const trimmedQuery = query.trim();

    // Use aggregation for better performance
    const pipeline = [
      {
        $match: {
          $and: [
            { status: 'active' },
            { isActive: true },
            {
              $or: [
                { name: { $regex: `^${this.escapeRegex(trimmedQuery)}`, $options: 'i' } },
                { nameAr: { $regex: `^${this.escapeRegex(trimmedQuery)}`, $options: 'i' } },
                { tags: { $in: [new RegExp(`^${this.escapeRegex(trimmedQuery)}`, 'i')] } },
              ],
            },
          ],
        },
      },
      {
        $project: {
          name: 1,
          nameAr: 1,
          tags: 1,
        },
      },
      { $limit: limit * 3 }, // Get more to filter unique
    ];

    const results = await this.productModel.aggregate(pipeline);
    const suggestions = new Set<string>();

    results.forEach((product) => {
      if (product.name && product.name.toLowerCase().startsWith(trimmedQuery.toLowerCase())) {
        suggestions.add(product.name);
      }
      if (product.nameAr && product.nameAr.startsWith(trimmedQuery)) {
        suggestions.add(product.nameAr);
      }
      if (product.tags) {
        product.tags.forEach((tag: string) => {
          if (tag.toLowerCase().startsWith(trimmedQuery.toLowerCase())) {
            suggestions.add(tag);
          }
        });
      }
    });

    return Array.from(suggestions).slice(0, limit);
  }

  /**
   * Get popular tags
   */
  async getPopularTags(limit: number = 20): Promise<{ tag: string; count: number }[]> {
    const pipeline = [
      {
        $match: {
          status: 'active',
          isActive: true,
          tags: { $exists: true, $ne: [] },
        },
      },
      { $unwind: '$tags' as const },
      {
        $group: {
          _id: '$tags',
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 as const } },
      { $limit: limit },
      {
        $project: {
          tag: '$_id',
          count: 1,
          _id: 0,
        },
      },
    ];

    return this.productModel.aggregate(pipeline);
  }

  /**
   * Get all available tags
   */
  async getAllTags(): Promise<string[]> {
    const pipeline = [
      {
        $match: {
          status: 'active',
          isActive: true,
          tags: { $exists: true, $ne: [] },
        },
      },
      { $unwind: '$tags' as const },
      {
        $group: {
          _id: '$tags',
        },
      },
      { $sort: { _id: 1 as const } },
      {
        $project: {
          _id: 0,
          tag: '$_id',
        },
      },
    ];

    const results = await this.productModel.aggregate(pipeline);
    return results.map((r) => r.tag);
  }

  /**
   * Escape special regex characters
   */
  private escapeRegex(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
}
