import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FaqCategory, FaqCategorySchema } from './schemas/faq-category.schema';
import { Faq, FaqSchema } from './schemas/faq.schema';
import { Page, PageSchema } from './schemas/page.schema';
import { Banner, BannerSchema } from './schemas/banner.schema';
import { Slider, SliderSchema } from './schemas/slider.schema';
import { Testimonial, TestimonialSchema } from './schemas/testimonial.schema';
import {
  EducationalCategory,
  EducationalCategorySchema,
} from './schemas/educational-category.schema';
import {
  EducationalContent,
  EducationalContentSchema,
} from './schemas/educational-content.schema';
import { ContentService } from './content.service';
import { EducationalService } from './educational.service';
import { ContentController } from './content.controller';
import { EducationalController } from './educational.controller';
import { BannersController } from './banners.controller';
import { AuthModule } from '@modules/auth/auth.module';
import { Product, ProductSchema } from '@modules/products/schemas/product.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: FaqCategory.name, schema: FaqCategorySchema },
      { name: Faq.name, schema: FaqSchema },
      { name: Page.name, schema: PageSchema },
      { name: Banner.name, schema: BannerSchema },
      { name: Slider.name, schema: SliderSchema },
      { name: Testimonial.name, schema: TestimonialSchema },
      { name: EducationalCategory.name, schema: EducationalCategorySchema },
      { name: EducationalContent.name, schema: EducationalContentSchema },
      { name: Product.name, schema: ProductSchema },
    ]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRATION', '15m'),
        },
      }),
      inject: [ConfigService],
    }),
    AuthModule,
  ],
  controllers: [ContentController, EducationalController, BannersController],
  providers: [ContentService, EducationalService],
  exports: [ContentService, EducationalService],
})
export class ContentModule implements OnModuleInit {
  constructor(
    private readonly contentService: ContentService,
    private readonly educationalService: EducationalService,
  ) {}

  async onModuleInit() {
    await this.contentService.seedDefaultContent();
    await this.educationalService.seedDefaultCategories();
  }
}
