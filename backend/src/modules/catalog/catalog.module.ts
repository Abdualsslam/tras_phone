import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Brand, BrandSchema } from './schemas/brand.schema';
import { Category, CategorySchema } from './schemas/category.schema';
import { Device, DeviceSchema } from './schemas/device.schema';
import { QualityType, QualityTypeSchema } from './schemas/quality-type.schema';
import { Product, ProductSchema } from '@modules/products/schemas/product.schema';
import { CatalogService } from './catalog.service';
import { CategoriesService } from './categories.service';
import { CatalogController } from './catalog.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Brand.name, schema: BrandSchema },
            { name: Category.name, schema: CategorySchema },
            { name: Device.name, schema: DeviceSchema },
            { name: QualityType.name, schema: QualityTypeSchema },
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
    ],
    controllers: [CatalogController],
    providers: [CatalogService, CategoriesService],
    exports: [CatalogService, CategoriesService],
})
export class CatalogModule implements OnModuleInit {
    constructor(private catalogService: CatalogService) { }

    async onModuleInit() {
        await this.catalogService.seedCatalogData();
    }
}
