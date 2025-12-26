import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CityDocument = City & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏙️ City Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'cities',
})
export class City {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ type: Types.ObjectId, ref: 'Country', required: true, index: true })
    countryId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'ShippingZone', required: true, index: true })
    shippingZoneId: Types.ObjectId;

    // ═════════════════════════════════════
    // Location Data
    // ═════════════════════════════════════
    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;

    @Prop()
    timezone?: string; // e.g., Asia/Riyadh

    // ═════════════════════════════════════
    // Administrative
    // ═════════════════════════════════════
    @Prop()
    region?: string;

    @Prop()
    regionAr?: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isCapital: boolean;

    @Prop({ default: 0 })
    displayOrder: number;

    createdAt: Date;
    updatedAt: Date;
}

export const CitySchema = SchemaFactory.createForClass(City);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
CitySchema.index({ countryId: 1 });
CitySchema.index({ shippingZoneId: 1 });
CitySchema.index({ isActive: 1 });
CitySchema.index({ name: 'text', nameAr: 'text' });
