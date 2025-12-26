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
import { RolesService } from './roles.service';
import { PermissionsService } from './permissions.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { PermissionsGuard } from '@guards/permissions.guard';
import { RequirePermissions } from '@decorators/permissions.decorator';
import { PERMISSIONS } from './constants/permissions.constant';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎭 Roles Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Roles & Permissions')
@Controller('roles')
@UseGuards(JwtAuthGuard, PermissionsGuard)
@ApiBearerAuth('JWT-auth')
export class RolesController {
    constructor(
        private readonly rolesService: RolesService,
        private readonly permissionsService: PermissionsService,
    ) { }

    @Get()
    @RequirePermissions(PERMISSIONS.ROLES.VIEW)
    @ApiOperation({ summary: 'Get all roles' })
    async findAll() {
        const roles = await this.rolesService.findAll();

        return ResponseBuilder.success(
            roles,
            'Roles retrieved successfully',
            'تم استرجاع الأدوار بنجاح',
        );
    }

    @Get(':id')
    @RequirePermissions(PERMISSIONS.ROLES.VIEW)
    @ApiOperation({ summary: 'Get role by ID' })
    async findById(@Param('id') id: string) {
        const role = await this.rolesService.findById(id);

        return ResponseBuilder.success(
            role,
            'Role retrieved successfully',
            'تم استرجاع الدور بنجاح',
        );
    }

    @Post()
    @RequirePermissions(PERMISSIONS.ROLES.CREATE)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create role' })
    async create(@Body() createRoleDto: any) {
        const role = await this.rolesService.create(createRoleDto);

        return ResponseBuilder.created(
            role,
            'Role created successfully',
            'تم إنشاء الدور بنجاح',
        );
    }

    @Put(':id')
    @RequirePermissions(PERMISSIONS.ROLES.UPDATE)
    @ApiOperation({ summary: 'Update role' })
    async update(@Param('id') id: string, @Body() updateData: any) {
        const role = await this.rolesService.update(id, updateData);

        return ResponseBuilder.success(
            role,
            'Role updated successfully',
            'تم تحديث الدور بنجاح',
        );
    }

    @Delete(':id')
    @RequirePermissions(PERMISSIONS.ROLES.DELETE)
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Delete role' })
    async delete(@Param('id') id: string) {
        await this.rolesService.delete(id);

        return ResponseBuilder.success(
            null,
            'Role deleted successfully',
            'تم حذف الدور بنجاح',
        );
    }

    // ═══════════════════════════════════
    // Role-Permission Management
    // ═══════════════════════════════════

    @Get(':id/permissions')
    @RequirePermissions(PERMISSIONS.ROLES.VIEW)
    @ApiOperation({ summary: 'Get permissions for role' })
    async getRolePermissions(@Param('id') id: string) {
        const permissions = await this.permissionsService.getPermissionsForRole(id);

        return ResponseBuilder.success(
            permissions,
            'Permissions retrieved successfully',
            'تم استرجاع الصلاحيات بنجاح',
        );
    }

    @Post(':id/permissions')
    @RequirePermissions(PERMISSIONS.ROLES.ASSIGN_PERMISSIONS)
    @ApiOperation({ summary: 'Assign permissions to role' })
    async assignPermissions(
        @Param('id') id: string,
        @Body('permissionIds') permissionIds: string[],
    ) {
        await this.permissionsService.assignPermissionsToRole(id, permissionIds);

        return ResponseBuilder.success(
            null,
            'Permissions assigned successfully',
            'تم تعيين الصلاحيات بنجاح',
        );
    }
}
