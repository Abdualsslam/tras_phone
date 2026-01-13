import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CountryDocument = Country & Document;

@Schema({ timestamps: true })
export class Country {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ required: true, unique: true, uppercase: true, length: 2 })
    code: string; // ISO 3166-1 alpha-2

    @Prop({ uppercase: true, length: 3 })
    code3?: string; // ISO 3166-1 alpha-3

    @Prop()
    numericCode?: string;

    @Prop()
    phoneCode: string; // +966

    @Prop()
    currency?: string; // SAR

    @Prop()
    flagEmoji?: string;

    @Prop()
    flagUrl?: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean;

    @Prop({ default: true })
    allowShipping: boolean;

    @Prop({ default: true })
    allowBilling: boolean;

    @Prop({ default: 0 })
    sortOrder: number;
}

export const CountrySchema = SchemaFactory.createForClass(Country);

// Note: 'code' index is automatically created by unique: true
CountrySchema.index({ isActive: 1, sortOrder: 1 });
