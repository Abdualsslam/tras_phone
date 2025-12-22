import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CouponDocument = Coupon & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎟️ Coupon Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'coupons',
})
export class Coupon {
    @Prop({ required: true, unique: true, uppercase: true })
    code: string;

    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop()
    description?: string;

    // ═════════════════════════════════════
    // Discount
    // ═════════════════════════════════════
    @Prop({
        required: true,
        type: String,
        enum: ['percentage', 'fixed_amount', 'free_shipping'],
    })
    discountType: string;

    @Prop({ type: Number })
    discountValue?: number;

    @Prop({ type: Number })
    maxDiscountAmount?: number;

    // ═════════════════════════════════════
    // Validity
    // ═════════════════════════════════════
    @Prop({ type: Date, required: true })
    startDate: Date;

    @Prop({ type: Date, required: true })
    expiryDate: Date;

    // ═════════════════════════════════════
    // Conditions
    // ═════════════════════════════════════
    @Prop({ type: Number })
    minOrderAmount?: number;

    @Prop({ type: [Types.ObjectId], ref: 'PriceLevel' })
    applicablePriceLevels?: Types.ObjectId[];

    @Prop({ type: [Types.ObjectId], ref: 'Category' })
    applicableCategories?: Types.ObjectId[];

    @Prop({ type: [Types.ObjectId], ref: 'Product' })
    applicableProducts?: Types.ObjectId[];

    @Prop({ default: false })
    firstOrderOnly: boolean;

    // ═════════════════════════════════════
    // Usage Limits
    // ═════════════════════════════════════
    @Prop({ type: Number })
    usageLimit?: number;

    @Prop({ type: Number, default: 1 })
    usageLimitPerCustomer: number;

    @Prop({ type: Number, default: 0 })
    usedCount: number;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isPublic: boolean; // Show in promotions page

    createdAt: Date;
    updatedAt: Date;
}

export const CouponSchema = SchemaFactory.createForClass(Coupon);

CouponSchema.index({ code: 1 });
CouponSchema.index({ isActive: 1, startDate: 1, expiryDate: 1 });
CouponSchema.index({ isPublic: 1 });
