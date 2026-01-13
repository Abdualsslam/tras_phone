import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TaxRateDocument = TaxRate & Document;

@Schema({ timestamps: true })
export class TaxRate {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ required: true, unique: true, lowercase: true })
    code: string; // e.g., 'vat-15'

    @Prop({ required: true, min: 0, max: 100 })
    rate: number; // Percentage, e.g., 15

    @Prop({
        type: String,
        enum: ['percentage', 'fixed'],
        default: 'percentage'
    })
    type: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean;

    @Prop({ default: false })
    isCompound: boolean; // Applied on top of other taxes

    @Prop({ default: true })
    includeInPrice: boolean; // Price includes tax

    // Applicability
    @Prop({ type: [{ type: Types.ObjectId, ref: 'Country' }] })
    countries?: Types.ObjectId[];

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Category' }] })
    categories?: Types.ObjectId[];

    @Prop({ type: [String] })
    productTypes?: string[];

    // Priority for overlapping rules
    @Prop({ default: 0 })
    priority: number;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;
}

export const TaxRateSchema = SchemaFactory.createForClass(TaxRate);

// Note: 'code' index is automatically created by unique: true
TaxRateSchema.index({ isActive: 1, priority: -1 });
