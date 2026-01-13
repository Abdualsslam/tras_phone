import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Promotion, PromotionSchema } from './schemas/promotion.schema';
import { PromotionProduct, PromotionProductSchema } from './schemas/promotion-product.schema';
import { PromotionCategory, PromotionCategorySchema } from './schemas/promotion-category.schema';
import { PromotionBrand, PromotionBrandSchema } from './schemas/promotion-brand.schema';
import { PromotionUsage, PromotionUsageSchema } from './schemas/promotion-usage.schema';
import { Coupon, CouponSchema } from './schemas/coupon.schema';
import { CouponUsage, CouponUsageSchema } from './schemas/coupon-usage.schema';
import { PromotionsService } from './promotions.service';
import { CouponsService } from './coupons.service';
import { PromotionsController } from './promotions.controller';
import { AuthModule } from '@modules/auth/auth.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Promotion.name, schema: PromotionSchema },
            { name: PromotionProduct.name, schema: PromotionProductSchema },
            { name: PromotionCategory.name, schema: PromotionCategorySchema },
            { name: PromotionBrand.name, schema: PromotionBrandSchema },
            { name: PromotionUsage.name, schema: PromotionUsageSchema },
            { name: Coupon.name, schema: CouponSchema },
            { name: CouponUsage.name, schema: CouponUsageSchema },
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
    controllers: [PromotionsController],
    providers: [PromotionsService, CouponsService],
    exports: [PromotionsService, CouponsService],
})
export class PromotionsModule { }
