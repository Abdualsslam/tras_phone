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
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiCommonErrorResponses,
  ApiPublicErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { CatalogService } from './catalog.service';
import { CategoriesService } from './categories.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📚 Catalog Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Catalog')
@Controller('catalog')
export class CatalogController {
  constructor(
    private readonly catalogService: CatalogService,
    private readonly categoriesService: CategoriesService,
  ) {}

  // ═════════════════════════════════════
  // Brands (Public Read)
  // ═════════════════════════════════════

  @Public()
  @Get('brands')
  @ApiOperation({
    summary: 'Get all brands',
    description:
      'Retrieve all brands with optional featured filter. Public endpoint.',
  })
  @ApiQuery({
    name: 'featured',
    required: false,
    type: Boolean,
    description: 'Filter featured brands only',
  })
  @ApiQuery({
    name: 'includeInactive',
    required: false,
    type: Boolean,
    description: 'Include inactive brands in results (admin only)',
  })
  @ApiResponse({
    status: 200,
    description: 'Brands retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getBrands(
    @Query('featured') featured?: boolean,
    @Query('includeInactive') includeInactive?: boolean,
  ) {
    const brands = await this.catalogService.findAllBrands({ featured, includeInactive });
    return ResponseBuilder.success(
      brands,
      'Brands retrieved',
      'تم استرجاع العلامات التجارية',
    );
  }

  @Public()
  @Get('brands/:slug')
  @ApiOperation({
    summary: 'Get brand by slug',
    description:
      'Retrieve detailed information about a brand by its slug. Public endpoint.',
  })
  @ApiParam({ name: 'slug', description: 'Brand slug', example: 'apple' })
  @ApiResponse({
    status: 200,
    description: 'Brand retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getBrandBySlug(@Param('slug') slug: string) {
    const brand = await this.catalogService.findBrandBySlug(slug);
    return ResponseBuilder.success(
      brand,
      'Brand retrieved',
      'تم استرجاع العلامة التجارية',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('brands')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create brand',
    description: 'Create a new brand. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Brand created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createBrand(@Body() data: any) {
    const brand = await this.catalogService.createBrand(data);
    return ResponseBuilder.created(
      brand,
      'Brand created',
      'تم إنشاء العلامة التجارية',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('brands/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update brand',
    description: 'Update brand information. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Brand ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Brand updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateBrand(@Param('id') id: string, @Body() data: any) {
    const brand = await this.catalogService.updateBrand(id, data);
    return ResponseBuilder.success(
      brand,
      'Brand updated',
      'تم تحديث العلامة التجارية',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Delete('brands/:id')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete brand',
    description: 'Delete a brand. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Brand ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Brand deleted successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async deleteBrand(@Param('id') id: string) {
    await this.catalogService.deleteBrand(id);
    return ResponseBuilder.success(
      null,
      'Brand deleted',
      'تم حذف العلامة التجارية',
    );
  }

  // ═════════════════════════════════════
  // Categories (Public Read)
  // ═════════════════════════════════════

  @Public()
  @Get('categories')
  @ApiOperation({
    summary: 'Get root categories',
    description: 'Retrieve all root-level categories. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Root categories retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getRootCategories() {
    const categories = await this.categoriesService.findRoots();
    return ResponseBuilder.success(
      categories,
      'Categories retrieved',
      'تم استرجاع الأقسام',
    );
  }

  @Public()
  @Get('categories/tree')
  @ApiOperation({
    summary: 'Get full category tree',
    description:
      'Retrieve the complete category hierarchy as a tree structure. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Category tree retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getCategoryTree() {
    const tree = await this.categoriesService.getTree();
    return ResponseBuilder.success(
      tree,
      'Category tree retrieved',
      'تم استرجاع شجرة الأقسام',
    );
  }

  @Public()
  @Get('categories/:id')
  @ApiOperation({
    summary: 'Get category with breadcrumb',
    description:
      'Retrieve category details including breadcrumb navigation. Public endpoint.',
  })
  @ApiParam({
    name: 'id',
    description: 'Category ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Category retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getCategoryById(@Param('id') id: string) {
    const result = await this.categoriesService.findWithBreadcrumb(id);
    return ResponseBuilder.success(
      result,
      'Category retrieved',
      'تم استرجاع القسم',
    );
  }

  @Public()
  @Get('categories/:id/children')
  @ApiOperation({
    summary: 'Get category children',
    description:
      'Retrieve all child categories for a specific category. Public endpoint.',
  })
  @ApiParam({
    name: 'id',
    description: 'Category ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Child categories retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getCategoryChildren(@Param('id') id: string) {
    const children = await this.categoriesService.findChildren(id);
    return ResponseBuilder.success(
      children,
      'Children retrieved',
      'تم استرجاع الأقسام الفرعية',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('categories')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create category',
    description: 'Create a new product category. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Category created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createCategory(@Body() data: any) {
    const category = await this.categoriesService.create(data);
    return ResponseBuilder.created(
      category,
      'Category created',
      'تم إنشاء القسم',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('categories/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update category',
    description: 'Update category information. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Category ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Category updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateCategory(@Param('id') id: string, @Body() data: any) {
    const category = await this.categoriesService.update(id, data);
    return ResponseBuilder.success(
      category,
      'Category updated',
      'تم تحديث القسم',
    );
  }

  // ═════════════════════════════════════
  // Devices (Public Read)
  // ═════════════════════════════════════

  @Public()
  @Get('devices')
  @ApiOperation({
    summary: 'Get all active devices',
    description:
      'Retrieve all active devices with optional limit. Public endpoint.',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Maximum number of devices to return',
  })
  @ApiQuery({
    name: 'popular',
    required: false,
    type: Boolean,
    description: 'Filter popular devices only',
  })
  @ApiResponse({
    status: 200,
    description: 'Devices retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getDevices(
    @Query('limit') limit?: number,
    @Query('popular') popular?: boolean,
  ) {
    const devices = popular
      ? await this.catalogService.findPopularDevices(limit)
      : await this.catalogService.findAllDevices(limit);
    return ResponseBuilder.success(
      devices,
      'Devices retrieved',
      'تم استرجاع الأجهزة',
    );
  }

  @Public()
  @Get('devices/brand/:brandId')
  @ApiOperation({
    summary: 'Get devices by brand',
    description: 'Retrieve all devices for a specific brand. Public endpoint.',
  })
  @ApiParam({
    name: 'brandId',
    description: 'Brand ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Devices retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getDevicesByBrand(@Param('brandId') brandId: string) {
    const devices = await this.catalogService.findDevicesByBrand(brandId);
    return ResponseBuilder.success(
      devices,
      'Devices retrieved',
      'تم استرجاع الأجهزة',
    );
  }

  @Public()
  @Get('devices/:slug')
  @ApiOperation({
    summary: 'Get device by slug',
    description:
      'Retrieve detailed information about a device by its slug. Public endpoint.',
  })
  @ApiParam({
    name: 'slug',
    description: 'Device slug',
    example: 'iphone-15-pro',
  })
  @ApiResponse({
    status: 200,
    description: 'Device retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getDeviceBySlug(@Param('slug') slug: string) {
    const device = await this.catalogService.findDeviceBySlug(slug);
    return ResponseBuilder.success(
      device,
      'Device retrieved',
      'تم استرجاع الجهاز',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('devices')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create device',
    description: 'Create a new device. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Device created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createDevice(@Body() data: any) {
    const device = await this.catalogService.createDevice(data);
    return ResponseBuilder.created(
      device,
      'Device created',
      'تم إنشاء الجهاز',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('devices/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update device',
    description: 'Update device information. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Device ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Device updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateDevice(@Param('id') id: string, @Body() data: any) {
    const device = await this.catalogService.updateDevice(id, data);
    return ResponseBuilder.success(
      device,
      'Device updated',
      'تم تحديث الجهاز',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Delete('devices/:id')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete device',
    description: 'Delete a device. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Device ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Device deleted successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async deleteDevice(@Param('id') id: string) {
    await this.catalogService.deleteDevice(id);
    return ResponseBuilder.success(
      null,
      'Device deleted',
      'تم حذف الجهاز',
    );
  }

  // ═════════════════════════════════════
  // Quality Types (Public Read)
  // ═════════════════════════════════════

  @Public()
  @Get('quality-types')
  @ApiOperation({
    summary: 'Get all quality types',
    description:
      'Retrieve all product quality types (new, used, refurbished, etc.). Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Quality types retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getQualityTypes() {
    const types = await this.catalogService.findAllQualityTypes();
    return ResponseBuilder.success(
      types,
      'Quality types retrieved',
      'تم استرجاع أنواع الجودة',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('quality-types')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create quality type',
    description: 'Create a new quality type. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Quality type created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createQualityType(@Body() data: any) {
    const qualityType = await this.catalogService.createQualityType(data);
    return ResponseBuilder.created(
      qualityType,
      'Quality type created',
      'تم إنشاء نوع الجودة',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('quality-types/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update quality type',
    description: 'Update quality type information. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Quality type ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Quality type updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateQualityType(@Param('id') id: string, @Body() data: any) {
    const qualityType = await this.catalogService.updateQualityType(id, data);
    return ResponseBuilder.success(
      qualityType,
      'Quality type updated',
      'تم تحديث نوع الجودة',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Delete('quality-types/:id')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete quality type',
    description: 'Delete a quality type. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Quality type ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Quality type deleted successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async deleteQualityType(@Param('id') id: string) {
    await this.catalogService.deleteQualityType(id);
    return ResponseBuilder.success(
      null,
      'Quality type deleted',
      'تم حذف نوع الجودة',
    );
  }
}
