import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Product, ProductSchema } from '../schemas/product.schema';
import {
  ProductDeviceCompatibility,
  ProductDeviceCompatibilitySchema,
} from '../schemas/product-device-compatibility.schema';
import { Brand, BrandSchema } from '@modules/catalog/schemas/brand.schema';
import { Category, CategorySchema } from '@modules/catalog/schemas/category.schema';
import {
  QualityType,
  QualityTypeSchema,
} from '@modules/catalog/schemas/quality-type.schema';
import { Device, DeviceSchema } from '@modules/catalog/schemas/device.schema';
import { ProductsImportExportController } from './products-import-export.controller';
import { ProductsImportExportService } from './products-import-export.service';
import { ReferenceResolver } from './utils/reference-resolver';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Product.name, schema: ProductSchema },
      {
        name: ProductDeviceCompatibility.name,
        schema: ProductDeviceCompatibilitySchema,
      },
      { name: Brand.name, schema: BrandSchema },
      { name: Category.name, schema: CategorySchema },
      { name: QualityType.name, schema: QualityTypeSchema },
      { name: Device.name, schema: DeviceSchema },
    ]),
  ],
  controllers: [ProductsImportExportController],
  providers: [ProductsImportExportService, ReferenceResolver],
  exports: [ProductsImportExportService],
})
export class ProductsImportExportModule {}
