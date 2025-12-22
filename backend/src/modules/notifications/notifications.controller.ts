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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
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
    @ApiOperation({ summary: 'Get my notifications' })
    async getMyNotifications(@CurrentUser() user: any, @Query() query: any) {
        const result = await this.notificationsService.getCustomerNotifications(user.customerId, query);
        return ResponseBuilder.success(result.data, 'Notifications retrieved', 'تم استرجاع الإشعارات', {
            total: result.total,
            unreadCount: result.unreadCount,
        });
    }

    @Put(':id/read')
    @ApiOperation({ summary: 'Mark notification as read' })
    async markAsRead(@Param('id') id: string) {
        await this.notificationsService.markAsRead(id);
        return ResponseBuilder.success(null, 'Marked as read', 'تم التعليم كمقروء');
    }

    @Put('read-all')
    @ApiOperation({ summary: 'Mark all notifications as read' })
    async markAllAsRead(@CurrentUser() user: any) {
        await this.notificationsService.markAllAsRead(user.customerId);
        return ResponseBuilder.success(null, 'All marked as read', 'تم تعليم الكل كمقروء');
    }

    @Post('token')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Register push token' })
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
    @ApiOperation({ summary: 'Send custom notification to customer' })
    async sendNotification(@Body() data: any) {
        const notification = await this.notificationsService.sendCustom(data);
        return ResponseBuilder.created(notification, 'Notification sent', 'تم إرسال الإشعار');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('templates')
    @ApiOperation({ summary: 'Get notification templates' })
    async getTemplates() {
        const templates = await this.notificationsService.getTemplates();
        return ResponseBuilder.success(templates, 'Templates retrieved', 'تم استرجاع القوالب');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Post('templates')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create notification template' })
    async createTemplate(@Body() data: any) {
        const template = await this.notificationsService.createTemplate(data);
        return ResponseBuilder.created(template, 'Template created', 'تم إنشاء القالب');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Put('templates/:id')
    @ApiOperation({ summary: 'Update notification template' })
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
    @ApiOperation({ summary: 'Get notification campaigns' })
    async getCampaigns(@Query() query: any) {
        const campaigns = await this.notificationsService.getCampaigns(query);
        return ResponseBuilder.success(campaigns, 'Campaigns retrieved', 'تم استرجاع الحملات');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('campaigns')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create notification campaign' })
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
    @ApiOperation({ summary: 'Launch notification campaign' })
    async launchCampaign(@Param('id') id: string) {
        await this.notificationsService.launchCampaign(id);
        return ResponseBuilder.success(null, 'Campaign launched', 'تم إطلاق الحملة');
    }
}
