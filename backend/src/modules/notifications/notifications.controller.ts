import {
    Controller,
    Get,
    Post,
    Put,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses, ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔔 Notifications Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    // ═════════════════════════════════════
    // Customer Endpoints
    // ═════════════════════════════════════

    @Get('my')
    @ApiOperation({
        summary: 'Get my notifications',
        description: 'Retrieve all notifications for the current customer with pagination.',
    })
    @ApiResponse({ status: 200, description: 'Notifications retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async getMyNotifications(@CurrentUser() user: any, @Query() query: any) {
        const result = await this.notificationsService.getCustomerNotifications(user.customerId, query);
        return ResponseBuilder.success(result.data, 'Notifications retrieved', 'تم استرجاع الإشعارات', {
            total: result.total,
            unreadCount: result.unreadCount,
        });
    }

    @Put(':id/read')
    @ApiOperation({
        summary: 'Mark notification as read',
        description: 'Mark a specific notification as read.',
    })
    @ApiParam({ name: 'id', description: 'Notification ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Notification marked as read successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async markAsRead(@Param('id') id: string) {
        await this.notificationsService.markAsRead(id);
        return ResponseBuilder.success(null, 'Marked as read', 'تم التعليم كمقروء');
    }

    @Put('read-all')
    @ApiOperation({
        summary: 'Mark all notifications as read',
        description: 'Mark all notifications for the current customer as read.',
    })
    @ApiResponse({ status: 200, description: 'All notifications marked as read successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async markAllAsRead(@CurrentUser() user: any) {
        await this.notificationsService.markAllAsRead(user.customerId);
        return ResponseBuilder.success(null, 'All marked as read', 'تم تعليم الكل كمقروء');
    }

    @Post('token')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Register push token',
        description: 'Register a push notification token for the current customer.',
    })
    @ApiResponse({ status: 201, description: 'Push token registered successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async registerToken(@CurrentUser() user: any, @Body() data: any) {
        const token = await this.notificationsService.registerToken({
            ...data,
            customerId: user.customerId,
        });
        return ResponseBuilder.created(token, 'Token registered', 'تم تسجيل التوكن');
    }

    // ═════════════════════════════════════
    // Admin Endpoints
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('send')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Send custom notification to customer',
        description: 'Send a custom notification to a customer. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Notification sent successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async sendNotification(@Body() data: any) {
        const notification = await this.notificationsService.sendCustom(data);
        return ResponseBuilder.created(notification, 'Notification sent', 'تم إرسال الإشعار');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('templates')
    @ApiOperation({
        summary: 'Get notification templates',
        description: 'Retrieve all notification templates. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Notification templates retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getTemplates() {
        const templates = await this.notificationsService.getTemplates();
        return ResponseBuilder.success(templates, 'Templates retrieved', 'تم استرجاع القوالب');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Post('templates')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create notification template',
        description: 'Create a new notification template. Super admin only.',
    })
    @ApiResponse({ status: 201, description: 'Notification template created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createTemplate(@Body() data: any) {
        const template = await this.notificationsService.createTemplate(data);
        return ResponseBuilder.created(template, 'Template created', 'تم إنشاء القالب');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Put('templates/:id')
    @ApiOperation({
        summary: 'Update notification template',
        description: 'Update a notification template. Super admin only.',
    })
    @ApiParam({ name: 'id', description: 'Template ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Notification template updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async updateTemplate(@Param('id') id: string, @Body() data: any) {
        const template = await this.notificationsService.updateTemplate(id, data);
        return ResponseBuilder.success(template, 'Template updated', 'تم تحديث القالب');
    }

    // ═════════════════════════════════════
    // Campaigns
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('campaigns')
    @ApiOperation({
        summary: 'Get notification campaigns',
        description: 'Retrieve all notification campaigns. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Notification campaigns retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getCampaigns(@Query() query: any) {
        const campaigns = await this.notificationsService.getCampaigns(query);
        return ResponseBuilder.success(campaigns, 'Campaigns retrieved', 'تم استرجاع الحملات');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('campaigns')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create notification campaign',
        description: 'Create a new notification campaign. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Notification campaign created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createCampaign(@Body() data: any, @CurrentUser() user: any) {
        const campaign = await this.notificationsService.createCampaign({
            ...data,
            createdBy: user._id,
        });
        return ResponseBuilder.created(campaign, 'Campaign created', 'تم إنشاء الحملة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('campaigns/:id/launch')
    @ApiOperation({
        summary: 'Launch notification campaign',
        description: 'Launch a notification campaign to send notifications to all recipients. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Campaign ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Campaign launched successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async launchCampaign(@Param('id') id: string) {
        await this.notificationsService.launchCampaign(id);
        return ResponseBuilder.success(null, 'Campaign launched', 'تم إطلاق الحملة');
    }
}
