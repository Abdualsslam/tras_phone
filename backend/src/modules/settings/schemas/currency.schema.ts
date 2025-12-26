import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CurrencyDocument = Currency & Document;

@Schema({ timestamps: true })
export class Currency {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ required: true, unique: true, uppercase: true, length: 3 })
    code: string; // ISO 4217

    @Prop({ required: true })
    symbol: string; // ر.س or $

    @Prop()
    symbolNative?: string;

    @Prop({ default: 2 })
    decimalDigits: number;

    @Prop({ default: 1 })
    exchangeRate: number; // Rate relative to base currency

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean;

    @Prop({
        type: String,
        enum: ['before', 'after'],
        default: 'after'
    })
    symbolPosition: string;

    @Prop({ default: ',' })
    thousandsSeparator: string;

    @Prop({ default: '.' })
    decimalSeparator: string;

    @Prop({ default: 0 })
    sortOrder: number;

    @Prop()
    lastRateUpdate?: Date;
}

export const CurrencySchema = SchemaFactory.createForClass(Currency);

CurrencySchema.index({ code: 1 }, { unique: true });
CurrencySchema.index({ isActive: 1, sortOrder: 1 });
