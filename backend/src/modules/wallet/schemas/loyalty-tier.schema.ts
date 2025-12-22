import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type LoyaltyTierDocument = LoyaltyTier & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏆 Loyalty Tier Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'loyalty_tiers',
})
export class LoyaltyTier {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true })
    code: string; // bronze, silver, gold, platinum

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    // ═════════════════════════════════════
    // Qualification
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    minPoints: number; // Points needed to reach this tier

    @Prop({ type: Number })
    minSpend?: number; // Alternative: minimum spend amount

    @Prop({ type: Number })
    minOrders?: number; // Alternative: minimum order count

    // ═════════════════════════════════════
    // Benefits
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 1 })
    pointsMultiplier: number; // 1x, 1.5x, 2x points earning

    @Prop({ type: Number, default: 0 })
    discountPercentage: number; // Extra discount

    @Prop({ default: false })
    freeShipping: boolean;

    @Prop({ default: false })
    prioritySupport: boolean;

    @Prop({ default: false })
    earlyAccess: boolean; // Early access to sales

    @Prop({ type: [String] })
    customBenefits?: string[]; // List of other benefits

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop()
    icon?: string;

    @Prop()
    color?: string;

    @Prop()
    badgeImage?: string;

    @Prop({ type: Number, default: 0 })
    displayOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const LoyaltyTierSchema = SchemaFactory.createForClass(LoyaltyTier);

LoyaltyTierSchema.index({ code: 1 });
LoyaltyTierSchema.index({ minPoints: 1 });
LoyaltyTierSchema.index({ isActive: 1, displayOrder: 1 });
