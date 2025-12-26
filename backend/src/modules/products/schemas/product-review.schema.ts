import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductReviewDocument = ProductReview & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ⭐ Product Review Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'product_reviews',
})
export class ProductReview {
    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Order' })
    orderId?: Types.ObjectId;

    @Prop({ required: true, min: 1, max: 5 })
    rating: number;

    @Prop()
    title?: string;

    @Prop()
    comment?: string;

    @Prop({ type: [String] })
    images?: string[];

    // ═════════════════════════════════════
    // Moderation
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['pending', 'approved', 'rejected'],
        default: 'pending',
    })
    status: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    moderatedBy?: Types.ObjectId;

    @Prop({ type: Date })
    moderatedAt?: Date;

    @Prop()
    moderationNote?: string;

    // ═════════════════════════════════════
    // Helpful votes
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    helpfulCount: number;

    @Prop({ type: [Types.ObjectId], ref: 'Customer', default: [] })
    helpfulVoters: Types.ObjectId[];

    @Prop({ default: false })
    isVerifiedPurchase: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const ProductReviewSchema = SchemaFactory.createForClass(ProductReview);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ProductReviewSchema.index({ productId: 1, status: 1 });
ProductReviewSchema.index({ customerId: 1 });
ProductReviewSchema.index({ rating: 1 });
ProductReviewSchema.index({ createdAt: -1 });
ProductReviewSchema.index({ productId: 1, customerId: 1 }, { unique: true }); // One review per product per customer
