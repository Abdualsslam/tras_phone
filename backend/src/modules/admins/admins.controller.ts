import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminsService } from './admins.service';
import { RolesService } from './roles.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { PermissionsGuard } from '@guards/permissions.guard';
import { RequirePermissions } from '@decorators/permissions.decorator';
import { PERMISSIONS } from './constants/permissions.constant';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Admin Users Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Admin Users')
@Controller('admins')
@UseGuards(JwtAuthGuard, PermissionsGuard)
@ApiBearerAuth('JWT-auth')
export class AdminsController {
    constructor(
        private readonly adminsService: AdminsService,
        private readonly rolesService: RolesService,
    ) { }

    @Get()
    @RequirePermissions(PERMISSIONS.ADMINS.VIEW)
    @ApiOperation({ summary: 'Get all admin users' })
    async findAll(@Query() query: any) {
        const result = await this.adminsService.findAll(query);

        return ResponseBuilder.success(
            result.data,
            'Admin users retrieved successfully',
            'تم استرجاع المستخدمين الإداريين بنجاح',
            {
                pagination: {
                    total: result.total,
                    page: query.page || 1,
                    limit: query.limit || 20,
                    totalPages: Math.ceil(result.total / (query.limit || 20)),
                    hasNextPage: (query.page || 1) < Math.ceil(result.total / (query.limit || 20)),
                    hasPreviousPage: (query.page || 1) > 1,
                },
            },
        );
    }

    @Get(':id')
    @RequirePermissions(PERMISSIONS.ADMINS.VIEW)
    @ApiOperation({ summary: 'Get admin user by ID' })
    async findById(@Param('id') id: string) {
        const adminUser = await this.adminsService.findById(id);

        return ResponseBuilder.success(
            adminUser,
            'Admin user retrieved successfully',
            'تم استرجاع المستخدم الإداري بنجاح',
        );
    }

    @Post()
    @RequirePermissions(PERMISSIONS.ADMINS.CREATE)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create admin user' })
    async create(@Body() createAdminDto: any) {
        const adminUser = await this.adminsService.create(createAdminDto);

        return ResponseBuilder.created(
            adminUser,
            'Admin user created successfully',
            'تم إنشاء المستخدم الإداري بنجاح',
        );
    }

    @Put(':id')
    @RequirePermissions(PERMISSIONS.ADMINS.UPDATE)
    @ApiOperation({ summary: 'Update admin user' })
    async update(@Param('id') id: string, @Body() updateData: any) {
        const adminUser = await this.adminsService.update(id, updateData);

        return ResponseBuilder.success(
            adminUser,
            'Admin user updated successfully',
            'تم تحديث المستخدم الإداري بنجاح',
        );
    }

    @Delete(':id')
    @RequirePermissions(PERMISSIONS.ADMINS.DELETE)
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Delete admin user' })
    async delete(@Param('id') id: string) {
        await this.adminsService.delete(id);

        return ResponseBuilder.success(
            null,
            'Admin user deleted successfully',
            'تم حذف المستخدم الإداري بنجاح',
        );
    }

    // ═══════════════════════════════════
    // Role Assignment
    // ═══════════════════════════════════

    @Get(':id/roles')
    @RequirePermissions(PERMISSIONS.ADMINS.VIEW)
    @ApiOperation({ summary: 'Get roles for admin user' })
    async getAdminRoles(@Param('id') id: string) {
        const roles = await this.rolesService.getRolesForAdmin(id);

        return ResponseBuilder.success(
            roles,
            'Roles retrieved successfully',
            'تم استرجاع الأدوار بنجاح',
        );
    }

    @Post(':id/roles')
    @RequirePermissions(PERMISSIONS.USERS.MANAGE_ROLES)
    @ApiOperation({ summary: 'Assign role to admin user' })
    async assignRole(
        @Param('id') id: string,
        @Body('roleId') roleId: string,
        @Body('assignedBy') assignedBy?: string,
    ) {
        await this.rolesService.assignToAdmin(id, roleId, assignedBy);

        return ResponseBuilder.success(
            null,
            'Role assigned successfully',
            'تم تعيين الدور بنجاح',
        );
    }

    @Delete(':id/roles/:roleId')
    @RequirePermissions(PERMISSIONS.USERS.MANAGE_ROLES)
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Remove role from admin  user' })
    async removeRole(
        @Param('id') id: string,
        @Param('roleId') roleId: string,
    ) {
        await this.rolesService.removeFromAdmin(id, roleId);

        return ResponseBuilder.success(
            null,
            'Role removed successfully',
            'تم إزالة الدور بنجاح',
        );
    }
}
