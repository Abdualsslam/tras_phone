import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ShippingZoneDocument = ShippingZone & Document;

@Schema({ _id: false })
export class ShippingRate {
    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true })
    nameEn: string;

    @Prop({
        type: String,
        enum: ['flat', 'weight', 'price', 'quantity', 'free'],
        required: true
    })
    type: string;

    @Prop({ default: 0 })
    cost: number;

    @Prop({ default: 0 })
    minOrderAmount: number; // For free shipping threshold

    @Prop({ default: 0 })
    minWeight: number; // kg

    @Prop()
    maxWeight?: number;

    @Prop({ default: 0 })
    weightRate?: number; // Cost per kg

    @Prop({ default: 0 })
    estimatedDays: number;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    sortOrder: number;
}

@Schema({ timestamps: true })
export class ShippingZone {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ required: true, unique: true, lowercase: true })
    code: string;

    // Zone coverage
    @Prop({ type: [{ type: Types.ObjectId, ref: 'Country' }] })
    countries: Types.ObjectId[];

    @Prop({ type: [{ type: Types.ObjectId, ref: 'City' }] })
    cities?: Types.ObjectId[];

    @Prop({ type: [String] })
    postalCodes?: string[];

    // Shipping methods
    @Prop({ type: [ShippingRate], default: [] })
    rates: ShippingRate[];

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    sortOrder: number;

    // Restrictions
    @Prop({ default: false })
    restrictedProducts: boolean;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Category' }] })
    excludedCategories?: Types.ObjectId[];

    @Prop()
    maxWeight?: number; // Maximum weight allowed for this zone

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;
}

export const ShippingZoneSchema = SchemaFactory.createForClass(ShippingZone);

// Note: 'code' index is automatically created by unique: true
ShippingZoneSchema.index({ isActive: 1, sortOrder: 1 });
ShippingZoneSchema.index({ countries: 1 });
ShippingZoneSchema.index({ cities: 1 });
