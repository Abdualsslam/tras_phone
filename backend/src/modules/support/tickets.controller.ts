import {
    Controller,
    Get,
    Post,
    Put,
    Body,
    Param,
    Query,
    UseGuards,
    UseInterceptors,
    UploadedFiles,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FilesInterceptor } from '@nestjs/platform-express';
import { TicketsService } from './tickets.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { TicketStatus, TicketPriority } from './schemas/ticket.schema';
import { MessageSenderType } from './schemas/ticket-message.schema';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '@common/enums/user-role.enum';
import { UploadsService } from '../uploads/uploads.service';
import { AdvancedSearchDto } from './dto/advanced-search.dto';

@ApiTags('Tickets')
@Controller('tickets')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class TicketsController {
    constructor(
        private readonly ticketsService: TicketsService,
        private readonly uploadsService: UploadsService,
    ) { }

    // ==================== Categories ====================

    @Get('categories')
    @Public()
    @ApiOperation({ summary: 'Get all ticket categories' })
    async getCategories(@Query('activeOnly') activeOnly: string = 'true') {
        const categories = await this.ticketsService.findAllCategories(activeOnly === 'true');
        return ResponseBuilder.success(categories);
    }

    @Post('categories')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Create ticket category' })
    async createCategory(@Body() data: any) {
        const category = await this.ticketsService.createCategory(data);
        return ResponseBuilder.success(category, 'Category created successfully');
    }

    @Put('categories/:id')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Update ticket category' })
    async updateCategory(@Param('id') id: string, @Body() data: any) {
        const category = await this.ticketsService.updateCategory(id, data);
        return ResponseBuilder.success(category, 'Category updated successfully');
    }

    // ==================== Customer Tickets ====================

    @Get('my')
    @ApiOperation({ summary: 'Get my tickets' })
    async getMyTickets(@CurrentUser() user: any) {
        const tickets = await this.ticketsService.findCustomerTickets(user.customerId);
        return ResponseBuilder.success(tickets);
    }

    @Post()
    @ApiOperation({ summary: 'Create a new ticket' })
    async createTicket(@CurrentUser() user: any, @Body() data: any) {
        const ticket = await this.ticketsService.createTicket({
            customer: {
                customerId: user.customerId,
                name: user.name,
                email: user.email,
                phone: user.phone,
            },
            categoryId: data.categoryId,
            subject: data.subject,
            description: data.description,
            source: data.source || 'web',
            priority: data.priority,
            orderId: data.orderId,
            productId: data.productId,
            attachments: data.attachments,
        });
        return ResponseBuilder.success(ticket, 'Ticket created successfully');
    }

    @Get('my/:id')
    @ApiOperation({ summary: 'Get my ticket details' })
    async getMyTicketDetails(@CurrentUser() user: any, @Param('id') id: string) {
        const ticket = await this.ticketsService.findTicketById(id);
        // Verify ownership
        if (ticket.customer.customerId?.toString() !== user.customerId) {
            return ResponseBuilder.error('Ticket not found', 404);
        }
        const messages = await this.ticketsService.getTicketMessages(id, false);
        return ResponseBuilder.success({ ticket, messages });
    }

    @Post('my/:id/messages')
    @ApiOperation({ summary: 'Add message to my ticket' })
    async addMessageToMyTicket(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { content: string; attachments?: string[] }
    ) {
        const ticket = await this.ticketsService.findTicketById(id);
        if (ticket.customer.customerId?.toString() !== user.customerId) {
            return ResponseBuilder.error('Ticket not found', 404);
        }

        const message = await this.ticketsService.addMessage(id, {
            senderType: MessageSenderType.CUSTOMER,
            senderId: user.customerId,
            senderName: user.name,
            content: data.content,
            attachments: data.attachments,
        });
        return ResponseBuilder.success(message, 'Message added successfully');
    }

    @Post('my/:id/rate')
    @ApiOperation({ summary: 'Rate a resolved ticket' })
    async rateTicket(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { rating: number; feedback?: string }
    ) {
        const ticket = await this.ticketsService.findTicketById(id);
        if (ticket.customer.customerId?.toString() !== user.customerId) {
            return ResponseBuilder.error('Ticket not found', 404);
        }

        const updated = await this.ticketsService.addSatisfactionRating(id, data.rating, data.feedback);
        return ResponseBuilder.success(updated, 'Rating submitted successfully');
    }

    // ==================== Admin Tickets ====================

    @Get('admin')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get all tickets (admin)' })
    async getAllTickets(
        @Query('status') status?: TicketStatus,
        @Query('priority') priority?: TicketPriority,
        @Query('assignedTo') assignedTo?: string,
        @Query('categoryId') categoryId?: string,
        @Query('search') search?: string,
        @Query('page') page?: number,
        @Query('limit') limit?: number
    ) {
        const result = await this.ticketsService.findTickets({
            status,
            priority,
            assignedTo,
            categoryId,
            search,
            page,
            limit,
        });
        return ResponseBuilder.success(result);
    }

    @Post('admin/search')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Advanced search for tickets' })
    async advancedSearch(@Body() searchDto: AdvancedSearchDto) {
        const result = await this.ticketsService.advancedSearch(searchDto);
        return ResponseBuilder.success(result);
    }

    @Get('admin/stats')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get ticket statistics' })
    async getTicketStats() {
        const stats = await this.ticketsService.getTicketStats();
        return ResponseBuilder.success(stats);
    }

    @Get('admin/my-stats')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get my agent statistics' })
    async getMyAgentStats(@CurrentUser() user: any) {
        const stats = await this.ticketsService.getAgentStats(user.adminId);
        return ResponseBuilder.success(stats);
    }

    @Get('admin/:id')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get ticket details (admin)' })
    async getTicketDetails(@Param('id') id: string) {
        const ticket = await this.ticketsService.findTicketById(id);
        const messages = await this.ticketsService.getTicketMessages(id, true);
        return ResponseBuilder.success({ ticket, messages });
    }

    @Put('admin/:id/status')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Update ticket status' })
    async updateTicketStatus(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { status: TicketStatus; resolution?: { summary: string; type: string } }
    ) {
        const ticket = await this.ticketsService.updateTicketStatus(
            id,
            data.status,
            user.adminId,
            data.resolution
        );
        return ResponseBuilder.success(ticket, 'Status updated successfully');
    }

    @Put('admin/:id/assign')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Assign ticket to agent' })
    async assignTicket(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { agentId: string }
    ) {
        const ticket = await this.ticketsService.assignTicket(id, data.agentId, user.adminId);
        return ResponseBuilder.success(ticket, 'Ticket assigned successfully');
    }

    @Put('admin/:id/escalate')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Escalate ticket' })
    async escalateTicket(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { reason: string }
    ) {
        const ticket = await this.ticketsService.escalateTicket(id, user.adminId, data.reason);
        return ResponseBuilder.success(ticket, 'Ticket escalated successfully');
    }

    @Post('admin/:id/messages')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Add message to ticket (admin)' })
    async addAgentMessage(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { content: string; isInternal?: boolean; attachments?: string[] }
    ) {
        const message = await this.ticketsService.addMessage(id, {
            senderType: MessageSenderType.AGENT,
            senderId: user.adminId,
            senderName: user.name,
            content: data.content,
            isInternal: data.isInternal,
            attachments: data.attachments,
        });
        return ResponseBuilder.success(message, 'Message added successfully');
    }

    @Post('admin/merge')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Merge tickets' })
    async mergeTickets(
        @CurrentUser() user: any,
        @Body() data: { primaryId: string; secondaryIds: string[] }
    ) {
        const ticket = await this.ticketsService.mergeTickets(
            data.primaryId,
            data.secondaryIds,
            user.adminId
        );
        return ResponseBuilder.success(ticket, 'Tickets merged successfully');
    }

    // ==================== Canned Responses ====================

    @Get('canned-responses')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get canned responses' })
    async getCannedResponses(
        @CurrentUser() user: any,
        @Query('categoryId') categoryId?: string
    ) {
        const responses = await this.ticketsService.findCannedResponses(user.adminId, categoryId);
        return ResponseBuilder.success(responses);
    }

    @Post('canned-responses')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Create canned response' })
    async createCannedResponse(@CurrentUser() user: any, @Body() data: any) {
        const response = await this.ticketsService.createCannedResponse(data, user.adminId);
        return ResponseBuilder.success(response, 'Canned response created successfully');
    }

    @Post('canned-responses/:id/use')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Mark canned response as used' })
    async useCannedResponse(@Param('id') id: string) {
        const response = await this.ticketsService.useCannedResponse(id);
        return ResponseBuilder.success(response);
    }

    // ==================== File Upload ====================

    @Post('upload')
    @ApiOperation({ summary: 'Upload ticket attachments' })
    @ApiConsumes('multipart/form-data')
    @ApiBody({
        schema: {
            type: 'object',
            properties: {
                files: {
                    type: 'array',
                    items: {
                        type: 'string',
                        format: 'binary',
                    },
                },
            },
        },
    })
    async uploadAttachments(@Body() body: { files: Array<{ base64: string; filename: string }> }) {
        try {
            const uploadedUrls: string[] = [];

            for (const file of body.files) {
                const result = await this.uploadsService.uploadBase64(
                    file.base64,
                    file.filename,
                    'support/tickets',
                );
                uploadedUrls.push(result.url);
            }

            return ResponseBuilder.success(
                { urls: uploadedUrls },
                'Files uploaded successfully',
            );
        } catch (error) {
            return ResponseBuilder.error(
                'Failed to upload files',
                500,
            );
        }
    }
}
