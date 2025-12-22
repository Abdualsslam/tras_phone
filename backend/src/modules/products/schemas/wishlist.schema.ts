import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WishlistDocument = Wishlist & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ❤️ Wishlist Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'wishlists',
})
export class Wishlist {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop()
    note?: string;

    @Prop({ default: false })
    notifyOnPriceChange: boolean;

    @Prop({ default: false })
    notifyOnBackInStock: boolean;

    createdAt: Date;
}

export const WishlistSchema = SchemaFactory.createForClass(Wishlist);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
WishlistSchema.index({ customerId: 1, productId: 1 }, { unique: true });
