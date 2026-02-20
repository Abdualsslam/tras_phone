import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuditService } from './audit.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuditAction, AuditResource } from './schemas/audit-log.schema';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { UserRole } from '@/common/enums/user-role.enum';

@ApiTags('Audit')
@Controller('audit')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  // ==================== Audit Logs ====================

  @Get('logs')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get audit logs' })
  async getAuditLogs(
    @Query('action') action?: AuditAction,
    @Query('resource') resource?: AuditResource,
    @Query('resourceId') resourceId?: string,
    @Query('actorType') actorType?: string,
    @Query('actorId') actorId?: string,
    @Query('severity') severity?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const result = await this.auditService.findAuditLogs({
      action,
      resource,
      resourceId,
      actorType,
      actorId,
      severity,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      search,
      page,
      limit,
    });
    return ResponseBuilder.success(result);
  }

  @Get('logs/critical')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get critical audit logs' })
  async getCriticalLogs(@Query('days') days?: string) {
    const daysNum = days ? parseInt(days, 10) : 7;
    const validDays = isNaN(daysNum) ? 7 : daysNum;
    const logs = await this.auditService.getCriticalLogs(validDays);
    return ResponseBuilder.success(logs);
  }

  @Get('logs/resource/:resource/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get resource history' })
  async getResourceHistory(
    @Param('resource') resource: AuditResource,
    @Param('id') id: string,
  ) {
    const logs = await this.auditService.getResourceHistory(resource, id);
    return ResponseBuilder.success(logs);
  }

  @Get('logs/actor/:type/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get actor activity' })
  async getActorActivity(
    @Param('type') type: string,
    @Param('id') id: string,
    @Query('limit') limit?: number,
  ) {
    const logs = await this.auditService.getActorActivity(type, id, limit);
    return ResponseBuilder.success(logs);
  }

  // ==================== Admin Activities ====================

  @Get('activities')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get recent admin activities' })
  async getRecentActivities(@Query('limit') limit?: number) {
    const activities = await this.auditService.getRecentActivities(limit);
    return ResponseBuilder.success(activities);
  }

  @Get('activities/my')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get my activities' })
  async getMyActivities(
    @CurrentUser() user: any,
    @Query('days') days?: string,
  ) {
    const daysNum = days ? parseInt(days, 10) : 30;
    const validDays = isNaN(daysNum) ? 30 : daysNum;
    const activities = await this.auditService.getAdminActivities(
      user.adminId,
      validDays,
    );
    return ResponseBuilder.success(activities);
  }

  @Get('activities/admin/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get admin activities by ID' })
  async getAdminActivities(
    @Param('id') id: string,
    @Query('days') days?: string,
  ) {
    const daysNum = days ? parseInt(days, 10) : 30;
    const validDays = isNaN(daysNum) ? 30 : daysNum;
    const activities = await this.auditService.getAdminActivities(
      id,
      validDays,
    );
    return ResponseBuilder.success(activities);
  }

  // ==================== Login History ====================

  @Get('logins')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get login history for user' })
  async getLoginHistory(
    @Query('userId') userId: string,
    @Query('userType') userType: 'admin' | 'customer',
    @Query('limit') limit?: number,
  ) {
    const history = await this.auditService.getLoginHistory(
      userId,
      userType,
      limit,
    );
    return ResponseBuilder.success(history);
  }

  @Get('logins/my')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get my login history' })
  async getMyLoginHistory(
    @CurrentUser() user: any,
    @Query('limit') limit?: number,
  ) {
    const history = await this.auditService.getLoginHistory(
      user.adminId,
      'admin',
      limit,
    );
    return ResponseBuilder.success(history);
  }

  @Get('logins/suspicious')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get suspicious logins' })
  async getSuspiciousLogins(@Query('days') days?: string) {
    const daysNum = days ? parseInt(days, 10) : 7;
    const validDays = isNaN(daysNum) ? 7 : daysNum;
    const logins = await this.auditService.getSuspiciousLogins(validDays);
    return ResponseBuilder.success(logins);
  }

  @Get('logins/failed')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get failed login attempts' })
  async getFailedLogins(
    @Query('email') email?: string,
    @Query('days') days?: string,
  ) {
    const daysNum = days ? parseInt(days, 10) : 7;
    const validDays = isNaN(daysNum) ? 7 : daysNum;
    const logins = await this.auditService.getFailedLogins(email, validDays);
    return ResponseBuilder.success(logins);
  }

  @Get('logins/ip/:ip')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get logins by IP address' })
  async getLoginsByIP(@Param('ip') ip: string, @Query('days') days?: string) {
    const daysNum = days ? parseInt(days, 10) : 7;
    const validDays = isNaN(daysNum) ? 7 : daysNum;
    const logins = await this.auditService.getLoginsByIP(ip, validDays);
    return ResponseBuilder.success(logins);
  }

  // ==================== Statistics ====================

  @Get('stats')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get audit statistics' })
  async getAuditStats() {
    const stats = await this.auditService.getAuditStats();
    return ResponseBuilder.success(stats);
  }
}
