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
  ApiQuery,
  ApiResponse,
} from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { ProductsSearchService } from './products-search.service';
import { ProductsSearchSuggestionsService } from './products-search-suggestions.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '@guards/optional-jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { SetPricesDto } from './dto/set-prices.dto';
import { CreatePriceLevelDto } from './dto/create-price-level.dto';
import { UpdatePriceLevelDto } from './dto/update-price-level.dto';
import { AddReviewDto } from './dto/add-review.dto';
import { ProductFilterQueryDto } from './dto/product-filter-query.dto';
import { ProductsOnOfferQueryDto } from './dto/products-on-offer-query.dto';
import { 
  AdvancedSearchQueryDto,
  SearchSuggestionsQueryDto,
  AutocompleteQueryDto,
} from './dto/advanced-search-query.dto';
import { AddDeviceCompatibilityDto } from './dto/add-device-compatibility.dto';
import { CreateStockAlertDto } from './dto/create-stock-alert.dto';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiAuthErrorResponses,
  ApiCommonErrorResponses,
  ApiPublicErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { AuditService } from '../audit/audit.service';
import {
  AuditAction,
  AuditResource,
} from '../audit/schemas/audit-log.schema';
import { EducationalService } from '@modules/content/educational.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Products Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Products')
@Controller('products')
export class ProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly productsSearchService: ProductsSearchService,
    private readonly productsSearchSuggestionsService: ProductsSearchSuggestionsService,
    private readonly auditService: AuditService,
    private readonly educationalService: EducationalService,
  ) {}

  // ═════════════════════════════════════
  // Public Endpoints
  // ═════════════════════════════════════

  @Public()
  @Get('price-levels')
  @ApiOperation({
    summary: 'Get all price levels',
    description:
      'Retrieve all active price levels for customer pricing. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Price levels retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getPriceLevels() {
    const priceLevels = await this.productsService.findAllPriceLevels();
    return ResponseBuilder.success(
      priceLevels,
      'Price levels retrieved',
      'تم استرجاع مستويات الأسعار',
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get('featured')
  @ApiOperation({
    summary: 'Get featured products',
    description: 'Retrieve featured products for homepage',
  })
  @ApiResponse({
    status: 200,
    description: 'Featured products retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getFeatured(
    @Query('limit') limit?: number,
    @CurrentUser() user?: any,
  ) {
    const priceLevelId = user?.customerId
      ? await this.productsService.getPriceLevelIdForCustomer(user.customerId)
      : null;
    const result = await this.productsService.findAll({
      isFeatured: true,
      featured: true,
      limit: limit || 10,
      page: 1,
      priceLevelId: priceLevelId || undefined,
    });
    return ResponseBuilder.success(
      result.data,
      'Featured products retrieved',
      'تم استرجاع المنتجات المميزة',
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get('new-arrivals')
  @ApiOperation({
    summary: 'Get new arrival products',
    description: 'Retrieve recently added products',
  })
  @ApiResponse({
    status: 200,
    description: 'New arrivals retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getNewArrivals(
    @Query('limit') limit?: number,
    @CurrentUser() user?: any,
  ) {
    const priceLevelId = user?.customerId
      ? await this.productsService.getPriceLevelIdForCustomer(user.customerId)
      : null;
    const result = await this.productsService.findAll({
      sortBy: 'createdAt',
      sortOrder: 'desc',
      limit: limit || 10,
      page: 1,
      priceLevelId: priceLevelId || undefined,
    });
    return ResponseBuilder.success(
      result.data,
      'New arrivals retrieved',
      'تم استرجاع المنتجات الجديدة',
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get('best-sellers')
  @ApiOperation({
    summary: 'Get best selling products',
    description: 'Retrieve best selling products based on sales count',
  })
  @ApiResponse({
    status: 200,
    description: 'Best sellers retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getBestSellers(
    @Query('limit') limit?: number,
    @CurrentUser() user?: any,
  ) {
    const priceLevelId = user?.customerId
      ? await this.productsService.getPriceLevelIdForCustomer(user.customerId)
      : null;
    const result = await this.productsService.findAll({
      sortBy: 'salesCount',
      sortOrder: 'desc',
      limit: limit || 10,
      page: 1,
      priceLevelId: priceLevelId || undefined,
    });
    return ResponseBuilder.success(
      result.data,
      'Best sellers retrieved',
      'تم استرجاع الأكثر مبيعاً',
    );
  }

  // ═════════════════════════════════════
  // Advanced Search Endpoints
  // ═════════════════════════════════════

  @Public()
  @Get('search/advanced')
  @ApiOperation({
    summary: 'Advanced product search',
    description:
      'Perform advanced search with fuzzy matching, tag filtering, and relevance scoring',
  })
  @ApiResponse({
    status: 200,
    description: 'Search results retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async advancedSearch(@Query() query: AdvancedSearchQueryDto) {
    const result = await this.productsSearchService.advancedSearch(query);
    return ResponseBuilder.success(
      result.data,
      'Search results retrieved',
      'تم استرجاع نتائج البحث',
      result.pagination,
    );
  }

  @Public()
  @Get('search/suggestions')
  @ApiOperation({
    summary: 'Get search suggestions',
    description:
      'Get search suggestions based on query, including product names and tags',
  })
  @ApiResponse({
    status: 200,
    description: 'Suggestions retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getSearchSuggestions(@Query() query: SearchSuggestionsQueryDto) {
    const result = await this.productsSearchSuggestionsService.getSuggestions(query);
    return ResponseBuilder.success(
      result,
      'Suggestions retrieved',
      'تم استرجاع الاقتراحات',
    );
  }

  @Public()
  @Get('search/autocomplete')
  @ApiOperation({
    summary: 'Get autocomplete suggestions',
    description: 'Get autocomplete suggestions for search input',
  })
  @ApiResponse({
    status: 200,
    description: 'Autocomplete suggestions retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getAutocomplete(@Query() query: AutocompleteQueryDto) {
    const suggestions = await this.productsSearchSuggestionsService.getAutocomplete(query);
    return ResponseBuilder.success(
      suggestions,
      'Autocomplete suggestions retrieved',
      'تم استرجاع اقتراحات الاكتمال التلقائي',
    );
  }

  @Public()
  @Get('search/tags')
  @ApiOperation({
    summary: 'Get all available tags',
    description: 'Get all tags available in products for filtering',
  })
  @ApiResponse({
    status: 200,
    description: 'Tags retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getAllTags() {
    const tags = await this.productsSearchSuggestionsService.getAllTags();
    return ResponseBuilder.success(
      tags,
      'Tags retrieved',
      'تم استرجاع التاجات',
    );
  }

  @Public()
  @Get('search/popular-tags')
  @ApiOperation({
    summary: 'Get popular tags',
    description: 'Get most frequently used tags with their counts',
  })
  @ApiResponse({
    status: 200,
    description: 'Popular tags retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getPopularTags(@Query('limit') limit?: number) {
    const tags = await this.productsSearchSuggestionsService.getPopularTags(limit || 20);
    return ResponseBuilder.success(
      tags,
      'Popular tags retrieved',
      'تم استرجاع التاجات الشائعة',
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get()
  @ApiOperation({
    summary: 'Get all products with filters',
    description:
      'Retrieve a paginated list of products with optional filtering by category, brand, price range, and more',
  })
  @ApiResponse({
    status: 200,
    description: 'Products retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async findAll(@Query() query: ProductFilterQueryDto, @CurrentUser() user?: any) {
    const filters: any = { ...query };
    if (user?.customerId) {
      const priceLevelId = await this.productsService.getPriceLevelIdForCustomer(user.customerId);
      if (priceLevelId) filters.priceLevelId = priceLevelId;
    }
    const result = await this.productsService.findAll(filters);
    return ResponseBuilder.success(
      result.data,
      'Products retrieved',
      'تم استرجاع المنتجات',
      result.pagination,
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get('on-offer')
  @ApiOperation({
    summary: 'Get products on offer',
    description:
      'Retrieve all products that have direct offers (compareAtPrice > basePrice) with pagination, sorting, and filtering options',
  })
  @ApiResponse({
    status: 200,
    description: 'Products on offer retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getProductsOnOffer(
    @Query() query: ProductsOnOfferQueryDto,
    @CurrentUser() user?: any,
  ) {
    const filters: any = { ...query };
    if (user?.customerId) {
      const priceLevelId = await this.productsService.getPriceLevelIdForCustomer(user.customerId);
      if (priceLevelId) filters.priceLevelId = priceLevelId;
    }
    const result = await this.productsService.findProductsOnOffer(filters);
    return ResponseBuilder.success(
      result.data,
      'Products on offer retrieved',
      'تم استرجاع المنتجات ذات العروض',
      result.pagination,
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get(':id/educational-content')
  @ApiOperation({
    summary: 'Get educational content for product',
    description:
      'Retrieve educational content ranked by relevance for a given product context',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiQuery({ name: 'tags', required: false, description: 'Comma-separated intent tags' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({
    status: 200,
    description: 'Educational content retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getEducationalContentForProduct(
    @Param('id') id: string,
    @Query('tags') tags?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const parsedTags = tags
      ? tags
          .split(',')
          .map((tag) => tag.trim())
          .filter(Boolean)
      : [];

    const result = await this.educationalService.getContentByContext({
      productId: id,
      tags: parsedTags,
      page: page || 1,
      limit: limit || 20,
    });

    return ResponseBuilder.paginated(
      result.data,
      result.total,
      page || 1,
      limit || 20,
      'Educational content retrieved',
      'تم استرجاع المحتوى التعليمي',
    );
  }

  @Public()
  @UseGuards(OptionalJwtAuthGuard)
  @Get(':identifier')
  @ApiOperation({
    summary: 'Get product by ID or slug',
    description:
      'Retrieve detailed information about a product by its ID or URL-friendly slug',
  })
  @ApiParam({
    name: 'identifier',
    description: 'Product ID or slug',
    example: 'iphone-15-pro-max',
  })
  @ApiResponse({
    status: 200,
    description: 'Product retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async findOne(
    @Param('identifier') identifier: string,
    @CurrentUser() user?: any,
  ) {
    const priceLevelId = user?.customerId
      ? await this.productsService.getPriceLevelIdForCustomer(user.customerId)
      : undefined;
    const product = await this.productsService.findByIdOrSlug(identifier, priceLevelId ?? undefined);
    return ResponseBuilder.success(
      product,
      'Product retrieved',
      'تم استرجاع المنتج',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get(':id/reviews/admin')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get all product reviews (admin)',
    description:
      'Retrieve all reviews for a product including pending, for moderation. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Reviews retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getReviewsForAdmin(@Param('id') id: string) {
    const reviews = await this.productsService.getReviewsForAdmin(id);
    return ResponseBuilder.success(
      reviews,
      'Reviews retrieved',
      'تم استرجاع التقييمات',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id/reviews/mine')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get my review for product',
    description: 'Get current customer\'s review for a product (if any). Use to check if already reviewed.',
  })
  @ApiParam({ name: 'id', description: 'Product ID' })
  @ApiResponse({
    status: 200,
    description: 'Review or null if not reviewed',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getMyReview(@Param('id') id: string, @CurrentUser() user: any) {
    const review = await this.productsService.getMyReview(id, user.customerId);
    return ResponseBuilder.success(
      review,
      review ? 'Review found' : 'No review yet',
      review ? 'تم العثور على التقييم' : 'لم تقم بالتقييم بعد',
    );
  }

  @Public()
  @Get(':id/reviews')
  @ApiOperation({
    summary: 'Get product reviews',
    description: 'Retrieve all approved reviews for a product',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Reviews retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getReviews(@Param('id') id: string) {
    const reviews = await this.productsService.getReviews(id);
    return ResponseBuilder.success(
      reviews,
      'Reviews retrieved',
      'تم استرجاع التقييمات',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id/reviews/:reviewId')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update my review',
    description: 'Update your own review. Only the review owner can update.',
  })
  @ApiParam({ name: 'id', description: 'Product ID' })
  @ApiParam({ name: 'reviewId', description: 'Review ID' })
  @ApiResponse({
    status: 200,
    description: 'Review updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateReview(
    @Param('id') id: string,
    @Param('reviewId') reviewId: string,
    @CurrentUser() user: any,
    @Body() updateReviewDto: AddReviewDto,
  ) {
    const review = await this.productsService.updateReview(
      id,
      reviewId,
      user.customerId,
      updateReviewDto,
    );
    return ResponseBuilder.success(
      review,
      'Review updated',
      'تم تحديث التقييم',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put(':id/reviews/:reviewId/approve')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Approve product review',
    description: 'Approve a pending review. Admin only.',
  })
  @ApiParam({ name: 'id', description: 'Product ID' })
  @ApiParam({ name: 'reviewId', description: 'Review ID' })
  @ApiResponse({
    status: 200,
    description: 'Review approved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async approveReview(
    @Param('id') id: string,
    @Param('reviewId') reviewId: string,
    @CurrentUser() user: any,
  ) {
    const review = await this.productsService.approveReview(
      id,
      reviewId,
      user.adminId ?? user.id,
    );
    return ResponseBuilder.success(
      review,
      'Review approved',
      'تم اعتماد التقييم',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Delete(':id/reviews/:reviewId')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Delete product review',
    description: 'Delete a review. Admin only.',
  })
  @ApiParam({ name: 'id', description: 'Product ID' })
  @ApiParam({ name: 'reviewId', description: 'Review ID' })
  @ApiResponse({
    status: 200,
    description: 'Review deleted successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async deleteReview(
    @Param('id') id: string,
    @Param('reviewId') reviewId: string,
  ) {
    await this.productsService.deleteReview(id, reviewId);
    return ResponseBuilder.success(
      null,
      'Review deleted',
      'تم حذف التقييم',
    );
  }

  // ═════════════════════════════════════
  // Admin Endpoints - Price Levels
  // ═════════════════════════════════════

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('price-levels/all')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get all price levels (admin)',
    description:
      'Retrieve all price levels including inactive ones. Admin only.',
  })
  @ApiResponse({
    status: 200,
    description: 'Price levels retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getAllPriceLevels() {
    const priceLevels = await this.productsService.findAllPriceLevelsAdmin();
    return ResponseBuilder.success(
      priceLevels,
      'Price levels retrieved',
      'تم استرجاع مستويات الأسعار',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('price-levels/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get price level by ID',
    description: 'Retrieve a single price level by ID. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Price level ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Price level retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getPriceLevelById(@Param('id') id: string) {
    const priceLevel = await this.productsService.findPriceLevelById(id);
    return ResponseBuilder.success(
      priceLevel,
      'Price level retrieved',
      'تم استرجاع مستوى السعر',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('price-levels')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create price level',
    description: 'Create a new price level. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Price level created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createPriceLevel(@Body() createDto: CreatePriceLevelDto) {
    const priceLevel = await this.productsService.createPriceLevel(createDto);
    return ResponseBuilder.created(
      priceLevel,
      'Price level created',
      'تم إنشاء مستوى السعر',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('price-levels/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update price level',
    description: 'Update price level information. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Price level ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Price level updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updatePriceLevel(
    @Param('id') id: string,
    @Body() updateDto: UpdatePriceLevelDto,
  ) {
    const priceLevel = await this.productsService.updatePriceLevel(
      id,
      updateDto,
    );
    return ResponseBuilder.success(
      priceLevel,
      'Price level updated',
      'تم تحديث مستوى السعر',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Delete('price-levels/:id')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete price level',
    description:
      'Delete a price level. Cannot delete if used in customers or products. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Price level ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 204,
    description: 'Price level deleted successfully',
  })
  @ApiCommonErrorResponses()
  async deletePriceLevel(@Param('id') id: string) {
    await this.productsService.deletePriceLevel(id);
    return ResponseBuilder.success(
      null,
      'Price level deleted',
      'تم حذف مستوى السعر',
    );
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
  async create(
    @Body() createProductDto: CreateProductDto,
    @CurrentUser() user: any,
  ) {
    const product = await this.productsService.create(createProductDto);

    await this.auditService
      .log({
        action: AuditAction.CREATE,
        resource: AuditResource.PRODUCT,
        resourceId: product._id.toString(),
        resourceName: product.name ?? product.nameAr ?? undefined,
        actorType: 'admin',
        actorId: user?.adminUserId ?? user?.id,
        actorName: user?.fullName ?? undefined,
        actorEmail: user?.email ?? undefined,
        description: `Product created: ${product.name ?? product._id.toString()}`,
        descriptionAr: 'تم إنشاء المنتج',
        severity: 'info',
        success: true,
      })
      .catch(() => undefined);

    return ResponseBuilder.created(
      product,
      'Product created',
      'تم إنشاء المنتج',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put(':id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update product',
    description: 'Update product information. All fields are optional.',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Product updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async update(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
    @CurrentUser() user: any,
  ) {
    const product = await this.productsService.update(id, updateProductDto);

    await this.auditService
      .log({
        action: AuditAction.UPDATE,
        resource: AuditResource.PRODUCT,
        resourceId: product._id.toString(),
        resourceName: product.name ?? product.nameAr ?? undefined,
        actorType: 'admin',
        actorId: user?.adminUserId ?? user?.id,
        actorName: user?.fullName ?? undefined,
        actorEmail: user?.email ?? undefined,
        description: `Product updated: ${product.name ?? product._id.toString()}`,
        descriptionAr: 'تم تحديث المنتج',
        severity: 'info',
        success: true,
      })
      .catch(() => undefined);

    return ResponseBuilder.success(
      product,
      'Product updated',
      'تم تحديث المنتج',
    );
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
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 204,
    description: 'Product deleted successfully',
  })
  @ApiCommonErrorResponses()
  async delete(@Param('id') id: string, @CurrentUser() user: any) {
    await this.productsService.delete(id);
    await this.auditService
      .log({
        action: AuditAction.DELETE,
        resource: AuditResource.PRODUCT,
        resourceId: id,
        resourceName: undefined,
        actorType: 'admin',
        actorId: user?.adminUserId ?? user?.id,
        actorName: user?.fullName ?? undefined,
        actorEmail: user?.email ?? undefined,
        description: `Product deleted: ${id}`,
        descriptionAr: 'تم حذف المنتج',
        severity: 'warning',
        success: true,
      })
      .catch(() => undefined);
    return ResponseBuilder.success(null, 'Product deleted', 'تم حذف المنتج');
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get(':id/prices')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get product prices for all price levels',
    description: 'Retrieve all price level prices for a product',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Product prices retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getPrices(@Param('id') id: string) {
    const prices = await this.productsService.getPrices(id);
    return ResponseBuilder.success(
      prices,
      'Prices retrieved',
      'تم استرجاع الأسعار',
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/prices')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Set product prices for all price levels',
    description:
      'Set prices for a product across different price levels (e.g., retail, wholesale)',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
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
  @Get('favorite/my')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Get my favorites' })
  async getFavorites(@CurrentUser() user: any) {
    const favorites = await this.productsService.getFavorites(user.customerId);
    return ResponseBuilder.success(
      favorites,
      'Favorites retrieved',
      'تم استرجاع المفضلة',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id/favorite/check')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Check if product is in favorites' })
  @ApiParam({ name: 'id', description: 'Product ID' })
  async checkFavorite(
    @Param('id') id: string,
    @CurrentUser() user: any,
  ) {
    const isFavorite = await this.productsService.isFavorite(
      user.customerId,
      id,
    );
    return ResponseBuilder.success(
      { isFavorite },
      'Favorite status checked',
      'تم التحقق من حالة المفضلة',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/favorite')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Add to favorites' })
  async addToFavorites(@Param('id') id: string, @CurrentUser() user: any) {
    await this.productsService.addToFavorites(user.customerId, id);
    return ResponseBuilder.success(
      null,
      'Added to favorites',
      'تم الإضافة للمفضلة',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id/favorite')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Remove from favorites' })
  async removeFromFavorites(@Param('id') id: string, @CurrentUser() user: any) {
    await this.productsService.removeFromFavorites(user.customerId, id);
    return ResponseBuilder.success(
      null,
      'Removed from favorites',
      'تم الإزالة من المفضلة',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/reviews')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Add product review',
    description:
      'Add a review and rating for a product. One review per product per customer.',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
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

  // ═════════════════════════════════════
  // Admin - Device Compatibility
  // ═════════════════════════════════════

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/devices')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Add device compatibility',
    description: 'Link devices to product for compatibility. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Device compatibility added successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async addDeviceCompatibility(
    @Param('id') id: string,
    @Body() addDeviceCompatibilityDto: AddDeviceCompatibilityDto,
  ) {
    const result = await this.productsService.addDeviceCompatibility(
      id,
      addDeviceCompatibilityDto.deviceIds,
      addDeviceCompatibilityDto.compatibilityNotes,
      addDeviceCompatibilityDto.isVerified,
    );
    return ResponseBuilder.success(
      result,
      'Device compatibility added',
      'تم إضافة توافق الأجهزة',
    );
  }

  // ═════════════════════════════════════
  // Admin - Tags
  // ═════════════════════════════════════

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/tags')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Add tags to product',
    description: 'Associate tags with a product. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Tags added successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async addTags(@Param('id') id: string, @Body('tagIds') tagIds: string[]) {
    await this.productsService.addTags(id, tagIds);
    return ResponseBuilder.success(null, 'Tags added', 'تم إضافة الوسوم');
  }

  // ═════════════════════════════════════
  // Stock Alerts (Customer)
  // ═════════════════════════════════════

  @UseGuards(JwtAuthGuard)
  @Get('stock-alerts')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get my stock alerts',
    description: 'Retrieve all stock alerts for the current customer',
  })
  @ApiResponse({
    status: 200,
    description: 'Stock alerts retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getStockAlerts(@CurrentUser() user: any) {
    const alerts = await this.productsService.getStockAlerts(user.customerId);
    return ResponseBuilder.success(
      alerts,
      'Stock alerts retrieved',
      'تم استرجاع تنبيهات المخزون',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Post('stock-alerts')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create stock alert',
    description:
      'Create a stock alert for a product (back in stock, low stock, or price drop)',
  })
  @ApiResponse({
    status: 201,
    description: 'Stock alert created successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async createStockAlert(
    @CurrentUser() user: any,
    @Body() createStockAlertDto: CreateStockAlertDto,
  ) {
    const alert = await this.productsService.createStockAlert(
      user.customerId,
      createStockAlertDto.productId,
      createStockAlertDto.alertType,
      createStockAlertDto.targetPrice,
    );
    return ResponseBuilder.created(
      alert,
      'Stock alert created',
      'تم إنشاء تنبيه المخزون',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Put('stock-alerts/:id')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update stock alert',
    description: 'Enable or disable a stock alert',
  })
  @ApiParam({
    name: 'id',
    description: 'Stock Alert ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Stock alert updated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async updateStockAlert(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body('isActive') isActive: boolean,
  ) {
    const alert = await this.productsService.updateStockAlert(
      user.customerId,
      id,
      isActive,
    );
    return ResponseBuilder.success(
      alert,
      'Stock alert updated',
      'تم تحديث تنبيه المخزون',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Delete('stock-alerts/:id')
  @ApiBearerAuth('JWT-auth')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete stock alert',
    description: 'Delete a stock alert',
  })
  @ApiParam({
    name: 'id',
    description: 'Stock Alert ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Stock alert deleted successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async deleteStockAlert(@CurrentUser() user: any, @Param('id') id: string) {
    await this.productsService.deleteStockAlert(user.customerId, id);
    return ResponseBuilder.success(
      null,
      'Stock alert deleted',
      'تم حذف تنبيه المخزون',
    );
  }
}
