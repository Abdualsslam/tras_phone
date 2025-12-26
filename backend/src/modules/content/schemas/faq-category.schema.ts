import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FaqCategoryDocument = FaqCategory & Document;

@Schema({ timestamps: true })
export class FaqCategory {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({ trim: true })
    descriptionAr?: string;

    @Prop({ trim: true })
    descriptionEn?: string;

    @Prop({ type: String })
    icon?: string;

    @Prop({ required: true, unique: true, lowercase: true })
    slug: string;

    @Prop({ default: 0 })
    sortOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    faqCount: number;
}

export const FaqCategorySchema = SchemaFactory.createForClass(FaqCategory);

FaqCategorySchema.index({ slug: 1 }, { unique: true });
FaqCategorySchema.index({ isActive: 1, sortOrder: 1 });
