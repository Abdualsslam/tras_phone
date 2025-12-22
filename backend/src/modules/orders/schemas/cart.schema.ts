import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CartDocument = Cart & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Cart Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'carts',
})
export class Cart {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({
        type: String,
        enum: ['active', 'abandoned', 'converted', 'expired'],
        default: 'active',
    })
    status: string;

    // ═════════════════════════════════════
    // Items (embedded for Redis-like speed)
    // ═════════════════════════════════════
    @Prop({
        type: [{
            productId: { type: Types.ObjectId, ref: 'Product', required: true },
            quantity: { type: Number, required: true, min: 1 },
            unitPrice: { type: Number, required: true },
            totalPrice: { type: Number, required: true },
            addedAt: { type: Date, default: Date.now },
        }],
        default: [],
    })
    items: {
        productId: Types.ObjectId;
        quantity: number;
        unitPrice: number;
        totalPrice: number;
        addedAt: Date;
    }[];

    // ═════════════════════════════════════
    // Totals
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    itemsCount: number;

    @Prop({ type: Number, default: 0 })
    subtotal: number;

    @Prop({ type: Number, default: 0 })
    discount: number;

    @Prop({ type: Number, default: 0 })
    taxAmount: number;

    @Prop({ type: Number, default: 0 })
    shippingCost: number;

    @Prop({ type: Number, default: 0 })
    total: number;

    // ═════════════════════════════════════
    // Applied Promotions/Coupons
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'Coupon' })
    couponId?: Types.ObjectId;

    @Prop()
    couponCode?: string;

    @Prop({ type: Number, default: 0 })
    couponDiscount: number;

    @Prop({ type: [Types.ObjectId], ref: 'Promotion' })
    appliedPromotions?: Types.ObjectId[];

    // ═════════════════════════════════════
    // Tracking
    // ═════════════════════════════════════
    @Prop({ type: Date })
    lastActivityAt?: Date;

    @Prop({ type: Date })
    convertedAt?: Date;

    @Prop({ type: Types.ObjectId, ref: 'Order' })
    orderId?: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const CartSchema = SchemaFactory.createForClass(Cart);

CartSchema.index({ customerId: 1, status: 1 });
CartSchema.index({ status: 1 });
CartSchema.index({ lastActivityAt: 1 }); // For abandoned cart detection
