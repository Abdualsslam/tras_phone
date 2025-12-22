import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CityDocument = City & Document;

@Schema({ timestamps: true })
export class City {
    @Prop({ type: Types.ObjectId, ref: 'Country', required: true })
    country: Types.ObjectId;

    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop()
    code?: string;

    @Prop()
    postalCode?: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: true })
    allowDelivery: boolean;

    @Prop({ default: 0 })
    shippingFee: number;

    @Prop({ default: 0 })
    estimatedDeliveryDays: number;

    @Prop({ default: 0 })
    sortOrder: number;

    // Geolocation
    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;
}

export const CitySchema = SchemaFactory.createForClass(City);

CitySchema.index({ country: 1, isActive: 1 });
CitySchema.index({ nameAr: 1 });
CitySchema.index({ nameEn: 1 });
