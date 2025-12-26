import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Ticket, TicketDocument, TicketStatus, TicketPriority } from './schemas/ticket.schema';
import { TicketMessage, TicketMessageDocument, MessageSenderType, MessageType } from './schemas/ticket-message.schema';
import { TicketCategory, TicketCategoryDocument } from './schemas/ticket-category.schema';
import { CannedResponse, CannedResponseDocument } from './schemas/canned-response.schema';

@Injectable()
export class TicketsService {
    constructor(
        @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
        @InjectModel(TicketMessage.name) private messageModel: Model<TicketMessageDocument>,
        @InjectModel(TicketCategory.name) private categoryModel: Model<TicketCategoryDocument>,
        @InjectModel(CannedResponse.name) private cannedResponseModel: Model<CannedResponseDocument>,
    ) { }

    // ==================== Categories ====================

    async createCategory(data: Partial<TicketCategory>): Promise<TicketCategory> {
        return this.categoryModel.create(data);
    }

    async findAllCategories(activeOnly: boolean = true): Promise<TicketCategory[]> {
        const query = activeOnly ? { isActive: true } : {};
        return this.categoryModel.find(query).sort({ sortOrder: 1 }).exec();
    }

    async updateCategory(id: string, data: Partial<TicketCategory>): Promise<TicketCategory> {
        const category = await this.categoryModel.findByIdAndUpdate(id, data, { new: true });
        if (!category) throw new NotFoundException('Category not found');
        return category;
    }

    // ==================== Tickets ====================

    async createTicket(data: {
        customer: { customerId?: string; name: string; email: string; phone?: string };
        categoryId: string;
        subject: string;
        description: string;
        source?: string;
        priority?: TicketPriority;
        orderId?: string;
        productId?: string;
        attachments?: string[];
    }): Promise<Ticket> {
        const category = await this.categoryModel.findById(data.categoryId);
        if (!category) throw new NotFoundException('Category not found');

        // Generate ticket number
        const ticketNumber = await this.generateTicketNumber();

        // Calculate SLA times
        const now = new Date();
        const firstResponseDue = new Date(now.getTime() + category.responseTimeHours * 60 * 60 * 1000);
        const resolutionDue = new Date(now.getTime() + category.resolutionTimeHours * 60 * 60 * 1000);

        const ticket = await this.ticketModel.create({
            ticketNumber,
            customer: {
                customerId: data.customer.customerId ? new Types.ObjectId(data.customer.customerId) : undefined,
                name: data.customer.name,
                email: data.customer.email,
                phone: data.customer.phone,
            },
            category: new Types.ObjectId(data.categoryId),
            subject: data.subject,
            description: data.description,
            source: data.source || 'web',
            priority: data.priority || category.defaultPriority,
            orderId: data.orderId ? new Types.ObjectId(data.orderId) : undefined,
            productId: data.productId ? new Types.ObjectId(data.productId) : undefined,
            attachments: data.attachments || [],
            sla: {
                firstResponseDue,
                resolutionDue,
            },
            assignedTo: category.defaultAssignee,
            assignedAt: category.defaultAssignee ? new Date() : undefined,
        });

        // Update category stats
        await this.categoryModel.findByIdAndUpdate(data.categoryId, {
            $inc: { totalTickets: 1, openTickets: 1 },
        });

        // Add initial message
        await this.addMessage(ticket._id.toString(), {
            senderType: MessageSenderType.CUSTOMER,
            senderId: data.customer.customerId,
            senderName: data.customer.name,
            content: data.description,
            attachments: data.attachments,
        });

        return ticket;
    }

    async findTicketById(id: string): Promise<Ticket> {
        const ticket = await this.ticketModel
            .findById(id)
            .populate('category', 'nameAr nameEn')
            .populate('assignedTo', 'name email')
            .populate('orderId', 'orderNumber')
            .exec();
        if (!ticket) throw new NotFoundException('Ticket not found');
        return ticket;
    }

    async findTicketByNumber(ticketNumber: string): Promise<Ticket> {
        const ticket = await this.ticketModel
            .findOne({ ticketNumber })
            .populate('category', 'nameAr nameEn')
            .populate('assignedTo', 'name email')
            .exec();
        if (!ticket) throw new NotFoundException('Ticket not found');
        return ticket;
    }

    async findTickets(filters: {
        status?: TicketStatus;
        priority?: TicketPriority;
        assignedTo?: string;
        categoryId?: string;
        customerId?: string;
        search?: string;
        fromDate?: Date;
        toDate?: Date;
        page?: number;
        limit?: number;
    }): Promise<{ tickets: Ticket[]; total: number }> {
        const query: any = { mergedInto: { $exists: false } };

        if (filters.status) query.status = filters.status;
        if (filters.priority) query.priority = filters.priority;
        if (filters.assignedTo) query.assignedTo = new Types.ObjectId(filters.assignedTo);
        if (filters.categoryId) query.category = new Types.ObjectId(filters.categoryId);
        if (filters.customerId) query['customer.customerId'] = new Types.ObjectId(filters.customerId);
        if (filters.search) {
            query.$or = [
                { ticketNumber: { $regex: filters.search, $options: 'i' } },
                { subject: { $regex: filters.search, $options: 'i' } },
                { 'customer.name': { $regex: filters.search, $options: 'i' } },
                { 'customer.email': { $regex: filters.search, $options: 'i' } },
            ];
        }
        if (filters.fromDate || filters.toDate) {
            query.createdAt = {};
            if (filters.fromDate) query.createdAt.$gte = filters.fromDate;
            if (filters.toDate) query.createdAt.$lte = filters.toDate;
        }

        const page = filters.page || 1;
        const limit = filters.limit || 20;

        const [tickets, total] = await Promise.all([
            this.ticketModel
                .find(query)
                .populate('category', 'nameAr nameEn')
                .populate('assignedTo', 'name')
                .sort({ createdAt: -1 })
                .skip((page - 1) * limit)
                .limit(limit)
                .exec(),
            this.ticketModel.countDocuments(query),
        ]);

        return { tickets, total };
    }

    async findCustomerTickets(customerId: string): Promise<Ticket[]> {
        return this.ticketModel
            .find({ 'customer.customerId': new Types.ObjectId(customerId), mergedInto: { $exists: false } })
            .populate('category', 'nameAr nameEn')
            .sort({ createdAt: -1 })
            .exec();
    }

    async updateTicketStatus(
        id: string,
        status: TicketStatus,
        agentId: string,
        resolution?: { summary: string; type: string }
    ): Promise<Ticket> {
        const ticket = await this.ticketModel.findById(id);
        if (!ticket) throw new NotFoundException('Ticket not found');

        const previousStatus = ticket.status;
        const updateData: any = { status };

        // Handle resolution
        if ([TicketStatus.RESOLVED, TicketStatus.CLOSED].includes(status) && resolution) {
            updateData.resolution = {
                ...resolution,
                resolvedBy: new Types.ObjectId(agentId),
                resolvedAt: new Date(),
            };
            updateData['sla.resolvedAt'] = new Date();

            // Check SLA breach
            if (ticket.sla?.resolutionDue && new Date() > ticket.sla.resolutionDue) {
                updateData['sla.resolutionBreached'] = true;
            }

            // Update category stats
            await this.categoryModel.findByIdAndUpdate(ticket.category, {
                $inc: { openTickets: -1 },
            });
        }

        // Handle reopening
        if (status === TicketStatus.REOPENED) {
            await this.categoryModel.findByIdAndUpdate(ticket.category, {
                $inc: { openTickets: 1 },
            });
        }

        const updatedTicket = await this.ticketModel.findByIdAndUpdate(id, updateData, { new: true });

        // Add status change message
        await this.addMessage(id, {
            senderType: MessageSenderType.SYSTEM,
            senderId: agentId,
            senderName: 'System',
            messageType: MessageType.STATUS_CHANGE,
            content: `Status changed from ${previousStatus} to ${status}`,
            isInternal: true,
        });

        return updatedTicket!;
    }

    async assignTicket(ticketId: string, agentId: string, assignedBy?: string): Promise<Ticket> {
        const ticket = await this.ticketModel.findById(ticketId);
        if (!ticket) throw new NotFoundException('Ticket not found');

        const previousAssignee = ticket.assignedTo;

        const updatedTicket = await this.ticketModel.findByIdAndUpdate(
            ticketId,
            {
                assignedTo: new Types.ObjectId(agentId),
                assignedAt: new Date(),
            },
            { new: true }
        ).populate('assignedTo', 'name');

        // Add assignment message
        await this.addMessage(ticketId, {
            senderType: MessageSenderType.SYSTEM,
            senderId: assignedBy || agentId,
            senderName: 'System',
            messageType: MessageType.ASSIGNMENT,
            content: `Ticket assigned to ${(updatedTicket?.assignedTo as any)?.name || 'agent'}`,
            isInternal: true,
        });

        return updatedTicket!;
    }

    async escalateTicket(ticketId: string, agentId: string, reason: string): Promise<Ticket> {
        const ticket = await this.ticketModel.findById(ticketId);
        if (!ticket) throw new NotFoundException('Ticket not found');

        const updatedTicket = await this.ticketModel.findByIdAndUpdate(
            ticketId,
            {
                status: TicketStatus.ESCALATED,
                escalationLevel: ticket.escalationLevel + 1,
                escalatedAt: new Date(),
                escalatedBy: new Types.ObjectId(agentId),
                escalationReason: reason,
            },
            { new: true }
        );

        // Add escalation message
        await this.addMessage(ticketId, {
            senderType: MessageSenderType.SYSTEM,
            senderId: agentId,
            senderName: 'System',
            messageType: MessageType.ESCALATION,
            content: `Ticket escalated: ${reason}`,
            isInternal: true,
        });

        return updatedTicket!;
    }

    async mergeTickets(primaryId: string, secondaryIds: string[], agentId: string): Promise<Ticket> {
        const primary = await this.ticketModel.findById(primaryId);
        if (!primary) throw new NotFoundException('Primary ticket not found');

        // Mark secondary tickets as merged
        await this.ticketModel.updateMany(
            { _id: { $in: secondaryIds.map(id => new Types.ObjectId(id)) } },
            { mergedInto: new Types.ObjectId(primaryId), status: TicketStatus.CLOSED }
        );

        // Update primary with merged references
        const updatedPrimary = await this.ticketModel.findByIdAndUpdate(
            primaryId,
            {
                $push: { mergedTickets: { $each: secondaryIds.map(id => new Types.ObjectId(id)) } },
            },
            { new: true }
        );

        // Copy messages from merged tickets
        for (const secId of secondaryIds) {
            const messages = await this.messageModel.find({ ticket: new Types.ObjectId(secId) });
            for (const msg of messages) {
                await this.messageModel.create({
                    ...msg.toObject(),
                    _id: undefined,
                    ticket: new Types.ObjectId(primaryId),
                    content: `[Merged from ticket] ${msg.content}`,
                });
            }
        }

        return updatedPrimary!;
    }

    async addSatisfactionRating(ticketId: string, rating: number, feedback?: string): Promise<Ticket> {
        const ticket = await this.ticketModel.findById(ticketId);
        if (!ticket) throw new NotFoundException('Ticket not found');

        if (![TicketStatus.RESOLVED, TicketStatus.CLOSED].includes(ticket.status)) {
            throw new BadRequestException('Can only rate resolved or closed tickets');
        }

        const updatedTicket = await this.ticketModel.findByIdAndUpdate(
            ticketId,
            {
                satisfactionRating: rating,
                satisfactionFeedback: feedback,
                satisfactionRatedAt: new Date(),
            },
            { new: true }
        );

        if (!updatedTicket) throw new NotFoundException('Ticket not found');

        return updatedTicket;
    }

    // ==================== Messages ====================

    async addMessage(ticketId: string, data: {
        senderType: MessageSenderType;
        senderId?: string;
        senderName: string;
        content: string;
        messageType?: MessageType;
        isInternal?: boolean;
        attachments?: string[];
    }): Promise<TicketMessage> {
        const ticket = await this.ticketModel.findById(ticketId);
        if (!ticket) throw new NotFoundException('Ticket not found');

        const message = await this.messageModel.create({
            ticket: new Types.ObjectId(ticketId),
            senderType: data.senderType,
            senderId: data.senderId ? new Types.ObjectId(data.senderId) : undefined,
            senderModel: data.senderType === MessageSenderType.CUSTOMER ? 'Customer' : 'Admin',
            senderName: data.senderName,
            messageType: data.messageType || MessageType.TEXT,
            content: data.content,
            isInternal: data.isInternal || false,
            attachments: data.attachments || [],
        });

        // Update ticket counters and activity
        const updateData: any = {};

        if (data.isInternal) {
            updateData.$inc = { internalNoteCount: 1 };
        } else {
            updateData.$inc = { messageCount: 1 };
        }

        if (data.senderType === MessageSenderType.CUSTOMER) {
            updateData.lastCustomerReplyAt = new Date();
            if (ticket.status === TicketStatus.AWAITING_RESPONSE) {
                updateData.status = TicketStatus.OPEN;
            }
        } else if (data.senderType === MessageSenderType.AGENT && !data.isInternal) {
            updateData.lastAgentReplyAt = new Date();

            // Track first response for SLA
            if (!ticket.sla?.firstRespondedAt) {
                updateData['sla.firstRespondedAt'] = new Date();
                if (ticket.sla?.firstResponseDue && new Date() > ticket.sla.firstResponseDue) {
                    updateData['sla.firstResponseBreached'] = true;
                }
            }

            // Update status to awaiting response
            if (ticket.status === TicketStatus.OPEN || ticket.status === TicketStatus.IN_PROGRESS) {
                updateData.status = TicketStatus.AWAITING_RESPONSE;
            }
        }

        await this.ticketModel.findByIdAndUpdate(ticketId, updateData);

        return message;
    }

    async getTicketMessages(ticketId: string, includeInternal: boolean = false): Promise<TicketMessage[]> {
        const query: any = { ticket: new Types.ObjectId(ticketId) };
        if (!includeInternal) {
            query.isInternal = { $ne: true };
        }
        return this.messageModel.find(query).sort({ createdAt: 1 }).exec();
    }

    // ==================== Canned Responses ====================

    async createCannedResponse(data: Partial<CannedResponse>, createdBy: string): Promise<CannedResponse> {
        return this.cannedResponseModel.create({
            ...data,
            createdBy: new Types.ObjectId(createdBy),
        });
    }

    async findCannedResponses(agentId: string, categoryId?: string): Promise<CannedResponse[]> {
        const query: any = {
            isActive: true,
            $or: [
                { isPersonal: false },
                { isPersonal: true, createdBy: new Types.ObjectId(agentId) },
            ],
        };
        if (categoryId) {
            query.$or.push({ category: new Types.ObjectId(categoryId) });
        }
        return this.cannedResponseModel.find(query).sort({ usageCount: -1 }).exec();
    }

    async useCannedResponse(responseId: string): Promise<CannedResponse> {
        const response = await this.cannedResponseModel.findByIdAndUpdate(
            responseId,
            { $inc: { usageCount: 1 }, lastUsedAt: new Date() },
            { new: true }
        );
        if (!response) throw new NotFoundException('Canned response not found');
        return response;
    }

    // ==================== Statistics ====================

    async getTicketStats(): Promise<any> {
        const [statusCounts, priorityCounts, avgResolutionTime, slaBreaches] = await Promise.all([
            this.ticketModel.aggregate([
                { $match: { mergedInto: { $exists: false } } },
                { $group: { _id: '$status', count: { $sum: 1 } } },
            ]),
            this.ticketModel.aggregate([
                { $match: { mergedInto: { $exists: false } } },
                { $group: { _id: '$priority', count: { $sum: 1 } } },
            ]),
            this.ticketModel.aggregate([
                { $match: { 'resolution.resolvedAt': { $exists: true } } },
                {
                    $project: {
                        resolutionTime: {
                            $subtract: ['$resolution.resolvedAt', '$createdAt'],
                        },
                    },
                },
                { $group: { _id: null, avgTime: { $avg: '$resolutionTime' } } },
            ]),
            this.ticketModel.countDocuments({
                $or: [
                    { 'sla.firstResponseBreached': true },
                    { 'sla.resolutionBreached': true },
                ],
            }),
        ]);

        return {
            byStatus: statusCounts.reduce((acc, s) => ({ ...acc, [s._id]: s.count }), {}),
            byPriority: priorityCounts.reduce((acc, p) => ({ ...acc, [p._id]: p.count }), {}),
            avgResolutionTimeMinutes: avgResolutionTime[0]?.avgTime ? Math.round(avgResolutionTime[0].avgTime / 60000) : 0,
            slaBreaches,
        };
    }

    async getAgentStats(agentId: string): Promise<any> {
        const [assigned, resolved, avgFirstResponse] = await Promise.all([
            this.ticketModel.countDocuments({
                assignedTo: new Types.ObjectId(agentId),
                status: { $nin: [TicketStatus.RESOLVED, TicketStatus.CLOSED] }
            }),
            this.ticketModel.countDocuments({
                'resolution.resolvedBy': new Types.ObjectId(agentId)
            }),
            this.ticketModel.aggregate([
                {
                    $match: {
                        assignedTo: new Types.ObjectId(agentId),
                        'sla.firstRespondedAt': { $exists: true }
                    }
                },
                {
                    $project: {
                        responseTime: {
                            $subtract: ['$sla.firstRespondedAt', '$createdAt'],
                        },
                    },
                },
                { $group: { _id: null, avgTime: { $avg: '$responseTime' } } },
            ]),
        ]);

        return {
            assignedTickets: assigned,
            resolvedTickets: resolved,
            avgFirstResponseMinutes: avgFirstResponse[0]?.avgTime ? Math.round(avgFirstResponse[0].avgTime / 60000) : 0,
        };
    }

    // ==================== Helpers ====================

    private async generateTicketNumber(): Promise<string> {
        const year = new Date().getFullYear();
        const count = await this.ticketModel.countDocuments({
            createdAt: { $gte: new Date(`${year}-01-01`) },
        });
        return `TKT-${year}-${String(count + 1).padStart(6, '0')}`;
    }

    // ==================== Seeding ====================

    async seedCategories(): Promise<void> {
        const existing = await this.categoryModel.countDocuments();
        if (existing > 0) return;

        const categories = [
            {
                nameAr: 'استفسارات عامة',
                nameEn: 'General Inquiries',
                icon: 'help-circle',
                responseTimeHours: 24,
                resolutionTimeHours: 48,
                defaultPriority: 'low',
                sortOrder: 1,
            },
            {
                nameAr: 'الطلبات والشحن',
                nameEn: 'Orders & Shipping',
                icon: 'package',
                responseTimeHours: 12,
                resolutionTimeHours: 48,
                defaultPriority: 'medium',
                requiresOrderId: true,
                sortOrder: 2,
            },
            {
                nameAr: 'المنتجات والضمان',
                nameEn: 'Products & Warranty',
                icon: 'shield',
                responseTimeHours: 24,
                resolutionTimeHours: 72,
                defaultPriority: 'medium',
                requiresProductId: true,
                sortOrder: 3,
            },
            {
                nameAr: 'المرتجعات والاستبدال',
                nameEn: 'Returns & Exchange',
                icon: 'refresh-cw',
                responseTimeHours: 12,
                resolutionTimeHours: 48,
                defaultPriority: 'high',
                requiresOrderId: true,
                sortOrder: 4,
            },
            {
                nameAr: 'المدفوعات والفواتير',
                nameEn: 'Payments & Billing',
                icon: 'credit-card',
                responseTimeHours: 6,
                resolutionTimeHours: 24,
                defaultPriority: 'high',
                sortOrder: 5,
            },
            {
                nameAr: 'الشكاوى',
                nameEn: 'Complaints',
                icon: 'alert-triangle',
                responseTimeHours: 4,
                resolutionTimeHours: 24,
                defaultPriority: 'urgent',
                sortOrder: 6,
            },
        ];

        await this.categoryModel.insertMany(categories);
    }
}
