import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Product, ProductSchema } from './schemas/product.schema';
import { ProductPrice, ProductPriceSchema } from './schemas/product-price.schema';
import { ProductReview, ProductReviewSchema } from './schemas/product-review.schema';
import { Wishlist, WishlistSchema } from './schemas/wishlist.schema';
import { PriceLevel, PriceLevelSchema } from './schemas/price-level.schema';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Product.name, schema: ProductSchema },
            { name: ProductPrice.name, schema: ProductPriceSchema },
            { name: ProductReview.name, schema: ProductReviewSchema },
            { name: Wishlist.name, schema: WishlistSchema },
            { name: PriceLevel.name, schema: PriceLevelSchema },
        ]),
    ],
    controllers: [ProductsController],
    providers: [ProductsService],
    exports: [ProductsService],
})
export class ProductsModule { }
