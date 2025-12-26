import {
    Controller,
    Get,
    Post,
    Body,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ReportType } from './schemas/report.schema';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '@/common/enums/user-role.enum';

@ApiTags('Analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class AnalyticsController {
    constructor(private readonly analyticsService: AnalyticsService) { }

    // ==================== Dashboard ====================

    @Get('dashboard')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get dashboard statistics' })
    async getDashboard() {
        const stats = await this.analyticsService.getDashboardStats();
        return ResponseBuilder.success(stats);
    }

    @Get('revenue-chart')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get revenue chart data' })
    async getRevenueChart(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
        @Query('groupBy') groupBy: string = 'day'
    ) {
        const data = await this.analyticsService.getRevenueChart(
            new Date(startDate),
            new Date(endDate),
            groupBy
        );
        return ResponseBuilder.success(data);
    }

    @Get('orders-chart')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get orders chart data' })
    async getOrdersChart(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string
    ) {
        const data = await this.analyticsService.getOrdersChart(
            new Date(startDate),
            new Date(endDate)
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
        @Query('limit') limit: number = 10
    ) {
        const data = await this.analyticsService.getTopProducts(
            new Date(startDate),
            new Date(endDate),
            limit
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
        @Query('limit') limit: number = 20
    ) {
        const data = await this.analyticsService.getTopSearches(
            new Date(startDate),
            new Date(endDate),
            limit
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
        @Query('groupBy') groupBy: string = 'day'
    ) {
        const data = await this.analyticsService.getSalesReport(
            new Date(startDate),
            new Date(endDate),
            groupBy
        );
        return ResponseBuilder.success(data);
    }

    @Get('payment-methods-breakdown')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get payment methods breakdown' })
    async getPaymentMethodsBreakdown(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string
    ) {
        const data = await this.analyticsService.getPaymentMethodsBreakdown(
            new Date(startDate),
            new Date(endDate)
        );
        return ResponseBuilder.success(data);
    }

    // ==================== Customer Report ====================

    @Get('customer-report')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get customer report' })
    async getCustomerReport(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string
    ) {
        const data = await this.analyticsService.getCustomerReport(
            new Date(startDate),
            new Date(endDate)
        );
        return ResponseBuilder.success(data);
    }

    // ==================== Reports ====================

    @Get('reports')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get my reports' })
    async getReports(
        @CurrentUser() user: any,
        @Query('type') type?: ReportType
    ) {
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
}
