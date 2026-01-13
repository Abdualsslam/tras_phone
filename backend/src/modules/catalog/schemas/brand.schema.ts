import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type BrandDocument = Brand & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏷️ Brand Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'brands',
})
export class Brand {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true, lowercase: true })
    slug: string;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    @Prop()
    logo?: string; // URL

    @Prop()
    website?: string;

    // ═════════════════════════════════════
    // SEO
    // ═════════════════════════════════════
    @Prop()
    metaTitle?: string;

    @Prop()
    metaTitleAr?: string;

    @Prop()
    metaDescription?: string;

    @Prop()
    metaDescriptionAr?: string;

    @Prop({ type: [String] })
    metaKeywords?: string[];

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isFeatured: boolean;

    @Prop({ default: 0 })
    displayOrder: number;

    // ═════════════════════════════════════
    // Statistics (updated via aggregation)
    // ═════════════════════════════════════
    @Prop({ default: 0 })
    productsCount: number;

    createdAt: Date;
    updatedAt: Date;
}

export const BrandSchema = SchemaFactory.createForClass(Brand);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'slug' index is automatically created by unique: true
BrandSchema.index({ isActive: 1 });
BrandSchema.index({ isFeatured: 1 });
BrandSchema.index({ name: 'text', nameAr: 'text' });
