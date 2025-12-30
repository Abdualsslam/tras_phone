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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { SetPricesDto } from './dto/set-prices.dto';
import { AddReviewDto } from './dto/add-review.dto';
import { ProductFilterQueryDto } from './dto/product-filter-query.dto';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses, ApiPublicErrorResponses } from '@common/decorators/api-error-responses.decorator';

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
    @ApiOperation({
        summary: 'Get all products with filters',
        description: 'Retrieve a paginated list of products with optional filtering by category, brand, price range, and more',
    })
    @ApiResponse({
        status: 200,
        description: 'Products retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiPublicErrorResponses()
    async findAll(@Query() query: ProductFilterQueryDto) {
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
    @ApiOperation({
        summary: 'Get product by ID or slug',
        description: 'Retrieve detailed information about a product by its ID or URL-friendly slug',
    })
    @ApiParam({ name: 'identifier', description: 'Product ID or slug', example: 'iphone-15-pro-max' })
    @ApiResponse({
        status: 200,
        description: 'Product retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiPublicErrorResponses()
    async findOne(@Param('identifier') identifier: string) {
        const product = await this.productsService.findByIdOrSlug(identifier);
        return ResponseBuilder.success(product, 'Product retrieved', 'تم استرجاع المنتج');
    }

    @Public()
    @Get(':id/reviews')
    @ApiOperation({
        summary: 'Get product reviews',
        description: 'Retrieve all approved reviews for a product',
    })
    @ApiParam({ name: 'id', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Reviews retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Create product',
        description: 'Create a new product. SKU and slug must be unique.',
    })
    @ApiResponse({
        status: 201,
        description: 'Product created successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async create(@Body() createProductDto: CreateProductDto) {
        const product = await this.productsService.create(createProductDto);
        return ResponseBuilder.created(product, 'Product created', 'تم إنشاء المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({
        summary: 'Update product',
        description: 'Update product information. All fields are optional.',
    })
    @ApiParam({ name: 'id', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Product updated successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto) {
        const product = await this.productsService.update(id, updateProductDto);
        return ResponseBuilder.success(product, 'Product updated', 'تم تحديث المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Delete(':id')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({
        summary: 'Delete product',
        description: 'Delete a product. This action cannot be undone.',
    })
    @ApiParam({ name: 'id', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 204,
        description: 'Product deleted successfully',
    })
    @ApiCommonErrorResponses()
    async delete(@Param('id') id: string) {
        await this.productsService.delete(id);
        return ResponseBuilder.success(null, 'Product deleted', 'تم حذف المنتج');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/prices')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({
        summary: 'Set product prices for all price levels',
        description: 'Set prices for a product across different price levels (e.g., retail, wholesale)',
    })
    @ApiParam({ name: 'id', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Prices updated successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async setPrices(@Param('id') id: string, @Body() setPricesDto: SetPricesDto) {
        await this.productsService.setPrices(id, setPricesDto.prices);
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
    @ApiOperation({
        summary: 'Add product review',
        description: 'Add a review and rating for a product. One review per product per customer.',
    })
    @ApiParam({ name: 'id', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 201,
        description: 'Review added successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async addReview(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() addReviewDto: AddReviewDto,
    ) {
        const review = await this.productsService.addReview({
            ...addReviewDto,
            productId: id,
            customerId: user.customerId,
        });
        return ResponseBuilder.created(review, 'Review added', 'تم إضافة التقييم');
    }
}
