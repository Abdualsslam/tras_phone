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
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { EducationalService } from './educational.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '../../common/enums/user-role.enum';
import {
  CreateEducationalCategoryDto,
  UpdateEducationalCategoryDto,
} from './dto/create-educational-category.dto';
import {
  CreateEducationalContentDto,
  UpdateEducationalContentDto,
} from './dto/create-educational-content.dto';
import { ContentType } from './schemas/educational-content.schema';
import { Types } from 'mongoose';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📚 Educational Content Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Educational Content')
@Controller('educational')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class EducationalController {
  constructor(private readonly educationalService: EducationalService) {}

  // ═════════════════════════════════════
  // Public - Categories
  // ═════════════════════════════════════

  @Get('categories')
  @Public()
  @ApiOperation({ summary: 'Get educational categories' })
  async getCategories() {
    const categories = await this.educationalService.getCategories();
    return ResponseBuilder.success(categories);
  }

  @Get('categories/:slug')
  @Public()
  @ApiOperation({ summary: 'Get category by slug' })
  async getCategoryBySlug(@Param('slug') slug: string) {
    const category = await this.educationalService.getCategoryBySlug(slug);
    return ResponseBuilder.success(category);
  }

  // ═════════════════════════════════════
  // Public - Content
  // ═════════════════════════════════════

  @Get('content')
  @Public()
  @ApiOperation({ summary: 'Get educational content' })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'type', required: false, enum: ContentType })
  @ApiQuery({ name: 'featured', required: false, type: Boolean })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getContent(
    @Query('categoryId') categoryId?: string,
    @Query('type') type?: ContentType,
    @Query('featured') featured?: boolean,
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const result = await this.educationalService.getContent({
      categoryId,
      type,
      featured,
      search,
      page: page || 1,
      limit: limit || 20,
    });
    return ResponseBuilder.paginated(
      result.data,
      result.total,
      page || 1,
      limit || 20,
    );
  }

  @Get('content/featured')
  @Public()
  @ApiOperation({ summary: 'Get featured content' })
  async getFeaturedContent(@Query('limit') limit?: number) {
    const content = await this.educationalService.getFeaturedContent(
      limit || 6,
    );
    return ResponseBuilder.success(content);
  }

  @Get('content/category/:slug')
  @Public()
  @ApiOperation({ summary: 'Get content by category' })
  async getContentByCategory(
    @Param('slug') slug: string,
    @Query('limit') limit?: number,
  ) {
    const content = await this.educationalService.getContentByCategory(
      slug,
      limit || 20,
    );
    return ResponseBuilder.success(content);
  }

  @Get('content/:slug')
  @Public()
  @ApiOperation({ summary: 'Get content by slug' })
  async getContentBySlug(@Param('slug') slug: string) {
    const content = await this.educationalService.getContentBySlug(slug);
    return ResponseBuilder.success(content);
  }

  @Post('content/:id/like')
  @Public()
  @ApiOperation({ summary: 'Like content' })
  async likeContent(@Param('id') id: string) {
    await this.educationalService.likeContent(id);
    return ResponseBuilder.success(null, 'Content liked');
  }

  @Post('content/:id/share')
  @Public()
  @ApiOperation({ summary: 'Track content share' })
  async shareContent(@Param('id') id: string) {
    await this.educationalService.shareContent(id);
    return ResponseBuilder.success(null, 'Share tracked');
  }

  // ═════════════════════════════════════
  // Admin - Categories
  // ═════════════════════════════════════

  @Get('admin/categories')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all categories (admin)' })
  async getAdminCategories() {
    const categories = await this.educationalService.getCategories(false);
    return ResponseBuilder.success(categories);
  }

  @Post('admin/categories')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create category' })
  async createCategory(@Body() data: CreateEducationalCategoryDto) {
    const categoryData = {
      ...data,
      parentId: data.parentId ? new Types.ObjectId(data.parentId) : undefined,
    };
    const category = await this.educationalService.createCategory(categoryData);
    return ResponseBuilder.success(category, 'Category created');
  }

  @Put('admin/categories/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update category' })
  async updateCategory(
    @Param('id') id: string,
    @Body() data: UpdateEducationalCategoryDto,
  ) {
    const category = await this.educationalService.updateCategory(id, data);
    return ResponseBuilder.success(category, 'Category updated');
  }

  @Delete('admin/categories/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete category' })
  async deleteCategory(@Param('id') id: string) {
    await this.educationalService.deleteCategory(id);
    return ResponseBuilder.success(null, 'Category deleted');
  }

  // ═════════════════════════════════════
  // Admin - Content
  // ═════════════════════════════════════

  @Get('admin/content')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all content (admin)' })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'type', required: false, enum: ContentType })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getAdminContent(
    @Query('categoryId') categoryId?: string,
    @Query('type') type?: ContentType,
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const result = await this.educationalService.getContent({
      categoryId,
      type,
      status,
      page: page || 1,
      limit: limit || 20,
    });
    return ResponseBuilder.paginated(
      result.data,
      result.total,
      page || 1,
      limit || 20,
    );
  }

  @Get('admin/content/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get content by ID (admin)' })
  async getContentById(@Param('id') id: string) {
    const content = await this.educationalService.getContentById(id);
    return ResponseBuilder.success(content);
  }

  @Post('admin/content')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create content' })
  async createContent(
    @CurrentUser() user: any,
    @Body() data: CreateEducationalContentDto,
  ) {
    const contentData = {
      ...data,
      categoryId: new Types.ObjectId(data.categoryId),
      relatedProducts: data.relatedProducts
        ? data.relatedProducts.map((id) => new Types.ObjectId(id))
        : undefined,
      relatedContent: data.relatedContent
        ? data.relatedContent.map((id) => new Types.ObjectId(id))
        : undefined,
    };
    const content = await this.educationalService.createContent(
      contentData,
      user.adminId,
    );
    return ResponseBuilder.success(content, 'Content created');
  }

  @Put('admin/content/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update content' })
  async updateContent(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() data: UpdateEducationalContentDto,
  ) {
    const contentData: any = {
      ...data,
    };
    if (data.categoryId) {
      contentData.categoryId = new Types.ObjectId(data.categoryId);
    }
    if (data.relatedProducts) {
      contentData.relatedProducts = data.relatedProducts.map(
        (id) => new Types.ObjectId(id),
      );
    }
    if (data.relatedContent) {
      contentData.relatedContent = data.relatedContent.map(
        (id) => new Types.ObjectId(id),
      );
    }
    const content = await this.educationalService.updateContent(
      id,
      contentData,
      user.adminId,
    );
    return ResponseBuilder.success(content, 'Content updated');
  }

  @Put('admin/content/:id/publish')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Publish content' })
  async publishContent(@CurrentUser() user: any, @Param('id') id: string) {
    const content = await this.educationalService.updateContent(
      id,
      { status: 'published' },
      user.adminId,
    );
    return ResponseBuilder.success(content, 'Content published');
  }

  @Delete('admin/content/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete content' })
  async deleteContent(@Param('id') id: string) {
    await this.educationalService.deleteContent(id);
    return ResponseBuilder.success(null, 'Content deleted');
  }
}
