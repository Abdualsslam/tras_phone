import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Ticket, TicketDocument, TicketStatus } from '../schemas/ticket.schema';
import { TicketMessage, TicketMessageDocument } from '../schemas/ticket-message.schema';
import { ChatSession, ChatSessionDocument } from '../schemas/chat-session.schema';
import * as ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Support Reports Service - خدمة التقارير
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SupportReportsService {
    constructor(
        @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
        @InjectModel(TicketMessage.name) private messageModel: Model<TicketMessageDocument>,
        @InjectModel(ChatSession.name) private sessionModel: Model<ChatSessionDocument>,
    ) { }

    // ═══════════════════════════════════════════════════════════════
    // Ticket Reports
    // ═══════════════════════════════════════════════════════════════

    /**
     * Get tickets report by date range
     */
    async getTicketsReport(startDate: Date, endDate: Date, groupBy: 'day' | 'week' | 'month' = 'day') {
        const tickets = await this.ticketModel.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate },
                    mergedInto: { $exists: false },
                },
            },
            {
                $group: {
                    _id: {
                        date: {
                            $dateToString: {
                                format: groupBy === 'day' ? '%Y-%m-%d' : groupBy === 'week' ? '%Y-W%V' : '%Y-%m',
                                date: '$createdAt',
                            },
                        },
                        status: '$status',
                    },
                    count: { $sum: 1 },
                },
            },
            { $sort: { '_id.date': 1 } },
        ]);

        return this.formatTimeSeriesData(tickets);
    }

    /**
     * Get tickets by category report
     */
    async getTicketsByCategoryReport(startDate: Date, endDate: Date) {
        return this.ticketModel.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate },
                    mergedInto: { $exists: false },
                },
            },
            {
                $lookup: {
                    from: 'ticketcategories',
                    localField: 'category',
                    foreignField: '_id',
                    as: 'categoryInfo',
                },
            },
            { $unwind: '$categoryInfo' },
            {
                $group: {
                    _id: '$category',
                    categoryName: { $first: '$categoryInfo.nameEn' },
                    categoryNameAr: { $first: '$categoryInfo.nameAr' },
                    totalTickets: { $sum: 1 },
                    openTickets: {
                        $sum: {
                            $cond: [
                                { $in: ['$status', [TicketStatus.OPEN, TicketStatus.IN_PROGRESS]] },
                                1,
                                0,
                            ],
                        },
                    },
                    resolvedTickets: {
                        $sum: {
                            $cond: [{ $eq: ['$status', TicketStatus.RESOLVED] }, 1, 0],
                        },
                    },
                    avgResolutionTime: {
                        $avg: {
                            $cond: [
                                { $ne: ['$resolution.resolvedAt', null] },
                                {
                                    $subtract: ['$resolution.resolvedAt', '$createdAt'],
                                },
                                null,
                            ],
                        },
                    },
                },
            },
            { $sort: { totalTickets: -1 } },
        ]);
    }

    /**
     * Get agent performance report
     */
    async getAgentPerformanceReport(startDate: Date, endDate: Date) {
        return this.ticketModel.aggregate([
            {
                $match: {
                    assignedTo: { $exists: true },
                    createdAt: { $gte: startDate, $lte: endDate },
                    mergedInto: { $exists: false },
                },
            },
            {
                $lookup: {
                    from: 'admins',
                    localField: 'assignedTo',
                    foreignField: '_id',
                    as: 'agentInfo',
                },
            },
            { $unwind: '$agentInfo' },
            {
                $group: {
                    _id: '$assignedTo',
                    agentName: { $first: '$agentInfo.name' },
                    totalAssigned: { $sum: 1 },
                    resolved: {
                        $sum: {
                            $cond: [
                                { $in: ['$status', [TicketStatus.RESOLVED, TicketStatus.CLOSED]] },
                                1,
                                0,
                            ],
                        },
                    },
                    avgFirstResponseTime: {
                        $avg: {
                            $cond: [
                                { $ne: ['$sla.firstRespondedAt', null] },
                                {
                                    $subtract: ['$sla.firstRespondedAt', '$createdAt'],
                                },
                                null,
                            ],
                        },
                    },
                    avgResolutionTime: {
                        $avg: {
                            $cond: [
                                { $ne: ['$resolution.resolvedAt', null] },
                                {
                                    $subtract: ['$resolution.resolvedAt', '$createdAt'],
                                },
                                null,
                            ],
                        },
                    },
                    avgRating: {
                        $avg: {
                            $cond: [
                                { $ne: ['$satisfactionRating', null] },
                                '$satisfactionRating',
                                null,
                            ],
                        },
                    },
                    slaBreaches: {
                        $sum: {
                            $cond: [
                                {
                                    $or: [
                                        { $eq: ['$sla.firstResponseBreached', true] },
                                        { $eq: ['$sla.resolutionBreached', true] },
                                    ],
                                },
                                1,
                                0,
                            ],
                        },
                    },
                },
            },
            {
                $project: {
                    agentName: 1,
                    totalAssigned: 1,
                    resolved: 1,
                    resolutionRate: {
                        $multiply: [
                            { $divide: ['$resolved', '$totalAssigned'] },
                            100,
                        ],
                    },
                    avgFirstResponseTimeMinutes: {
                        $divide: ['$avgFirstResponseTime', 60000],
                    },
                    avgResolutionTimeMinutes: {
                        $divide: ['$avgResolutionTime', 60000],
                    },
                    avgRating: { $round: ['$avgRating', 1] },
                    slaBreaches: 1,
                },
            },
            { $sort: { totalAssigned: -1 } },
        ]);
    }

    /**
     * Get SLA compliance report
     */
    async getSLAComplianceReport(startDate: Date, endDate: Date) {
        const [firstResponseCompliance, resolutionCompliance] = await Promise.all([
            this.ticketModel.aggregate([
                {
                    $match: {
                        createdAt: { $gte: startDate, $lte: endDate },
                        'sla.firstRespondedAt': { $exists: true },
                    },
                },
                {
                    $group: {
                        _id: null,
                        total: { $sum: 1 },
                        breached: {
                            $sum: {
                                $cond: ['$sla.firstResponseBreached', 1, 0],
                            },
                        },
                        avgResponseTime: {
                            $avg: {
                                $subtract: ['$sla.firstRespondedAt', '$createdAt'],
                            },
                        },
                    },
                },
            ]),
            this.ticketModel.aggregate([
                {
                    $match: {
                        createdAt: { $gte: startDate, $lte: endDate },
                        'resolution.resolvedAt': { $exists: true },
                    },
                },
                {
                    $group: {
                        _id: null,
                        total: { $sum: 1 },
                        breached: {
                            $sum: {
                                $cond: ['$sla.resolutionBreached', 1, 0],
                            },
                        },
                        avgResolutionTime: {
                            $avg: {
                                $subtract: ['$resolution.resolvedAt', '$createdAt'],
                            },
                        },
                    },
                },
            ]),
        ]);

        return {
            firstResponse: {
                total: firstResponseCompliance[0]?.total || 0,
                breached: firstResponseCompliance[0]?.breached || 0,
                complianceRate: firstResponseCompliance[0]
                    ? ((firstResponseCompliance[0].total - firstResponseCompliance[0].breached) /
                          firstResponseCompliance[0].total) *
                      100
                    : 0,
                avgResponseTimeMinutes: firstResponseCompliance[0]
                    ? Math.round(firstResponseCompliance[0].avgResponseTime / 60000)
                    : 0,
            },
            resolution: {
                total: resolutionCompliance[0]?.total || 0,
                breached: resolutionCompliance[0]?.breached || 0,
                complianceRate: resolutionCompliance[0]
                    ? ((resolutionCompliance[0].total - resolutionCompliance[0].breached) /
                          resolutionCompliance[0].total) *
                      100
                    : 0,
                avgResolutionTimeMinutes: resolutionCompliance[0]
                    ? Math.round(resolutionCompliance[0].avgResolutionTime / 60000)
                    : 0,
            },
        };
    }

    /**
     * Get customer satisfaction report
     */
    async getCustomerSatisfactionReport(startDate: Date, endDate: Date) {
        return this.ticketModel.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate },
                    satisfactionRating: { $exists: true },
                },
            },
            {
                $group: {
                    _id: '$satisfactionRating',
                    count: { $sum: 1 },
                },
            },
            { $sort: { _id: -1 } },
        ]);
    }

    /**
     * Get peak hours report
     */
    async getPeakHoursReport(startDate: Date, endDate: Date) {
        return this.ticketModel.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate },
                },
            },
            {
                $group: {
                    _id: { $hour: '$createdAt' },
                    count: { $sum: 1 },
                },
            },
            { $sort: { _id: 1 } },
        ]);
    }

    // ═══════════════════════════════════════════════════════════════
    // Chat Reports
    // ═══════════════════════════════════════════════════════════════

    /**
     * Get chat sessions report
     */
    async getChatSessionsReport(startDate: Date, endDate: Date) {
        return this.sessionModel.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate },
                },
            },
            {
                $group: {
                    _id: {
                        $dateToString: {
                            format: '%Y-%m-%d',
                            date: '$createdAt',
                        },
                    },
                    totalSessions: { $sum: 1 },
                    avgWaitTime: { $avg: '$metrics.waitTime' },
                    avgDuration: { $avg: '$metrics.chatDuration' },
                    avgRating: { $avg: '$rating' },
                },
            },
            { $sort: { _id: 1 } },
        ]);
    }

    // ═══════════════════════════════════════════════════════════════
    // Export Functions
    // ═══════════════════════════════════════════════════════════════

    /**
     * Export tickets to Excel
     */
    async exportTicketsToExcel(tickets: Ticket[]): Promise<Buffer> {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Support Tickets');

        // Add headers
        worksheet.columns = [
            { header: 'Ticket Number', key: 'ticketNumber', width: 20 },
            { header: 'Customer', key: 'customerName', width: 25 },
            { header: 'Email', key: 'customerEmail', width: 30 },
            { header: 'Subject', key: 'subject', width: 40 },
            { header: 'Status', key: 'status', width: 15 },
            { header: 'Priority', key: 'priority', width: 12 },
            { header: 'Category', key: 'category', width: 20 },
            { header: 'Assigned To', key: 'assignedTo', width: 20 },
            { header: 'Created At', key: 'createdAt', width: 20 },
            { header: 'Rating', key: 'rating', width: 10 },
        ];

        // Style header row
        worksheet.getRow(1).font = { bold: true };
        worksheet.getRow(1).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FF4472C4' },
        };

        // Add data
        tickets.forEach((ticket: any) => {
            worksheet.addRow({
                ticketNumber: ticket.ticketNumber,
                customerName: ticket.customer?.name || '',
                customerEmail: ticket.customer?.email || '',
                subject: ticket.subject,
                status: ticket.status,
                priority: ticket.priority,
                category: ticket.category?.nameEn || '',
                assignedTo: ticket.assignedTo?.name || 'Unassigned',
                createdAt: ticket.createdAt?.toISOString().split('T')[0] || '',
                rating: ticket.satisfactionRating || '',
            });
        });

        // Generate buffer
        const buffer = await workbook.xlsx.writeBuffer();
        return Buffer.from(buffer);
    }

    /**
     * Export tickets to PDF
     */
    async exportTicketsToPDF(tickets: Ticket[]): Promise<Buffer> {
        return new Promise((resolve, reject) => {
            const doc = new PDFDocument({ margin: 50 });
            const chunks: Buffer[] = [];

            doc.on('data', (chunk) => chunks.push(chunk));
            doc.on('end', () => resolve(Buffer.concat(chunks)));
            doc.on('error', reject);

            // Title
            doc.fontSize(20).text('Support Tickets Report', { align: 'center' });
            doc.moveDown();
            doc.fontSize(10).text(`Generated: ${new Date().toLocaleString()}`, { align: 'center' });
            doc.moveDown(2);

            // Table headers
            const tableTop = doc.y;
            doc.fontSize(10).font('Helvetica-Bold');
            doc.text('Ticket #', 50, tableTop, { width: 80 });
            doc.text('Customer', 130, tableTop, { width: 100 });
            doc.text('Subject', 230, tableTop, { width: 150 });
            doc.text('Status', 380, tableTop, { width: 80 });
            doc.text('Priority', 460, tableTop, { width: 60 });

            doc.moveDown();
            doc.font('Helvetica');

            // Table rows
            tickets.forEach((ticket: any, index) => {
                const y = doc.y;

                if (y > 700) {
                    doc.addPage();
                }

                doc.fontSize(9);
                doc.text(ticket.ticketNumber || '', 50, doc.y, { width: 80 });
                doc.text(ticket.customer?.name || '', 130, y, { width: 100 });
                doc.text(ticket.subject || '', 230, y, { width: 150 });
                doc.text(ticket.status || '', 380, y, { width: 80 });
                doc.text(ticket.priority || '', 460, y, { width: 60 });

                doc.moveDown();
            });

            doc.end();
        });
    }

    /**
     * Export chat sessions to Excel
     */
    async exportChatSessionsToExcel(sessions: ChatSession[]): Promise<Buffer> {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Chat Sessions');

        // Add headers
        worksheet.columns = [
            { header: 'Session ID', key: 'sessionId', width: 20 },
            { header: 'Customer', key: 'customerName', width: 25 },
            { header: 'Email', key: 'customerEmail', width: 30 },
            { header: 'Status', key: 'status', width: 15 },
            { header: 'Agent', key: 'agent', width: 20 },
            { header: 'Wait Time (sec)', key: 'waitTime', width: 15 },
            { header: 'Duration (sec)', key: 'duration', width: 15 },
            { header: 'Messages', key: 'messageCount', width: 12 },
            { header: 'Rating', key: 'rating', width: 10 },
            { header: 'Created At', key: 'createdAt', width: 20 },
        ];

        // Style header row
        worksheet.getRow(1).font = { bold: true };
        worksheet.getRow(1).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FF4472C4' },
        };

        // Add data
        sessions.forEach((session: any) => {
            worksheet.addRow({
                sessionId: session.sessionId,
                customerName: session.visitor?.name || '',
                customerEmail: session.visitor?.email || '',
                status: session.status,
                agent: session.assignedAgent?.name || 'Unassigned',
                waitTime: session.metrics?.waitTime || 0,
                duration: session.metrics?.chatDuration || 0,
                messageCount: session.metrics?.messageCount || 0,
                rating: session.rating || '',
                createdAt: session.createdAt?.toISOString().split('T')[0] || '',
            });
        });

        // Generate buffer
        const buffer = await workbook.xlsx.writeBuffer();
        return Buffer.from(buffer);
    }

    // ═══════════════════════════════════════════════════════════════
    // Helper Methods
    // ═══════════════════════════════════════════════════════════════

    private formatTimeSeriesData(data: any[]) {
        const result: Record<string, any> = {};

        data.forEach((item) => {
            const date = item._id.date;
            const status = item._id.status;

            if (!result[date]) {
                result[date] = { date, total: 0 };
            }

            result[date][status] = item.count;
            result[date].total += item.count;
        });

        return Object.values(result);
    }
}
