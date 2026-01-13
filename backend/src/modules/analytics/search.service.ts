import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { SearchLog, SearchLogDocument } from './schemas/search-log.schema';
import {
  RecentlyViewed,
  RecentlyViewedDocument,
} from './schemas/recently-viewed.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Search Analytics Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SearchService {
  constructor(
    @InjectModel(SearchLog.name)
    private searchLogModel: Model<SearchLogDocument>,
    @InjectModel(RecentlyViewed.name)
    private recentlyViewedModel: Model<RecentlyViewedDocument>,
  ) {}

  // ═════════════════════════════════════
  // Search Logging
  // ═════════════════════════════════════

  /**
   * Log a search query
   */
  async logSearch(data: {
    query: string;
    customerId?: string;
    sessionId?: string;
    resultsCount: number;
    filters?: any;
    deviceType?: string;
    userAgent?: string;
    ipAddress?: string;
  }): Promise<SearchLogDocument> {
    return this.searchLogModel.create({
      ...data,
      customerId: data.customerId
        ? new Types.ObjectId(data.customerId)
        : undefined,
    });
  }

  /**
   * Log product click from search
   */
  async logSearchClick(searchId: string, productId: string): Promise<void> {
    await this.searchLogModel.findByIdAndUpdate(searchId, {
      $push: { clickedProducts: new Types.ObjectId(productId) },
    });
  }

  /**
   * Log purchase from search
   */
  async logSearchPurchase(searchId: string, productId: string): Promise<void> {
    await this.searchLogModel.findByIdAndUpdate(searchId, {
      purchasedProduct: new Types.ObjectId(productId),
    });
  }

  // ═════════════════════════════════════
  // Popular Searches
  // ═════════════════════════════════════

  /**
   * Get popular searches
   */
  async getPopularSearches(limit: number = 20): Promise<any[]> {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    return this.searchLogModel.aggregate([
      {
        $match: {
          createdAt: { $gte: thirtyDaysAgo },
          resultsCount: { $gt: 0 },
        },
      },
      {
        $group: {
          _id: { $toLower: { $trim: { input: '$query' } } },
          searchCount: { $sum: 1 },
          avgResults: { $avg: '$resultsCount' },
          lastSearched: { $max: '$createdAt' },
        },
      },
      { $sort: { searchCount: -1 } },
      { $limit: limit },
      {
        $project: {
          query: '$_id',
          searchCount: 1,
          avgResults: { $round: ['$avgResults', 0] },
          lastSearched: 1,
          _id: 0,
        },
      },
    ]);
  }

  /**
   * Get trending searches (fast growing)
   */
  async getTrendingSearches(limit: number = 10): Promise<any[]> {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 7);
    const twoWeeksAgo = new Date(today);
    twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);

    const [thisWeek, lastWeek] = await Promise.all([
      this.searchLogModel.aggregate([
        { $match: { createdAt: { $gte: weekAgo } } },
        {
          $group: {
            _id: { $toLower: { $trim: { input: '$query' } } },
            count: { $sum: 1 },
          },
        },
      ]),
      this.searchLogModel.aggregate([
        { $match: { createdAt: { $gte: twoWeeksAgo, $lt: weekAgo } } },
        {
          $group: {
            _id: { $toLower: { $trim: { input: '$query' } } },
            count: { $sum: 1 },
          },
        },
      ]),
    ]);

    const lastWeekMap = new Map(lastWeek.map((l) => [l._id, l.count]));

    const trending = thisWeek
      .map((t) => {
        const lastCount = lastWeekMap.get(t._id) || 0;
        const growth =
          lastCount > 0 ? ((t.count - lastCount) / lastCount) * 100 : 100;
        return {
          query: t._id,
          thisWeekCount: t.count,
          lastWeekCount: lastCount,
          growth: Math.round(growth),
        };
      })
      .filter((t) => t.growth > 0)
      .sort((a, b) => b.growth - a.growth)
      .slice(0, limit);

    return trending;
  }

  /**
   * Get searches with no results
   */
  async getNoResultSearches(limit: number = 20): Promise<any[]> {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    return this.searchLogModel.aggregate([
      { $match: { createdAt: { $gte: thirtyDaysAgo }, resultsCount: 0 } },
      {
        $group: {
          _id: { $toLower: { $trim: { input: '$query' } } },
          count: { $sum: 1 },
          lastSearched: { $max: '$createdAt' },
        },
      },
      { $sort: { count: -1 } },
      { $limit: limit },
      {
        $project: {
          query: '$_id',
          count: 1,
          lastSearched: 1,
          _id: 0,
        },
      },
    ]);
  }

  /**
   * Get search analytics summary
   */
  async getSearchAnalytics(startDate: Date, endDate: Date): Promise<any> {
    const [summary, dailyStats, topSearches] = await Promise.all([
      this.searchLogModel.aggregate([
        { $match: { createdAt: { $gte: startDate, $lte: endDate } } },
        {
          $group: {
            _id: null,
            totalSearches: { $sum: 1 },
            uniqueQueries: { $addToSet: '$query' },
            avgResultsCount: { $avg: '$resultsCount' },
            noResultsCount: {
              $sum: { $cond: [{ $eq: ['$resultsCount', 0] }, 1, 0] },
            },
            clickedSearches: {
              $sum: {
                $cond: [
                  {
                    $gt: [{ $size: { $ifNull: ['$clickedProducts', []] } }, 0],
                  },
                  1,
                  0,
                ],
              },
            },
            purchasedSearches: {
              $sum: { $cond: [{ $ne: ['$purchasedProduct', null] }, 1, 0] },
            },
          },
        },
      ]),
      this.searchLogModel.aggregate([
        { $match: { createdAt: { $gte: startDate, $lte: endDate } } },
        {
          $group: {
            _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            count: { $sum: 1 },
          },
        },
        { $sort: { _id: 1 } },
      ]),
      this.getPopularSearches(10),
    ]);

    const stats = summary[0] || {
      totalSearches: 0,
      uniqueQueries: [],
      avgResultsCount: 0,
      noResultsCount: 0,
      clickedSearches: 0,
      purchasedSearches: 0,
    };

    return {
      totalSearches: stats.totalSearches,
      uniqueQueries: stats.uniqueQueries?.length || 0,
      avgResultsCount: Math.round(stats.avgResultsCount || 0),
      noResultsRate:
        stats.totalSearches > 0
          ? ((stats.noResultsCount / stats.totalSearches) * 100).toFixed(1)
          : 0,
      clickThroughRate:
        stats.totalSearches > 0
          ? ((stats.clickedSearches / stats.totalSearches) * 100).toFixed(1)
          : 0,
      conversionRate:
        stats.totalSearches > 0
          ? ((stats.purchasedSearches / stats.totalSearches) * 100).toFixed(1)
          : 0,
      dailyStats,
      topSearches,
    };
  }

  // ═════════════════════════════════════
  // Recently Viewed Products
  // ═════════════════════════════════════

  /**
   * Track product view
   */
  async trackProductView(customerId: string, productId: string): Promise<void> {
    await this.recentlyViewedModel.findOneAndUpdate(
      {
        customerId: new Types.ObjectId(customerId),
        productId: new Types.ObjectId(productId),
      },
      {
        $inc: { viewCount: 1 },
        $set: { lastViewedAt: new Date() },
      },
      { upsert: true },
    );
  }

  /**
   * Get recently viewed products for customer
   */
  async getRecentlyViewed(
    customerId: string,
    limit: number = 20,
  ): Promise<any[]> {
    return this.recentlyViewedModel
      .find({ customerId: new Types.ObjectId(customerId) })
      .populate(
        'productId',
        'name nameAr slug mainImage basePrice stockQuantity',
      )
      .sort({ lastViewedAt: -1 })
      .limit(limit)
      .lean();
  }

  /**
   * Clear recently viewed for customer
   */
  async clearRecentlyViewed(customerId: string): Promise<void> {
    await this.recentlyViewedModel.deleteMany({
      customerId: new Types.ObjectId(customerId),
    });
  }
}
