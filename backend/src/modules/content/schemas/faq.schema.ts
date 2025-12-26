import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FaqDocument = Faq & Document;

@Schema({ timestamps: true })
export class Faq {
    @Prop({ type: Types.ObjectId, ref: 'FaqCategory', required: true })
    category: Types.ObjectId;

    @Prop({ required: true, trim: true })
    questionAr: string;

    @Prop({ required: true, trim: true })
    questionEn: string;

    @Prop({ required: true })
    answerAr: string;

    @Prop({ required: true })
    answerEn: string;

    @Prop({ type: [String], default: [] })
    tags: string[];

    @Prop({ default: 0 })
    sortOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    viewCount: number;

    @Prop({ default: 0 })
    helpfulCount: number;

    @Prop({ default: 0 })
    notHelpfulCount: number;

    // SEO
    @Prop()
    metaTitleAr?: string;

    @Prop()
    metaTitleEn?: string;

    @Prop()
    metaDescriptionAr?: string;

    @Prop()
    metaDescriptionEn?: string;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    updatedBy?: Types.ObjectId;
}

export const FaqSchema = SchemaFactory.createForClass(Faq);

FaqSchema.index({ category: 1, isActive: 1, sortOrder: 1 });
FaqSchema.index({ tags: 1 });
FaqSchema.index({ '$**': 'text' }); // Full text search
