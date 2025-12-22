import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { DailyStats, DailyStatsDocument } from './schemas/daily-stats.schema';
import { ProductAnalytics, ProductAnalyticsDocument } from './schemas/product-analytics.schema';
import { SearchAnalytics, SearchAnalyticsDocument } from './schemas/search-analytics.schema';
import { Report, ReportDocument, ReportType, ReportStatus } from './schemas/report.schema';

@Injectable()
export class AnalyticsService {
    constructor(
        @InjectModel(DailyStats.name) private dailyStatsModel: Model<DailyStatsDocument>,
        @InjectModel(ProductAnalytics.name) private productAnalyticsModel: Model<ProductAnalyticsDocument>,
        @InjectModel(SearchAnalytics.name) private searchAnalyticsModel: Model<SearchAnalyticsDocument>,
        @InjectModel(Report.name) private reportModel: Model<ReportDocument>,
    ) { }

    // ==================== Dashboard Stats ====================

    async getDashboardStats(): Promise<any> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        const weekAgo = new Date(today);
        weekAgo.setDate(weekAgo.getDate() - 7);

        const monthAgo = new Date(today);
        monthAgo.setMonth(monthAgo.getMonth() - 1);

        const [todayStats, yesterdayStats, weekStats, monthStats] = await Promise.all([
            this.dailyStatsModel.findOne({ date: today }),
            this.dailyStatsModel.findOne({ date: yesterday }),
            this.getAggregatedStats(weekAgo, today),
            this.getAggregatedStats(monthAgo, today),
        ]);

        return {
            today: todayStats || this.getEmptyStats(),
            yesterday: yesterdayStats || this.getEmptyStats(),
            week: weekStats,
            month: monthStats,
            comparison: {
                ordersChange: this.calculateChange(
                    yesterdayStats?.sales?.totalOrders || 0,
                    todayStats?.sales?.totalOrders || 0
                ),
                revenueChange: this.calculateChange(
                    yesterdayStats?.sales?.netRevenue || 0,
                    todayStats?.sales?.netRevenue || 0
                ),
            },
        };
    }

    async getAggregatedStats(startDate: Date, endDate: Date): Promise<any> {
        const result = await this.dailyStatsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $group: {
                    _id: null,
                    totalOrders: { $sum: '$sales.totalOrders' },
                    completedOrders: { $sum: '$sales.completedOrders' },
                    grossRevenue: { $sum: '$sales.grossRevenue' },
                    netRevenue: { $sum: '$sales.netRevenue' },
                    discounts: { $sum: '$sales.discounts' },
                    refunds: { $sum: '$sales.refunds' },
                    itemsSold: { $sum: '$sales.itemsSold' },
                    newCustomers: { $sum: '$customers.newCustomers' },
                    pageViews: { $sum: '$traffic.pageViews' },
                    uniqueVisitors: { $sum: '$traffic.uniqueVisitors' },
                },
            },
        ]);

        if (result.length === 0) return this.getEmptyStats();

        const data = result[0];
        data.averageOrderValue = data.totalOrders > 0
            ? data.netRevenue / data.totalOrders
            : 0;

        return data;
    }

    async getRevenueChart(startDate: Date, endDate: Date, groupBy: string = 'day'): Promise<any[]> {
        const groupFormat = groupBy === 'month'
            ? { year: { $year: '$date' }, month: { $month: '$date' } }
            : groupBy === 'week'
                ? { year: { $year: '$date' }, week: { $week: '$date' } }
                : { year: { $year: '$date' }, month: { $month: '$date' }, day: { $dayOfMonth: '$date' } };

        return this.dailyStatsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $group: {
                    _id: groupFormat,
                    revenue: { $sum: '$sales.netRevenue' },
                    orders: { $sum: '$sales.totalOrders' },
                    date: { $first: '$date' },
                },
            },
            { $sort: { date: 1 } },
        ]);
    }

    async getOrdersChart(startDate: Date, endDate: Date): Promise<any[]> {
        return this.dailyStatsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $project: {
                    date: 1,
                    completed: '$sales.completedOrders',
                    cancelled: '$sales.cancelledOrders',
                    returned: '$sales.returnedOrders',
                    pending: { $subtract: ['$sales.totalOrders', { $add: ['$sales.completedOrders', '$sales.cancelledOrders'] }] },
                },
            },
            { $sort: { date: 1 } },
        ]);
    }

    // ==================== Product Analytics ====================

    async trackProductView(productId: string): Promise<void> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        await this.productAnalyticsModel.findOneAndUpdate(
            { product: new Types.ObjectId(productId), date: today },
            { $inc: { views: 1 } },
            { upsert: true }
        );
    }

    async trackAddToCart(productId: string): Promise<void> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        await this.productAnalyticsModel.findOneAndUpdate(
            { product: new Types.ObjectId(productId), date: today },
            { $inc: { addToCart: 1 } },
            { upsert: true }
        );
    }

    async getTopProducts(startDate: Date, endDate: Date, limit: number = 10): Promise<any[]> {
        return this.productAnalyticsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $group: {
                    _id: '$product',
                    views: { $sum: '$views' },
                    addToCart: { $sum: '$addToCart' },
                    unitsSold: { $sum: '$unitsSold' },
                    revenue: { $sum: '$revenue' },
                },
            },
            { $sort: { revenue: -1 } },
            { $limit: limit },
            {
                $lookup: {
                    from: 'products',
                    localField: '_id',
                    foreignField: '_id',
                    as: 'product',
                },
            },
            { $unwind: '$product' },
            {
                $project: {
                    _id: 1,
                    name: '$product.nameAr',
                    sku: '$product.sku',
                    image: { $arrayElemAt: ['$product.images', 0] },
                    views: 1,
                    addToCart: 1,
                    unitsSold: 1,
                    revenue: 1,
                    conversionRate: {
                        $cond: [
                            { $gt: ['$views', 0] },
                            { $multiply: [{ $divide: ['$unitsSold', '$views'] }, 100] },
                            0,
                        ],
                    },
                },
            },
        ]);
    }

    async getLowPerformingProducts(limit: number = 10): Promise<any[]> {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        return this.productAnalyticsModel.aggregate([
            { $match: { date: { $gte: thirtyDaysAgo } } },
            {
                $group: {
                    _id: '$product',
                    views: { $sum: '$views' },
                    unitsSold: { $sum: '$unitsSold' },
                },
            },
            { $match: { views: { $gt: 100 }, unitsSold: { $lt: 5 } } },
            { $sort: { views: -1 } },
            { $limit: limit },
            {
                $lookup: {
                    from: 'products',
                    localField: '_id',
                    foreignField: '_id',
                    as: 'product',
                },
            },
            { $unwind: '$product' },
        ]);
    }

    // ==================== Search Analytics ====================

    async trackSearch(query: string, resultsCount: number): Promise<void> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const update: any = { $inc: { searchCount: 1 } };
        if (resultsCount === 0) {
            update.$inc.noResultsCount = 1;
        }

        await this.searchAnalyticsModel.findOneAndUpdate(
            { query: query.toLowerCase().trim(), date: today },
            update,
            { upsert: true }
        );
    }

    async getTopSearches(startDate: Date, endDate: Date, limit: number = 20): Promise<any[]> {
        return this.searchAnalyticsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $group: {
                    _id: '$query',
                    searchCount: { $sum: '$searchCount' },
                    clickCount: { $sum: '$clickCount' },
                    purchaseCount: { $sum: '$purchaseCount' },
                    noResultsCount: { $sum: '$noResultsCount' },
                },
            },
            { $sort: { searchCount: -1 } },
            { $limit: limit },
        ]);
    }

    async getNoResultSearches(limit: number = 20): Promise<any[]> {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        return this.searchAnalyticsModel.aggregate([
            { $match: { date: { $gte: thirtyDaysAgo }, noResultsCount: { $gt: 0 } } },
            {
                $group: {
                    _id: '$query',
                    noResultsCount: { $sum: '$noResultsCount' },
                },
            },
            { $sort: { noResultsCount: -1 } },
            { $limit: limit },
        ]);
    }

    // ==================== Sales Reports ====================

    async getSalesReport(startDate: Date, endDate: Date, groupBy: string = 'day'): Promise<any> {
        const stats = await this.getAggregatedStats(startDate, endDate);
        const chart = await this.getRevenueChart(startDate, endDate, groupBy);

        return {
            summary: stats,
            chart,
            period: { startDate, endDate },
        };
    }

    async getPaymentMethodsBreakdown(startDate: Date, endDate: Date): Promise<any[]> {
        const result = await this.dailyStatsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            { $project: { methods: { $objectToArray: '$paymentMethods' } } },
            { $unwind: '$methods' },
            {
                $group: {
                    _id: '$methods.k',
                    count: { $sum: '$methods.v.count' },
                    amount: { $sum: '$methods.v.amount' },
                },
            },
            { $sort: { amount: -1 } },
        ]);

        const total = result.reduce((acc, r) => acc + r.amount, 0);
        return result.map(r => ({ ...r, percentage: ((r.amount / total) * 100).toFixed(1) }));
    }

    // ==================== Customer Reports ====================

    async getCustomerReport(startDate: Date, endDate: Date): Promise<any> {
        const result = await this.dailyStatsModel.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate } } },
            {
                $group: {
                    _id: null,
                    newCustomers: { $sum: '$customers.newCustomers' },
                    returningCustomers: { $sum: '$customers.returningCustomers' },
                    guestCheckouts: { $sum: '$customers.guestCheckouts' },
                },
            },
        ]);

        return result[0] || { newCustomers: 0, returningCustomers: 0, guestCheckouts: 0 };
    }

    // ==================== Report Generation ====================

    async createReport(data: Partial<Report>, createdBy: string): Promise<ReportDocument> {
        return this.reportModel.create({
            ...data,
            createdBy: new Types.ObjectId(createdBy),
        });
    }

    async getReports(userId: string, type?: ReportType): Promise<Report[]> {
        const query: any = { createdBy: new Types.ObjectId(userId) };
        if (type) query.type = type;
        return this.reportModel.find(query).sort({ createdAt: -1 }).limit(50).exec();
    }

    async getReportById(id: string): Promise<Report | null> {
        return this.reportModel.findById(id).exec();
    }

    async updateReportStatus(id: string, status: ReportStatus, data?: Partial<Report>): Promise<Report | null> {
        return this.reportModel.findByIdAndUpdate(
            id,
            { status, ...data },
            { new: true }
        );
    }

    async generateReport(reportId: string): Promise<void> {
        const report = await this.reportModel.findById(reportId);
        if (!report) return;

        await this.updateReportStatus(reportId, ReportStatus.PROCESSING, { startedAt: new Date() });

        try {
            let data: any;

            switch (report.type) {
                case ReportType.SALES:
                    data = await this.getSalesReport(report.startDate, report.endDate, report.groupBy);
                    break;
                case ReportType.CUSTOMERS:
                    data = await this.getCustomerReport(report.startDate, report.endDate);
                    break;
                case ReportType.PRODUCTS:
                    data = await this.getTopProducts(report.startDate, report.endDate, 100);
                    break;
                default:
                    data = {};
            }

            // TODO: Generate actual file (Excel/PDF/CSV)
            // For now, just save summary
            await this.updateReportStatus(reportId, ReportStatus.COMPLETED, {
                completedAt: new Date(),
                summary: data.summary || data,
                rowCount: Array.isArray(data) ? data.length : 1,
            });
        } catch (error) {
            await this.updateReportStatus(reportId, ReportStatus.FAILED, {
                error: error.message,
                completedAt: new Date(),
            });
        }
    }

    // ==================== Daily Stats Recording ====================

    async recordDailySales(data: {
        orderId: string;
        status: string;
        grossAmount: number;
        discount: number;
        shipping: number;
        tax: number;
        netAmount: number;
        itemCount: number;
        paymentMethod: string;
        city?: string;
        isNewCustomer: boolean;
        isGuest: boolean;
    }): Promise<void> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const update: any = {
            $inc: {
                'sales.totalOrders': 1,
                'sales.grossRevenue': data.grossAmount,
                'sales.discounts': data.discount,
                'sales.shipping': data.shipping,
                'sales.tax': data.tax,
                'sales.netRevenue': data.netAmount,
                'sales.itemsSold': data.itemCount,
            },
        };

        if (data.status === 'completed') {
            update.$inc['sales.completedOrders'] = 1;
        }

        if (data.isNewCustomer) {
            update.$inc['customers.newCustomers'] = 1;
        } else if (!data.isGuest) {
            update.$inc['customers.returningCustomers'] = 1;
        }

        if (data.isGuest) {
            update.$inc['customers.guestCheckouts'] = 1;
        }

        // Payment method tracking
        update.$inc[`paymentMethods.${data.paymentMethod}.count`] = 1;
        update.$inc[`paymentMethods.${data.paymentMethod}.amount`] = data.netAmount;

        // City tracking
        if (data.city) {
            update.$inc[`ordersByCity.${data.city}`] = 1;
        }

        await this.dailyStatsModel.findOneAndUpdate(
            { date: today },
            update,
            { upsert: true }
        );
    }

    // ==================== Helpers ====================

    private getEmptyStats(): any {
        return {
            sales: { totalOrders: 0, completedOrders: 0, grossRevenue: 0, netRevenue: 0, averageOrderValue: 0 },
            customers: { newCustomers: 0, returningCustomers: 0, guestCheckouts: 0 },
            traffic: { pageViews: 0, uniqueVisitors: 0 },
            conversion: { conversionRate: 0, cartAbandonmentRate: 0 },
        };
    }

    private calculateChange(previous: number, current: number): number {
        if (previous === 0) return current > 0 ? 100 : 0;
        return Number((((current - previous) / previous) * 100).toFixed(1));
    }
}
