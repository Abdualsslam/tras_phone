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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses } from '@common/decorators/api-error-responses.decorator';
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
    @ApiOperation({
        summary: 'Get all roles',
        description: 'Retrieve all roles in the system.',
    })
    @ApiResponse({ status: 200, description: 'Roles retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Get role by ID',
        description: 'Retrieve detailed information about a specific role.',
    })
    @ApiParam({ name: 'id', description: 'Role ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Role retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Create role',
        description: 'Create a new role with specified permissions.',
    })
    @ApiResponse({ status: 201, description: 'Role created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Update role',
        description: 'Update role information and permissions.',
    })
    @ApiParam({ name: 'id', description: 'Role ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Role updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Delete role',
        description: 'Delete a role. This action cannot be undone.',
    })
    @ApiParam({ name: 'id', description: 'Role ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 204, description: 'Role deleted successfully' })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Get permissions for role',
        description: 'Retrieve all permissions assigned to a specific role.',
    })
    @ApiParam({ name: 'id', description: 'Role ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Role permissions retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
    @ApiOperation({
        summary: 'Assign permissions to role',
        description: 'Assign permissions to a role. Existing permissions will be replaced.',
    })
    @ApiParam({ name: 'id', description: 'Role ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Permissions assigned successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
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
