import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { ContentService } from './content.service';
import { Public } from '../../common/decorators/public.decorator';
import { BannerPosition } from './schemas/banner.schema';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * Banners Controller - Public endpoint for mobile app
 * Route: /banners
 */
@ApiTags('Banners')
@Controller('banners')
export class BannersController {
  constructor(private readonly contentService: ContentService) {}

  @Get()
  @Public()
  @ApiOperation({ summary: 'Get banners by placement' })
  @ApiQuery({ name: 'placement', required: false, enum: BannerPosition })
  async getBanners(@Query('placement') placement?: BannerPosition) {
    const position = placement || BannerPosition.HOME_TOP;
    const banners = await this.contentService.findActiveBanners(position);
    return ResponseBuilder.success(banners, 'Banners retrieved');
  }
}
