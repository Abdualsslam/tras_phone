import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';
import { DashboardService } from './dashboard.service';
import { SearchService } from './search.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { ReportType } from './schemas/report.schema';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '../../common/enums/user-role.enum';

@ApiTags('Analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class AnalyticsController {
  constructor(
    private readonly analyticsService: AnalyticsService,
    private readonly dashboardService: DashboardService,
    private readonly searchService: SearchService,
  ) {}

  // ==================== Dashboard ====================

  @Get('dashboard')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get dashboard statistics' })
  async getDashboard() {
    const stats = await this.dashboardService.getDashboardStats();
    return ResponseBuilder.success(stats);
  }

  @Get('dashboard/overview')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get dashboard overview' })
  async getDashboardOverview() {
    const stats = await this.dashboardService.getOverviewStats();
    return ResponseBuilder.success(stats);
  }

  @Get('dashboard/top-customers')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get top customers' })
  async getTopCustomers(@Query('limit') limit: number = 10) {
    const customers = await this.dashboardService.getTopCustomers(limit);
    return ResponseBuilder.success(customers);
  }

  @Get('dashboard/low-stock')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get low stock products' })
  async getLowStock(@Query('limit') limit: number = 10) {
    const products = await this.dashboardService.getLowStockProducts(limit);
    return ResponseBuilder.success(products);
  }

  @Get('dashboard/recent-orders')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get recent orders' })
  async getRecentOrders(@Query('limit') limit: number = 10) {
    const orders = await this.dashboardService.getRecentOrders(limit);
    return ResponseBuilder.success(orders);
  }

  @Get('dashboard/pending-actions')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get pending actions count' })
  async getPendingActions() {
    const actions = await this.dashboardService.getPendingActions();
    return ResponseBuilder.success(actions);
  }

  @Get('dashboard/sales-chart')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get sales chart data' })
  async getSalesChart(@Query('days') days: number = 7) {
    const chart = await this.dashboardService.getSalesChart(days);
    return ResponseBuilder.success(chart);
  }

  @Get('dashboard/orders-chart')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get orders by status chart' })
  async getOrdersStatusChart() {
    const chart = await this.dashboardService.getOrdersChart();
    return ResponseBuilder.success(chart);
  }

  @Get('revenue-chart')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get revenue chart data' })
  async getRevenueChart(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('groupBy') groupBy: string = 'day',
  ) {
    const data = await this.analyticsService.getRevenueChart(
      new Date(startDate),
      new Date(endDate),
      groupBy,
    );
    return ResponseBuilder.success(data);
  }

  @Get('orders-chart')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get orders chart data' })
  async getOrdersChart(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const data = await this.analyticsService.getOrdersChart(
      new Date(startDate),
      new Date(endDate),
    );
    return ResponseBuilder.success(data);
  }

  // ==================== Products ====================

  @Get('products/top')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get top performing products' })
  async getTopProducts(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('limit') limit: number = 10,
  ) {
    const data = await this.analyticsService.getTopProducts(
      new Date(startDate),
      new Date(endDate),
      limit,
    );
    return ResponseBuilder.success(data);
  }

  @Get('products/low-performing')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get low performing products' })
  async getLowPerformingProducts(@Query('limit') limit: number = 10) {
    const data = await this.analyticsService.getLowPerformingProducts(limit);
    return ResponseBuilder.success(data);
  }

  // ==================== Search ====================

  @Get('search/top')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get top search queries' })
  async getTopSearches(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('limit') limit: number = 20,
  ) {
    const data = await this.analyticsService.getTopSearches(
      new Date(startDate),
      new Date(endDate),
      limit,
    );
    return ResponseBuilder.success(data);
  }

  @Get('search/no-results')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get searches with no results' })
  async getNoResultSearches(@Query('limit') limit: number = 20) {
    const data = await this.analyticsService.getNoResultSearches(limit);
    return ResponseBuilder.success(data);
  }

  // ==================== Sales Report ====================

  @Get('sales-report')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get sales report' })
  async getSalesReport(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('groupBy') groupBy: string = 'day',
  ) {
    const data = await this.analyticsService.getSalesReport(
      new Date(startDate),
      new Date(endDate),
      groupBy,
    );
    return ResponseBuilder.success(data);
  }

  @Get('payment-methods-breakdown')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get payment methods breakdown' })
  async getPaymentMethodsBreakdown(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const data = await this.analyticsService.getPaymentMethodsBreakdown(
      new Date(startDate),
      new Date(endDate),
    );
    return ResponseBuilder.success(data);
  }

  // ==================== Customer Report ====================

  @Get('customer-report')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get customer report' })
  async getCustomerReport(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const data = await this.analyticsService.getCustomerReport(
      new Date(startDate),
      new Date(endDate),
    );
    return ResponseBuilder.success(data);
  }

  // ==================== Reports ====================

  @Get('reports')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get my reports' })
  async getReports(@CurrentUser() user: any, @Query('type') type?: ReportType) {
    const reports = await this.analyticsService.getReports(user.adminId, type);
    return ResponseBuilder.success(reports);
  }

  @Get('reports/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get report by ID' })
  async getReport(@Param('id') id: string) {
    const report = await this.analyticsService.getReportById(id);
    return ResponseBuilder.success(report);
  }

  @Post('reports')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create a new report' })
  async createReport(@CurrentUser() user: any, @Body() data: any) {
    const report = await this.analyticsService.createReport(data, user.adminId);

    // Start generation in background
    this.analyticsService.generateReport(report._id.toString());

    return ResponseBuilder.success(report, 'Report generation started');
  }

  // ==================== Tracking (Internal) ====================

  @Post('track/product-view')
  @ApiOperation({ summary: 'Track product view' })
  async trackProductView(@Body() data: { productId: string }) {
    await this.analyticsService.trackProductView(data.productId);
    return ResponseBuilder.success(null);
  }

  @Post('track/add-to-cart')
  @ApiOperation({ summary: 'Track add to cart' })
  async trackAddToCart(@Body() data: { productId: string }) {
    await this.analyticsService.trackAddToCart(data.productId);
    return ResponseBuilder.success(null);
  }

  @Post('track/search')
  @ApiOperation({ summary: 'Track search' })
  async trackSearch(@Body() data: { query: string; resultsCount: number }) {
    await this.analyticsService.trackSearch(data.query, data.resultsCount);
    return ResponseBuilder.success(null);
  }

  // ==================== Search Analytics ====================

  @Post('search/log')
  @Public()
  @ApiOperation({ summary: 'Log search query' })
  async logSearch(@Body() data: any) {
    const log = await this.searchService.logSearch(data);
    return ResponseBuilder.success({ searchId: log._id });
  }

  @Post('search/:id/click')
  @Public()
  @ApiOperation({ summary: 'Log search click' })
  async logSearchClick(
    @Param('id') id: string,
    @Body() data: { productId: string },
  ) {
    await this.searchService.logSearchClick(id, data.productId);
    return ResponseBuilder.success(null);
  }

  @Get('search/popular')
  @Public()
  @ApiOperation({ summary: 'Get popular searches' })
  async getPopularSearches(@Query('limit') limit: number = 20) {
    const searches = await this.searchService.getPopularSearches(limit);
    return ResponseBuilder.success(searches);
  }

  @Get('search/trending')
  @Public()
  @ApiOperation({ summary: 'Get trending searches' })
  async getTrendingSearches(@Query('limit') limit: number = 10) {
    const searches = await this.searchService.getTrendingSearches(limit);
    return ResponseBuilder.success(searches);
  }

  @Get('search/analytics')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get search analytics' })
  async getSearchAnalytics(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const analytics = await this.searchService.getSearchAnalytics(
      new Date(startDate),
      new Date(endDate),
    );
    return ResponseBuilder.success(analytics);
  }

  // ==================== Recently Viewed ====================

  @Post('recently-viewed/:productId')
  @ApiOperation({ summary: 'Track product view' })
  async trackRecentlyViewed(
    @CurrentUser() user: any,
    @Param('productId') productId: string,
  ) {
    if (user.customerId) {
      await this.searchService.trackProductView(user.customerId, productId);
    }
    return ResponseBuilder.success(null);
  }

  @Get('recently-viewed')
  @ApiOperation({ summary: 'Get recently viewed products' })
  async getRecentlyViewed(
    @CurrentUser() user: any,
    @Query('limit') limit: number = 20,
  ) {
    const products = await this.searchService.getRecentlyViewed(
      user.customerId,
      limit,
    );
    return ResponseBuilder.success(products);
  }

  @Delete('recently-viewed')
  @ApiOperation({ summary: 'Clear recently viewed products' })
  async clearRecentlyViewed(@CurrentUser() user: any) {
    await this.searchService.clearRecentlyViewed(user.customerId);
    return ResponseBuilder.success(null, 'Recently viewed cleared');
  }
}
