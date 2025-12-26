import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SliderDocument = Slider & Document;

@Schema({ _id: false })
export class SliderSlide {
    @Prop({ required: true })
    imageDesktopAr: string;

    @Prop({ required: true })
    imageDesktopEn: string;

    @Prop()
    imageMobileAr?: string;

    @Prop()
    imageMobileEn?: string;

    @Prop()
    titleAr?: string;

    @Prop()
    titleEn?: string;

    @Prop()
    subtitleAr?: string;

    @Prop()
    subtitleEn?: string;

    @Prop()
    buttonTextAr?: string;

    @Prop()
    buttonTextEn?: string;

    @Prop()
    linkUrl?: string;

    @Prop({ default: false })
    openInNewTab: boolean;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    sortOrder: number;
}

@Schema({ timestamps: true })
export class Slider {
    @Prop({ required: true, trim: true })
    name: string;

    @Prop({ required: true, unique: true, lowercase: true })
    slug: string;

    @Prop({
        type: String,
        enum: ['home', 'category', 'product', 'custom'],
        default: 'home'
    })
    location: string;

    @Prop({ type: [SliderSlide], default: [] })
    slides: SliderSlide[];

    // Settings
    @Prop({ default: true })
    autoplay: boolean;

    @Prop({ default: 5000 })
    autoplaySpeed: number; // ms

    @Prop({ default: true })
    showDots: boolean;

    @Prop({ default: true })
    showArrows: boolean;

    @Prop({ default: true })
    infinite: boolean;

    @Prop({ default: true })
    pauseOnHover: boolean;

    @Prop({
        type: String,
        enum: ['slide', 'fade'],
        default: 'slide'
    })
    effect: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;
}

export const SliderSchema = SchemaFactory.createForClass(Slider);

SliderSchema.index({ slug: 1 }, { unique: true });
SliderSchema.index({ location: 1, isActive: 1 });
