import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TestimonialDocument = Testimonial & Document;

@Schema({ timestamps: true })
export class Testimonial {
    @Prop({ required: true, trim: true })
    customerName: string;

    @Prop()
    customerTitle?: string; // e.g., "CEO, Company"

    @Prop()
    customerImage?: string;

    @Prop({ type: Types.ObjectId, ref: 'Customer' })
    customerId?: Types.ObjectId;

    @Prop({ required: true })
    contentAr: string;

    @Prop({ required: true })
    contentEn: string;

    @Prop({ type: Number, min: 1, max: 5, required: true })
    rating: number;

    @Prop({ type: Types.ObjectId, ref: 'Product' })
    productId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Order' })
    orderId?: Types.ObjectId;

    @Prop({ default: false })
    isFeatured: boolean;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    sortOrder: number;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    approvedBy?: Types.ObjectId;

    @Prop()
    approvedAt?: Date;
}

export const TestimonialSchema = SchemaFactory.createForClass(Testimonial);

TestimonialSchema.index({ isActive: 1, isFeatured: -1, sortOrder: 1 });
TestimonialSchema.index({ productId: 1, isActive: 1 });
TestimonialSchema.index({ rating: -1 });
