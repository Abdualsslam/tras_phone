import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PriceLevelDocument = PriceLevel & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Price Level Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'price_levels',
})
export class PriceLevel {
    @Prop({ required: true, unique: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true })
    code: string; // "retail", "wholesale", "vip"

    @Prop()
    description?: string;

    // ═════════════════════════════════════
    // Discount
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    discountPercentage: number; // Default discount for this level

    @Prop({ type: Number })
    minOrderAmount?: number; // Minimum order to qualify

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop()
    color?: string;

    @Prop({ default: 0 })
    displayOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean; // Default for new customers

    createdAt: Date;
    updatedAt: Date;
}

export const PriceLevelSchema = SchemaFactory.createForClass(PriceLevel);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
PriceLevelSchema.index({ code: 1 });
PriceLevelSchema.index({ isActive: 1 });
PriceLevelSchema.index({ isDefault: 1 });
