import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DailyStats, DailyStatsDocument } from './schemas/daily-stats.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Dashboard Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class DashboardService {
  constructor(
    @InjectModel(DailyStats.name)
    private dailyStatsModel: Model<DailyStatsDocument>,
    @InjectModel('Order') private orderModel: Model<any>,
    @InjectModel('Customer') private customerModel: Model<any>,
    @InjectModel('Product') private productModel: Model<any>,
    @InjectModel('ReturnRequest') private returnModel: Model<any>,
  ) {}

  /**
   * Get complete dashboard stats
   */
  async getDashboardStats(): Promise<any> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      stats,
      salesChart,
      topProducts,
      topCustomers,
      lowStock,
      recentOrders,
      pendingActions,
    ] = await Promise.all([
      this.getOverviewStats(),
      this.getSalesChart(7),
      this.getTopProducts(10),
      this.getTopCustomers(10),
      this.getLowStockProducts(10),
      this.getRecentOrders(10),
      this.getPendingActions(),
    ]);

    return {
      overview: stats,
      salesChart,
      topProducts,
      topCustomers,
      lowStock,
      recentOrders,
      pendingActions,
    };
  }

  /**
   * Get overview stats
   */
  async getOverviewStats(): Promise<any> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const thisMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
    const lastMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0);

    const [
      todayOrders,
      thisMonthOrders,
      lastMonthOrders,
      todayRevenue,
      thisMonthRevenue,
      lastMonthRevenue,
      totalCustomers,
      newCustomersThisMonth,
      totalProducts,
      activeProducts,
    ] = await Promise.all([
      // Orders
      this.orderModel.countDocuments({ createdAt: { $gte: today } }),
      this.orderModel.countDocuments({ createdAt: { $gte: thisMonth } }),
      this.orderModel.countDocuments({
        createdAt: { $gte: lastMonth, $lt: thisMonth },
      }),

      // Revenue
      this.getRevenue(today, new Date()),
      this.getRevenue(thisMonth, new Date()),
      this.getRevenue(lastMonth, lastMonthEnd),

      // Customers (status is virtual from approvedAt - use approvedAt for approved/active count)
      this.customerModel.countDocuments({ approvedAt: { $exists: true, $ne: null } }),
      this.customerModel.countDocuments({ createdAt: { $gte: thisMonth } }),

      // Products
      this.productModel.countDocuments(),
      this.productModel.countDocuments({ status: 'active' }),
    ]);

    return {
      orders: {
        today: todayOrders,
        thisMonth: thisMonthOrders,
        lastMonth: lastMonthOrders,
        change: this.calculateChange(lastMonthOrders, thisMonthOrders),
      },
      revenue: {
        today: todayRevenue,
        thisMonth: thisMonthRevenue,
        lastMonth: lastMonthRevenue,
        change: this.calculateChange(lastMonthRevenue, thisMonthRevenue),
      },
      customers: {
        total: totalCustomers,
        newThisMonth: newCustomersThisMonth,
      },
      products: {
        total: totalProducts,
        active: activeProducts,
      },
    };
  }

  /**
   * Get sales chart data
   */
  async getSalesChart(days: number = 7): Promise<any[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const result = await this.orderModel.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $nin: ['cancelled', 'refunded'] },
        },
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' },
          },
          orders: { $sum: 1 },
          revenue: { $sum: '$total' },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } },
    ]);

    return result.map((r) => ({
      date: new Date(r._id.year, r._id.month - 1, r._id.day),
      orders: r.orders,
      revenue: r.revenue,
    }));
  }

  /**
   * Get orders chart by status
   */
  async getOrdersChart(): Promise<any[]> {
    const result = await this.orderModel.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    return result;
  }

  /**
   * Get top selling products
   */
  async getTopProducts(limit: number = 10): Promise<any[]> {
    return this.productModel
      .find({ status: 'active' })
      .sort({ soldCount: -1 })
      .limit(limit)
      .select('name nameAr sku mainImage basePrice soldCount stockQuantity')
      .lean();
  }

  /**
   * Get top customers by order value
   */
  async getTopCustomers(limit: number = 10): Promise<any[]> {
    const result = await this.orderModel.aggregate([
      {
        $match: {
          customerId: { $exists: true, $ne: null },
          status: { $nin: ['cancelled', 'refunded'] },
        },
      },
      {
        $group: {
          _id: '$customerId',
          totalOrders: { $sum: 1 },
          totalSpent: { $sum: '$total' },
          lastOrderDate: { $max: '$createdAt' },
        },
      },
      { $sort: { totalSpent: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'customers',
          localField: '_id',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $project: {
          _id: 1,
          shopName: '$customer.shopName',
          responsiblePersonName: '$customer.responsiblePersonName',
          phone: '$customer.phone',
          totalOrders: 1,
          totalSpent: 1,
          lastOrderDate: 1,
        },
      },
    ]);

    return result;
  }

  /**
   * Get low stock products
   */
  async getLowStockProducts(limit: number = 10): Promise<any[]> {
    return this.productModel
      .find({
        status: 'active',
        $expr: { $lte: ['$stockQuantity', '$lowStockThreshold'] },
      })
      .sort({ stockQuantity: 1 })
      .limit(limit)
      .select('name nameAr sku mainImage stockQuantity lowStockThreshold')
      .lean();
  }

  /**
   * Get recent orders
   */
  async getRecentOrders(limit: number = 10): Promise<any[]> {
    return this.orderModel
      .find()
      .populate('customerId', 'shopName responsiblePersonName phone')
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('orderNumber status total paymentStatus createdAt')
      .lean();
  }

  /**
   * Get pending actions
   */
  async getPendingActions(): Promise<any> {
    const [
      pendingOrders,
      pendingPayments,
      pendingReturns,
      pendingApprovals,
      lowStockCount,
    ] = await Promise.all([
      this.orderModel.countDocuments({ status: 'pending' }),
      this.orderModel.countDocuments({
        paymentStatus: 'unpaid',
        paymentMethod: 'bank_transfer',
      }),
      this.returnModel.countDocuments({ status: 'pending' }),
      this.customerModel.countDocuments({ approvedAt: { $exists: false } }),
      this.productModel.countDocuments({
        status: 'active',
        $expr: { $lte: ['$stockQuantity', '$lowStockThreshold'] },
      }),
    ]);

    return {
      pendingOrders,
      pendingPayments,
      pendingReturns,
      pendingApprovals,
      lowStockCount,
      total:
        pendingOrders + pendingPayments + pendingReturns + pendingApprovals,
    };
  }

  /**
   * Calculate revenue for date range
   */
  private async getRevenue(startDate: Date, endDate: Date): Promise<number> {
    const result = await this.orderModel.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate, $lte: endDate },
          status: { $nin: ['cancelled', 'refunded'] },
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$total' },
        },
      },
    ]);

    return result[0]?.total || 0;
  }

  /**
   * Calculate percentage change
   */
  private calculateChange(previous: number, current: number): number {
    if (previous === 0) return current > 0 ? 100 : 0;
    return Number((((current - previous) / previous) * 100).toFixed(1));
  }
}
