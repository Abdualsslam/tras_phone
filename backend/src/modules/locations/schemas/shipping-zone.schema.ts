import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ShippingZoneDocument = ShippingZone & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Shipping Zone Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'shipping_zones',
})
export class ShippingZone {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ type: Types.ObjectId, ref: 'Country', required: true })
    countryId: Types.ObjectId;

    // ═════════════════════════════════════
    // Shipping Costs
    // ═════════════════════════════════════
    @Prop({ required: true, type: Number })
    baseCost: number; // Base shipping cost

    @Prop({ type: Number, default: 0 })
    costPerKg: number; // Additional cost per kg

    @Prop({ type: Number })
    freeShippingThreshold?: number; // Order amount for free shipping

    // ═════════════════════════════════════
    // Delivery Time
    // ═════════════════════════════════════
    @Prop({ type: Number })
    estimatedDeliveryDays?: number;

    @Prop({ type: Number })
    minDeliveryDays?: number;

    @Prop({ type: Number })
    maxDeliveryDays?: number;

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const ShippingZoneSchema = SchemaFactory.createForClass(ShippingZone);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ShippingZoneSchema.index({ countryId: 1 });
ShippingZoneSchema.index({ isActive: 1 });
