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
import { ProductsService } from './products.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Products Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Products')
@Controller('products')
export class ProductsController {
    constructor(private readonly productsService: ProductsService) { }

    // ═════════════════════════════════════
    // Public Endpoints
    // ═════════════════════════════════════

    @Public()
    @Get()
    @ApiOperation({ summary: 'Get all products with filters' })
    async findAll(@Query() query: any) {
        const result = await this.productsService.findAll(query);
        return ResponseBuilder.success(
            result.data,
            'Products retrieved',
            'تم استرجاع المنتجات',
            result.pagination,
        );
    }

    @Public()
    @Get(':identifier')
    @ApiOperation({ summary: 'Get product by ID or slug' })
    async findOne(@Param('identifier') identifier: string) {
        const product = await this.productsService.findByIdOrSlug(identifier);
        return ResponseBuilder.success(product, 'Product retrieved', 'تم استرجاع المنتج');
    }

    @Public()
    @Get(':id/reviews')
    @ApiOperation({ summary: 'Get product reviews' })
    async getReviews(@Param('id') id: string) {
        const reviews = await this.productsService.getReviews(id);
        return ResponseBuilder.success(reviews, 'Reviews retrieved', 'تم استرجاع التقييمات');
    }

    // ═════════════════════════════════════
    // Admin Endpoints
    // ═════════════════════════════════════

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post()
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create product' })
    async create(@Body() data: any) {
        const product = await this.productsService.create(data);
        return ResponseBuilder.created(product, 'Product created', 'تم إنشاء المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Update product' })
    async update(@Param('id') id: string, @Body() data: any) {
        const product = await this.productsService.update(id, data);
        return ResponseBuilder.success(product, 'Product updated', 'تم تحديث المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Delete(':id')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Delete product' })
    async delete(@Param('id') id: string) {
        await this.productsService.delete(id);
        return ResponseBuilder.success(null, 'Product deleted', 'تم حذف المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/prices')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Set product prices for all levels' })
    async setPrices(@Param('id') id: string, @Body() prices: any[]) {
        await this.productsService.setPrices(id, prices);
        return ResponseBuilder.success(null, 'Prices updated', 'تم تحديث الأسعار');
    }

    // ═════════════════════════════════════
    // Customer Endpoints
    // ═════════════════════════════════════

    @UseGuards(JwtAuthGuard)
    @Get('wishlist/my')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get my wishlist' })
    async getWishlist(@CurrentUser() user: any) {
        const wishlist = await this.productsService.getWishlist(user.customerId);
        return ResponseBuilder.success(wishlist, 'Wishlist retrieved', 'تم استرجاع المفضلة');
    }

    @UseGuards(JwtAuthGuard)
    @Post(':id/wishlist')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Add to wishlist' })
    async addToWishlist(@Param('id') id: string, @CurrentUser() user: any) {
        await this.productsService.addToWishlist(user.customerId, id);
        return ResponseBuilder.success(null, 'Added to wishlist', 'تم الإضافة للمفضلة');
    }

    @UseGuards(JwtAuthGuard)
    @Delete(':id/wishlist')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Remove from wishlist' })
    async removeFromWishlist(@Param('id') id: string, @CurrentUser() user: any) {
        await this.productsService.removeFromWishlist(user.customerId, id);
        return ResponseBuilder.success(null, 'Removed from wishlist', 'تم الإزالة من المفضلة');
    }

    @UseGuards(JwtAuthGuard)
    @Post(':id/reviews')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Add product review' })
    async addReview(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() data: any,
    ) {
        const review = await this.productsService.addReview({
            ...data,
            productId: id,
            customerId: user.customerId,
        });
        return ResponseBuilder.created(review, 'Review added', 'تم إضافة التقييم');
    }
}
