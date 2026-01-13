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
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiParam,
  ApiResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { AdminsService } from './admins.service';
import { RolesService } from './roles.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { PermissionsGuard } from '@guards/permissions.guard';
import { RequirePermissions } from '@decorators/permissions.decorator';
import { PERMISSIONS } from './constants/permissions.constant';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { CreateAdminDto } from './dto/create-admin.dto';
import { CreateAdminWithUserDto } from './dto/create-admin-with-user.dto';
import { UpdateAdminDto } from './dto/update-admin.dto';
import { AssignRoleDto } from './dto/assign-role.dto';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { PaginationQueryDto } from '@common/dto/pagination-query.dto';

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
  ) {}

  @Get()
  @RequirePermissions(PERMISSIONS.ADMINS.VIEW)
  @ApiOperation({
    summary: 'Get all admin users',
    description:
      'Retrieve a paginated list of all admin users with optional filtering',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    example: 1,
    description: 'Page number',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    example: 20,
    description: 'Items per page',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Search by name or employee code',
  })
  @ApiQuery({
    name: 'department',
    required: false,
    type: String,
    description: 'Filter by department',
  })
  @ApiQuery({
    name: 'employmentStatus',
    required: false,
    enum: ['active', 'on_leave', 'suspended', 'terminated'],
    description: 'Filter by employment status',
  })
  @ApiResponse({
    status: 200,
    description: 'Admin users retrieved successfully',
    type: ApiResponseDto,
    isArray: false,
  })
  @ApiCommonErrorResponses()
  async findAll(
    @Query()
    query: PaginationQueryDto & {
      search?: string;
      department?: string;
      employmentStatus?: string;
    },
  ) {
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
          hasNextPage:
            (query.page || 1) < Math.ceil(result.total / (query.limit || 20)),
          hasPreviousPage: (query.page || 1) > 1,
        },
      },
    );
  }

  @Get(':id')
  @RequirePermissions(PERMISSIONS.ADMINS.VIEW)
  @ApiOperation({
    summary: 'Get admin user by ID',
    description: 'Retrieve detailed information about a specific admin user',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Admin user retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
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
  @ApiOperation({
    summary: 'Create admin user',
    description:
      'Create a new admin user. The user must already exist with userType=admin',
  })
  @ApiResponse({
    status: 201,
    description: 'Admin user created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async create(@Body() createAdminDto: CreateAdminDto) {
    const adminUser = await this.adminsService.create(createAdminDto);

    return ResponseBuilder.created(
      adminUser,
      'Admin user created successfully',
      'تم إنشاء المستخدم الإداري بنجاح',
    );
  }

  @Post('create-with-user')
  @RequirePermissions(PERMISSIONS.ADMINS.CREATE)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create admin user with new user account',
    description: 'Create a new user account and admin profile in one operation',
  })
  @ApiResponse({
    status: 201,
    description: 'Admin user created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createWithUser(@Body() createAdminWithUserDto: CreateAdminWithUserDto) {
    const adminUser = await this.adminsService.createWithUser(
      createAdminWithUserDto,
    );

    return ResponseBuilder.created(
      adminUser,
      'Admin user created successfully',
      'تم إنشاء المستخدم الإداري بنجاح',
    );
  }

  @Put(':id')
  @RequirePermissions(PERMISSIONS.ADMINS.UPDATE)
  @ApiOperation({
    summary: 'Update admin user',
    description: 'Update admin user information. All fields are optional.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Admin user updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async update(@Param('id') id: string, @Body() updateData: UpdateAdminDto) {
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
  @ApiOperation({
    summary: 'Delete admin user',
    description: 'Delete an admin user. This action cannot be undone.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 204,
    description: 'Admin user deleted successfully',
  })
  @ApiCommonErrorResponses()
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
  @ApiOperation({
    summary: 'Get roles for admin user',
    description: 'Retrieve all roles assigned to a specific admin user',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Roles retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
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
  @ApiOperation({
    summary: 'Assign role to admin user',
    description:
      'Assign a role to an admin user. The role must exist in the system.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Role assigned successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async assignRole(
    @Param('id') id: string,
    @Body() assignRoleDto: AssignRoleDto,
  ) {
    await this.rolesService.assignToAdmin(
      id,
      assignRoleDto.roleId,
      assignRoleDto.assignedBy,
    );

    return ResponseBuilder.success(
      null,
      'Role assigned successfully',
      'تم تعيين الدور بنجاح',
    );
  }

  @Delete(':id/roles/:roleId')
  @RequirePermissions(PERMISSIONS.USERS.MANAGE_ROLES)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove role from admin user',
    description: 'Remove a role from an admin user',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiParam({
    name: 'roleId',
    description: 'Role ID to remove',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 204,
    description: 'Role removed successfully',
  })
  @ApiCommonErrorResponses()
  async removeRole(@Param('id') id: string, @Param('roleId') roleId: string) {
    await this.rolesService.removeFromAdmin(id, roleId);

    return ResponseBuilder.success(
      null,
      'Role removed successfully',
      'تم إزالة الدور بنجاح',
    );
  }
}
