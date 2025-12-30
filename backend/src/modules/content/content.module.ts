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
import { ContentService } from './content.service';
import { ContentController } from './content.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: FaqCategory.name, schema: FaqCategorySchema },
            { name: Faq.name, schema: FaqSchema },
            { name: Page.name, schema: PageSchema },
            { name: Banner.name, schema: BannerSchema },
            { name: Slider.name, schema: SliderSchema },
            { name: Testimonial.name, schema: TestimonialSchema },
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
    ],
    controllers: [ContentController],
    providers: [ContentService],
    exports: [ContentService],
})
export class ContentModule implements OnModuleInit {
    constructor(private readonly contentService: ContentService) { }

    async onModuleInit() {
        await this.contentService.seedDefaultContent();
    }
}
