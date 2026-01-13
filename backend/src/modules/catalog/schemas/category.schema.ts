import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CategoryDocument = Category & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📂 Category Schema (Hierarchical Tree)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'categories',
})
export class Category {
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
    image?: string;

    @Prop()
    icon?: string;

    // ═════════════════════════════════════
    // Hierarchy
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'Category', index: true })
    parentId?: Types.ObjectId;

    @Prop({ type: [Types.ObjectId], ref: 'Category', default: [] })
    ancestors: Types.ObjectId[]; // All parent IDs from root to immediate parent

    @Prop({ default: 0 })
    level: number; // 0 = root, 1 = child, 2 = grandchild, etc.

    @Prop()
    path?: string; // Full path like "electronics/phones/screens"

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
    // Statistics
    // ═════════════════════════════════════
    @Prop({ default: 0 })
    productsCount: number;

    @Prop({ default: 0 })
    childrenCount: number;

    createdAt: Date;
    updatedAt: Date;
}

export const CategorySchema = SchemaFactory.createForClass(Category);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'slug' index is automatically created by unique: true
CategorySchema.index({ parentId: 1 });
CategorySchema.index({ ancestors: 1 });
CategorySchema.index({ level: 1 });
CategorySchema.index({ isActive: 1 });
CategorySchema.index({ isFeatured: 1 });
CategorySchema.index({ name: 'text', nameAr: 'text' });
