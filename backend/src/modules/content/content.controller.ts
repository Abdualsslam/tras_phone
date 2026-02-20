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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ContentService } from './content.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { BannerPosition, BannerType } from './schemas/banner.schema';
import { PageStatus } from './schemas/page.schema';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { UserRole } from '@/common/enums/user-role.enum';

@ApiTags('Content')
@Controller('content')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  // ==================== FAQ - Public ====================

  @Get('faqs/categories')
  @Public()
  @ApiOperation({ summary: 'Get FAQ categories' })
  async getFaqCategories() {
    const categories = await this.contentService.findAllFaqCategories();
    return ResponseBuilder.success(categories);
  }

  @Get('faqs/category/:slug')
  @Public()
  @ApiOperation({ summary: 'Get FAQs by category' })
  async getFaqsByCategory(@Param('slug') slug: string) {
    const faqs = await this.contentService.findFaqsByCategory(slug);
    return ResponseBuilder.success(faqs);
  }

  @Get('faqs')
  @Public()
  @ApiOperation({ summary: 'Get all FAQs' })
  async getAllFaqs() {
    const faqs = await this.contentService.findAllFaqs();
    return ResponseBuilder.success(faqs);
  }

  @Get('faqs/search')
  @Public()
  @ApiOperation({ summary: 'Search FAQs' })
  async searchFaqs(@Query('q') query: string) {
    const faqs = await this.contentService.searchFaqs(query);
    return ResponseBuilder.success(faqs);
  }

  @Post('faqs/:id/view')
  @Public()
  @ApiOperation({ summary: 'Record FAQ view' })
  async recordFaqView(@Param('id') id: string) {
    await this.contentService.incrementFaqView(id);
    return ResponseBuilder.success(null);
  }

  @Post('faqs/:id/helpful')
  @Public()
  @ApiOperation({ summary: 'Mark FAQ as helpful/not helpful' })
  async markFaqHelpful(
    @Param('id') id: string,
    @Body() data: { helpful: boolean },
  ) {
    await this.contentService.markFaqHelpful(id, data.helpful);
    return ResponseBuilder.success(null, 'Feedback recorded');
  }

  // ==================== Pages - Public ====================

  @Get('pages/footer')
  @Public()
  @ApiOperation({ summary: 'Get footer pages' })
  async getFooterPages() {
    const pages = await this.contentService.findFooterPages();
    return ResponseBuilder.success(pages);
  }

  @Get('pages/header')
  @Public()
  @ApiOperation({ summary: 'Get header pages' })
  async getHeaderPages() {
    const pages = await this.contentService.findHeaderPages();
    return ResponseBuilder.success(pages);
  }

  @Get('pages/:slug')
  @Public()
  @ApiOperation({ summary: 'Get page by slug' })
  async getPage(@Param('slug') slug: string) {
    const page = await this.contentService.findPageBySlug(slug);
    return ResponseBuilder.success(page);
  }

  // ==================== Banners - Public ====================

  @Get('banners/:position')
  @Public()
  @ApiOperation({ summary: 'Get banners by position' })
  async getBannersByPosition(@Param('position') position: BannerPosition) {
    const banners = await this.contentService.findActiveBanners(position);
    return ResponseBuilder.success(banners);
  }

  @Post('banners/:id/impression')
  @Public()
  @ApiOperation({ summary: 'Record banner impression' })
  async recordImpression(@Param('id') id: string) {
    await this.contentService.recordBannerImpression(id);
    return ResponseBuilder.success(null);
  }

  @Post('banners/:id/click')
  @Public()
  @ApiOperation({ summary: 'Record banner click' })
  async recordClick(@Param('id') id: string) {
    await this.contentService.recordBannerClick(id);
    return ResponseBuilder.success(null);
  }

  // ==================== Sliders - Public ====================

  @Get('sliders/:slug')
  @Public()
  @ApiOperation({ summary: 'Get slider by slug' })
  async getSlider(@Param('slug') slug: string) {
    const slider = await this.contentService.findSliderBySlug(slug);
    return ResponseBuilder.success(slider);
  }

  @Get('sliders/location/:location')
  @Public()
  @ApiOperation({ summary: 'Get sliders by location' })
  async getSlidersByLocation(@Param('location') location: string) {
    const sliders = await this.contentService.findSlidersByLocation(location);
    return ResponseBuilder.success(sliders);
  }

  // ==================== Testimonials - Public ====================

  @Get('testimonials')
  @Public()
  @ApiOperation({ summary: 'Get active testimonials' })
  async getTestimonials(@Query('limit') limit?: number) {
    const testimonials =
      await this.contentService.findActiveTestimonials(limit);
    return ResponseBuilder.success(testimonials);
  }

  @Get('testimonials/featured')
  @Public()
  @ApiOperation({ summary: 'Get featured testimonials' })
  async getFeaturedTestimonials() {
    const testimonials = await this.contentService.findFeaturedTestimonials();
    return ResponseBuilder.success(testimonials);
  }

  // ==================== Admin - FAQs ====================

  @Post('admin/faq-categories')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create FAQ category' })
  async createFaqCategory(@Body() data: any) {
    const category = await this.contentService.createFaqCategory(data);
    return ResponseBuilder.success(category, 'Category created');
  }

  @Put('admin/faq-categories/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update FAQ category' })
  async updateFaqCategory(@Param('id') id: string, @Body() data: any) {
    const category = await this.contentService.updateFaqCategory(id, data);
    return ResponseBuilder.success(category, 'Category updated');
  }

  @Post('admin/faqs')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create FAQ' })
  async createFaq(@CurrentUser() user: any, @Body() data: any) {
    const faq = await this.contentService.createFaq(data, user.adminId);
    return ResponseBuilder.success(faq, 'FAQ created');
  }

  @Put('admin/faqs/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update FAQ' })
  async updateFaq(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() data: any,
  ) {
    const faq = await this.contentService.updateFaq(id, data, user.adminId);
    return ResponseBuilder.success(faq, 'FAQ updated');
  }

  // ==================== Admin - Pages ====================

  @Get('admin/pages')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all pages (admin)' })
  async getAllPages(@Query('status') status?: PageStatus) {
    const pages = await this.contentService.findAllPages(status);
    return ResponseBuilder.success(pages);
  }

  @Post('admin/pages')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create page' })
  async createPage(@CurrentUser() user: any, @Body() data: any) {
    const page = await this.contentService.createPage(data, user.adminId);
    return ResponseBuilder.success(page, 'Page created');
  }

  @Put('admin/pages/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update page' })
  async updatePage(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() data: any,
  ) {
    const page = await this.contentService.updatePage(id, data, user.adminId);
    return ResponseBuilder.success(page, 'Page updated');
  }

  @Delete('admin/pages/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete page' })
  async deletePage(@Param('id') id: string) {
    await this.contentService.deletePage(id);
    return ResponseBuilder.success(null, 'Page deleted');
  }

  // ==================== Admin - Banners ====================

  @Get('admin/banners')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all banners (admin)' })
  async getAllBanners(@Query('type') type?: BannerType) {
    const banners = await this.contentService.findAllBanners(type);
    return ResponseBuilder.success(banners);
  }

  @Post('admin/banners')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create banner' })
  async createBanner(@CurrentUser() user: any, @Body() data: any) {
    const banner = await this.contentService.createBanner(data, user.adminId);
    return ResponseBuilder.success(banner, 'Banner created');
  }

  @Put('admin/banners/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update banner' })
  async updateBanner(@Param('id') id: string, @Body() data: any) {
    const banner = await this.contentService.updateBanner(id, data);
    return ResponseBuilder.success(banner, 'Banner updated');
  }

  @Delete('admin/banners/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete banner' })
  async deleteBanner(@Param('id') id: string) {
    await this.contentService.deleteBanner(id);
    return ResponseBuilder.success(null, 'Banner deleted');
  }

  // ==================== Admin - Sliders ====================

  @Get('admin/sliders')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all sliders (admin)' })
  async getAllSliders() {
    const sliders = await this.contentService.findAllSliders();
    return ResponseBuilder.success(sliders);
  }

  @Post('admin/sliders')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create slider' })
  async createSlider(@CurrentUser() user: any, @Body() data: any) {
    const slider = await this.contentService.createSlider(data, user.adminId);
    return ResponseBuilder.success(slider, 'Slider created');
  }

  @Put('admin/sliders/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update slider' })
  async updateSlider(@Param('id') id: string, @Body() data: any) {
    const slider = await this.contentService.updateSlider(id, data);
    return ResponseBuilder.success(slider, 'Slider updated');
  }

  @Post('admin/sliders/:id/slides')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Add slide to slider' })
  async addSlide(@Param('id') id: string, @Body() data: any) {
    const slider = await this.contentService.addSlide(id, data);
    return ResponseBuilder.success(slider, 'Slide added');
  }

  @Put('admin/sliders/:id/slides/:index')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update slide' })
  async updateSlide(
    @Param('id') id: string,
    @Param('index') index: number,
    @Body() data: any,
  ) {
    const slider = await this.contentService.updateSlide(id, index, data);
    return ResponseBuilder.success(slider, 'Slide updated');
  }

  @Delete('admin/sliders/:id/slides/:index')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Remove slide' })
  async removeSlide(@Param('id') id: string, @Param('index') index: number) {
    const slider = await this.contentService.removeSlide(id, index);
    return ResponseBuilder.success(slider, 'Slide removed');
  }

  @Delete('admin/sliders/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete slider' })
  async deleteSlider(@Param('id') id: string) {
    await this.contentService.deleteSlider(id);
    return ResponseBuilder.success(null, 'Slider deleted');
  }

  // ==================== Admin - Testimonials ====================

  @Get('admin/testimonials')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all testimonials (admin)' })
  async getAllTestimonials() {
    const testimonials = await this.contentService.findAllTestimonials();
    return ResponseBuilder.success(testimonials);
  }

  @Post('admin/testimonials')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create testimonial' })
  async createTestimonial(@Body() data: any) {
    const testimonial = await this.contentService.createTestimonial(data);
    return ResponseBuilder.success(testimonial, 'Testimonial created');
  }

  @Put('admin/testimonials/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update testimonial' })
  async updateTestimonial(@Param('id') id: string, @Body() data: any) {
    const testimonial = await this.contentService.updateTestimonial(id, data);
    return ResponseBuilder.success(testimonial, 'Testimonial updated');
  }

  @Put('admin/testimonials/:id/approve')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Approve testimonial' })
  async approveTestimonial(@CurrentUser() user: any, @Param('id') id: string) {
    const testimonial = await this.contentService.approveTestimonial(
      id,
      user.adminId,
    );
    return ResponseBuilder.success(testimonial, 'Testimonial approved');
  }

  @Delete('admin/testimonials/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete testimonial' })
  async deleteTestimonial(@Param('id') id: string) {
    await this.contentService.deleteTestimonial(id);
    return ResponseBuilder.success(null, 'Testimonial deleted');
  }
}
