import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionDocument = Promotion & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Promotion Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'promotions',
})
export class Promotion {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true })
    code: string;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    // ═════════════════════════════════════
    // Discount Type
    // ═════════════════════════════════════
    @Prop({
        required: true,
        type: String,
        enum: ['percentage', 'fixed_amount', 'buy_x_get_y', 'free_shipping'],
    })
    discountType: string;

    @Prop({ type: Number })
    discountValue?: number; // Percentage or fixed amount

    @Prop({ type: Number })
    maxDiscountAmount?: number; // Cap for percentage discounts

    // ═════════════════════════════════════
    // Buy X Get Y
    // ═════════════════════════════════════
    @Prop({ type: Number })
    buyQuantity?: number; // Buy X

    @Prop({ type: Number })
    getQuantity?: number; // Get Y

    @Prop({ type: Number })
    getDiscountPercentage?: number; // Discount on Y (100 = free)

    // ═════════════════════════════════════
    // Validity
    // ═════════════════════════════════════
    @Prop({ type: Date, required: true })
    startDate: Date;

    @Prop({ type: Date, required: true })
    endDate: Date;

    // ═════════════════════════════════════
    // Conditions
    // ═════════════════════════════════════
    @Prop({ type: Number })
    minOrderAmount?: number;

    @Prop({ type: Number })
    minQuantity?: number;

    @Prop({ type: [Types.ObjectId], ref: 'PriceLevel' })
    applicablePriceLevels?: Types.ObjectId[]; // Empty = all levels

    @Prop({ type: [Types.ObjectId], ref: 'Customer' })
    applicableCustomers?: Types.ObjectId[]; // Empty = all customers

    // ═════════════════════════════════════
    // Scope
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['all', 'specific_products', 'specific_categories', 'specific_brands'],
        default: 'all',
    })
    scope: string;

    // ═════════════════════════════════════
    // Usage Limits
    // ═════════════════════════════════════
    @Prop({ type: Number })
    usageLimit?: number; // Total uses allowed

    @Prop({ type: Number })
    usageLimitPerCustomer?: number;

    @Prop({ type: Number, default: 0 })
    usedCount: number;

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop()
    image?: string;

    @Prop()
    badgeText?: string;

    @Prop()
    badgeColor?: string;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isAutoApply: boolean; // Auto-apply when conditions met

    @Prop({ type: Number, default: 0 })
    priority: number; // Higher = applied first

    // ═════════════════════════════════════
    // Stacking
    // ═════════════════════════════════════
    @Prop({ default: false })
    isStackable: boolean; // Can combine with other promotions

    @Prop({ type: [Types.ObjectId], ref: 'Promotion' })
    excludedPromotions?: Types.ObjectId[]; // Cannot combine with these

    createdAt: Date;
    updatedAt: Date;
}

export const PromotionSchema = SchemaFactory.createForClass(Promotion);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
PromotionSchema.index({ code: 1 });
PromotionSchema.index({ isActive: 1, startDate: 1, endDate: 1 });
PromotionSchema.index({ scope: 1 });
PromotionSchema.index({ isAutoApply: 1 });
PromotionSchema.index({ priority: -1 });
