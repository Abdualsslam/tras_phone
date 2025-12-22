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
    ) { }

    // ═════════════════════════════════════
    // Brands (Public Read)
    // ═════════════════════════════════════

    @Public()
    @Get('brands')
    @ApiOperation({ summary: 'Get all brands' })
    async getBrands(@Query('featured') featured?: boolean) {
        const brands = await this.catalogService.findAllBrands({ featured });
        return ResponseBuilder.success(brands, 'Brands retrieved', 'تم استرجاع العلامات التجارية');
    }

    @Public()
    @Get('brands/:slug')
    @ApiOperation({ summary: 'Get brand by slug' })
    async getBrandBySlug(@Param('slug') slug: string) {
        const brand = await this.catalogService.findBrandBySlug(slug);
        return ResponseBuilder.success(brand, 'Brand retrieved', 'تم استرجاع العلامة التجارية');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('brands')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create brand' })
    async createBrand(@Body() data: any) {
        const brand = await this.catalogService.createBrand(data);
        return ResponseBuilder.created(brand, 'Brand created', 'تم إنشاء العلامة التجارية');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('brands/:id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Update brand' })
    async updateBrand(@Param('id') id: string, @Body() data: any) {
        const brand = await this.catalogService.updateBrand(id, data);
        return ResponseBuilder.success(brand, 'Brand updated', 'تم تحديث العلامة التجارية');
    }

    // ═════════════════════════════════════
    // Categories (Public Read)
    // ═════════════════════════════════════

    @Public()
    @Get('categories')
    @ApiOperation({ summary: 'Get root categories' })
    async getRootCategories() {
        const categories = await this.categoriesService.findRoots();
        return ResponseBuilder.success(categories, 'Categories retrieved', 'تم استرجاع الأقسام');
    }

    @Public()
    @Get('categories/tree')
    @ApiOperation({ summary: 'Get full category tree' })
    async getCategoryTree() {
        const tree = await this.categoriesService.getTree();
        return ResponseBuilder.success(tree, 'Category tree retrieved', 'تم استرجاع شجرة الأقسام');
    }

    @Public()
    @Get('categories/:id')
    @ApiOperation({ summary: 'Get category with breadcrumb' })
    async getCategoryById(@Param('id') id: string) {
        const result = await this.categoriesService.findWithBreadcrumb(id);
        return ResponseBuilder.success(result, 'Category retrieved', 'تم استرجاع القسم');
    }

    @Public()
    @Get('categories/:id/children')
    @ApiOperation({ summary: 'Get category children' })
    async getCategoryChildren(@Param('id') id: string) {
        const children = await this.categoriesService.findChildren(id);
        return ResponseBuilder.success(children, 'Children retrieved', 'تم استرجاع الأقسام الفرعية');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('categories')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create category' })
    async createCategory(@Body() data: any) {
        const category = await this.categoriesService.create(data);
        return ResponseBuilder.created(category, 'Category created', 'تم إنشاء القسم');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('categories/:id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Update category' })
    async updateCategory(@Param('id') id: string, @Body() data: any) {
        const category = await this.categoriesService.update(id, data);
        return ResponseBuilder.success(category, 'Category updated', 'تم تحديث القسم');
    }

    // ═════════════════════════════════════
    // Devices (Public Read)
    // ═════════════════════════════════════

    @Public()
    @Get('devices')
    @ApiOperation({ summary: 'Get popular devices' })
    async getPopularDevices(@Query('limit') limit?: number) {
        const devices = await this.catalogService.findPopularDevices(limit);
        return ResponseBuilder.success(devices, 'Devices retrieved', 'تم استرجاع الأجهزة');
    }

    @Public()
    @Get('devices/brand/:brandId')
    @ApiOperation({ summary: 'Get devices by brand' })
    async getDevicesByBrand(@Param('brandId') brandId: string) {
        const devices = await this.catalogService.findDevicesByBrand(brandId);
        return ResponseBuilder.success(devices, 'Devices retrieved', 'تم استرجاع الأجهزة');
    }

    @Public()
    @Get('devices/:slug')
    @ApiOperation({ summary: 'Get device by slug' })
    async getDeviceBySlug(@Param('slug') slug: string) {
        const device = await this.catalogService.findDeviceBySlug(slug);
        return ResponseBuilder.success(device, 'Device retrieved', 'تم استرجاع الجهاز');
    }

    // ═════════════════════════════════════
    // Quality Types (Public)
    // ═════════════════════════════════════

    @Public()
    @Get('quality-types')
    @ApiOperation({ summary: 'Get all quality types' })
    async getQualityTypes() {
        const types = await this.catalogService.findAllQualityTypes();
        return ResponseBuilder.success(types, 'Quality types retrieved', 'تم استرجاع أنواع الجودة');
    }
}
