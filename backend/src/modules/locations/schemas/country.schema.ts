import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type CountryDocument = Country & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🌍 Country Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'countries',
})
export class Country {
    @Prop({ required: true, unique: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true, uppercase: true, length: 2 })
    code: string; // ISO 3166-1 alpha-2 (e.g., SA, AE)

    @Prop({ required: true, unique: true, uppercase: true, length: 3 })
    code3: string; // ISO 3166-1 alpha-3 (e.g., SAU, ARE)

    @Prop({ required: true })
    phoneCode: string; // e.g., +966

    @Prop({ required: true, default: 'SAR' })
    currency: string;

    @Prop()
    flag?: string; // URL or emoji

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean; // Default country (Saudi Arabia)

    createdAt: Date;
    updatedAt: Date;
}

export const CountrySchema = SchemaFactory.createForClass(Country);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
CountrySchema.index({ code: 1 });
CountrySchema.index({ isActive: 1 });
CountrySchema.index({ isDefault: 1 });
