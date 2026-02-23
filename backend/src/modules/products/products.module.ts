import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Product, ProductSchema } from './schemas/product.schema';
import {
  ProductPrice,
  ProductPriceSchema,
} from './schemas/product-price.schema';
import {
  ProductReview,
  ProductReviewSchema,
} from './schemas/product-review.schema';
import { Favorite, FavoriteSchema } from './schemas/favorite.schema';
import { PriceLevel, PriceLevelSchema } from './schemas/price-level.schema';
import {
  ProductDeviceCompatibility,
  ProductDeviceCompatibilitySchema,
} from './schemas/product-device-compatibility.schema';
import { Tag, TagSchema } from './schemas/tag.schema';
import { ProductTag, ProductTagSchema } from './schemas/product-tag.schema';
import { StockAlert, StockAlertSchema } from './schemas/stock-alert.schema';
import { Brand, BrandSchema } from '@modules/catalog/schemas/brand.schema';
import {
  Category,
  CategorySchema,
} from '@modules/catalog/schemas/category.schema';
import {
  QualityType,
  QualityTypeSchema,
} from '@modules/catalog/schemas/quality-type.schema';
import { Device, DeviceSchema } from '@modules/catalog/schemas/device.schema';
import { Customer, CustomerSchema } from '@modules/customers/schemas/customer.schema';
import {
  ProductStock,
  ProductStockSchema,
} from '@modules/inventory/schemas/product-stock.schema';
import {
  Warehouse,
  WarehouseSchema,
} from '@modules/inventory/schemas/warehouse.schema';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { ProductsSearchService } from './products-search.service';
import { ProductsSearchSuggestionsService } from './products-search-suggestions.service';
import { AuthModule } from '@modules/auth/auth.module';
import { CustomersModule } from '@modules/customers/customers.module';
import { ContentModule } from '@modules/content/content.module';
import { ProductsImportExportController } from './import-export/products-import-export.controller';
import { ProductsImportExportService } from './import-export/products-import-export.service';
import { ReferenceResolver } from './import-export/utils/reference-resolver';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Product.name, schema: ProductSchema },
      { name: ProductPrice.name, schema: ProductPriceSchema },
      { name: ProductReview.name, schema: ProductReviewSchema },
      { name: Favorite.name, schema: FavoriteSchema },
      { name: PriceLevel.name, schema: PriceLevelSchema },
      {
        name: ProductDeviceCompatibility.name,
        schema: ProductDeviceCompatibilitySchema,
      },
      { name: Tag.name, schema: TagSchema },
      { name: ProductTag.name, schema: ProductTagSchema },
      { name: StockAlert.name, schema: StockAlertSchema },
      { name: Brand.name, schema: BrandSchema },
      { name: Category.name, schema: CategorySchema },
      { name: QualityType.name, schema: QualityTypeSchema },
      { name: Device.name, schema: DeviceSchema },
      { name: Customer.name, schema: CustomerSchema },
      { name: ProductStock.name, schema: ProductStockSchema },
      { name: Warehouse.name, schema: WarehouseSchema },
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
    forwardRef(() => CustomersModule),
    ContentModule,
  ],
  controllers: [ProductsController, ProductsImportExportController],
  providers: [
    ProductsService,
    ProductsSearchService,
    ProductsSearchSuggestionsService,
    ProductsImportExportService,
    ReferenceResolver,
  ],
  exports: [
    ProductsService,
    ProductsSearchService,
    ProductsSearchSuggestionsService,
  ],
})
export class ProductsModule {}
