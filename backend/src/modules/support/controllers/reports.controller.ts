import {
    Controller,
    Get,
    Query,
    UseGuards,
    Res,
    StreamableFile,
} from '@nestjs/common';
import { Response } from 'express';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/response.builder';
import { SupportReportsService } from '../services/support-reports.service';
import { TicketsService } from '../tickets.service';
import { ChatService } from '../chat.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Reports Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Support Reports')
@Controller('support/reports')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ReportsController {
    constructor(
        private readonly reportsService: SupportReportsService,
        private readonly ticketsService: TicketsService,
        private readonly chatService: ChatService,
    ) { }

    // ═══════════════════════════════════════════════════════════════
    // Ticket Reports
    // ═══════════════════════════════════════════════════════════════

    @Get('tickets/overview')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get tickets overview report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    @ApiQuery({ name: 'groupBy', required: false, enum: ['day', 'week', 'month'] })
    async getTicketsOverview(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
        @Query('groupBy') groupBy: 'day' | 'week' | 'month' = 'day',
    ) {
        const report = await this.reportsService.getTicketsReport(
            new Date(startDate),
            new Date(endDate),
            groupBy,
        );
        return ResponseBuilder.success(report);
    }

    @Get('tickets/by-category')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get tickets by category report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getTicketsByCategory(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getTicketsByCategoryReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    @Get('tickets/agent-performance')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get agent performance report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getAgentPerformance(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getAgentPerformanceReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    @Get('tickets/sla-compliance')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get SLA compliance report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getSLACompliance(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getSLAComplianceReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    @Get('tickets/satisfaction')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get customer satisfaction report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getCustomerSatisfaction(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getCustomerSatisfactionReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    @Get('tickets/peak-hours')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get peak hours report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getPeakHours(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getPeakHoursReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    // ═══════════════════════════════════════════════════════════════
    // Chat Reports
    // ═══════════════════════════════════════════════════════════════

    @Get('chat/overview')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get chat sessions overview report' })
    @ApiQuery({ name: 'startDate', required: true, type: String })
    @ApiQuery({ name: 'endDate', required: true, type: String })
    async getChatOverview(
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        const report = await this.reportsService.getChatSessionsReport(
            new Date(startDate),
            new Date(endDate),
        );
        return ResponseBuilder.success(report);
    }

    // ═══════════════════════════════════════════════════════════════
    // Export Endpoints
    // ═══════════════════════════════════════════════════════════════

    @Get('tickets/export/excel')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Export tickets to Excel' })
    @ApiQuery({ name: 'startDate', required: false, type: String })
    @ApiQuery({ name: 'endDate', required: false, type: String })
    @ApiQuery({ name: 'status', required: false, type: String })
    async exportTicketsExcel(
        @Query('startDate') startDate?: string,
        @Query('endDate') endDate?: string,
        @Query('status') status?: string,
        @Res({ passthrough: true }) res?: Response,
    ) {
        const filters: any = {};
        if (startDate) filters.fromDate = new Date(startDate);
        if (endDate) filters.toDate = new Date(endDate);
        if (status) filters.status = status;

        const { tickets } = await this.ticketsService.findTickets(filters);
        const buffer = await this.reportsService.exportTicketsToExcel(tickets);

        if (res) {
            res.set({
                'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition': `attachment; filename=tickets-${Date.now()}.xlsx`,
            });
        }

        return new StreamableFile(buffer);
    }

    @Get('tickets/export/pdf')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Export tickets to PDF' })
    @ApiQuery({ name: 'startDate', required: false, type: String })
    @ApiQuery({ name: 'endDate', required: false, type: String })
    @ApiQuery({ name: 'status', required: false, type: String })
    async exportTicketsPDF(
        @Query('startDate') startDate?: string,
        @Query('endDate') endDate?: string,
        @Query('status') status?: string,
        @Res({ passthrough: true }) res?: Response,
    ) {
        const filters: any = {};
        if (startDate) filters.fromDate = new Date(startDate);
        if (endDate) filters.toDate = new Date(endDate);
        if (status) filters.status = status;

        const { tickets } = await this.ticketsService.findTickets(filters);
        const buffer = await this.reportsService.exportTicketsToPDF(tickets);

        if (res) {
            res.set({
                'Content-Type': 'application/pdf',
                'Content-Disposition': `attachment; filename=tickets-${Date.now()}.pdf`,
            });
        }

        return new StreamableFile(buffer);
    }
}
