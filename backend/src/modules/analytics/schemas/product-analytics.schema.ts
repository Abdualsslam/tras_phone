import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductAnalyticsDocument = ProductAnalytics & Document;

@Schema({ timestamps: true })
export class ProductAnalytics {
    @Prop({ type: Types.ObjectId, ref: 'Product', required: true })
    product: Types.ObjectId;

    @Prop({ required: true })
    date: Date;

    // Views
    @Prop({ default: 0 })
    views: number;

    @Prop({ default: 0 })
    uniqueViews: number;

    // Cart actions
    @Prop({ default: 0 })
    addToCart: number;

    @Prop({ default: 0 })
    removeFromCart: number;

    // Wishlist
    @Prop({ default: 0 })
    addToWishlist: number;

    @Prop({ default: 0 })
    removeFromWishlist: number;

    // Sales
    @Prop({ default: 0 })
    unitsSold: number;

    @Prop({ default: 0 })
    revenue: number;

    @Prop({ default: 0 })
    unitsReturned: number;

    @Prop({ default: 0 })
    refundAmount: number;

    // Conversion
    @Prop({ default: 0 })
    viewToCartRate: number;

    @Prop({ default: 0 })
    cartToPurchaseRate: number;

    // Reviews
    @Prop({ default: 0 })
    reviewsReceived: number;

    @Prop({ default: 0 })
    avgRating: number;

    // Stock
    @Prop({ default: 0 })
    stockLevel: number;

    @Prop({ default: 0 })
    stockOuts: number;
}

export const ProductAnalyticsSchema = SchemaFactory.createForClass(ProductAnalytics);

ProductAnalyticsSchema.index({ product: 1, date: 1 }, { unique: true });
ProductAnalyticsSchema.index({ date: 1 });
