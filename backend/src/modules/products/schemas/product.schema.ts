import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductDocument = Product & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Product Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'products',
  toJSON: { virtuals: true },
})
export class Product {
  @Prop({ required: true, unique: true })
  sku: string;

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
  shortDescription?: string;

  @Prop()
  shortDescriptionAr?: string;

  // ═════════════════════════════════════
  // Relationships
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'Brand', required: true, index: true })
  brandId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Category', required: true, index: true })
  categoryId: Types.ObjectId;

  @Prop({ type: [Types.ObjectId], ref: 'Category', default: [] })
  additionalCategories: Types.ObjectId[];

  @Prop({ type: Types.ObjectId, ref: 'QualityType', required: true })
  qualityTypeId: Types.ObjectId;

  // ═════════════════════════════════════
  // Device Compatibility
  // ═════════════════════════════════════
  @Prop({ type: [Types.ObjectId], ref: 'Device', default: [] })
  compatibleDevices: Types.ObjectId[];

  // ═════════════════════════════════════
  // Related Products
  // ═════════════════════════════════════
  @Prop({ type: [Types.ObjectId], ref: 'Product', default: [] })
  relatedProducts?: Types.ObjectId[];

  // ═════════════════════════════════════
  // Related Educational Content
  // ═════════════════════════════════════
  @Prop({ type: [Types.ObjectId], ref: 'EducationalContent', default: [] })
  relatedEducationalContent?: Types.ObjectId[];

  // ═════════════════════════════════════
  // Specifications
  // ═════════════════════════════════════
  @Prop({ type: Object })
  specifications?: Record<string, any>; // Flexible key-value specs

  @Prop()
  weight?: number; // In grams

  @Prop()
  dimensions?: string; // "LxWxH in cm"

  @Prop()
  color?: string;

  // ═════════════════════════════════════
  // Images
  // ═════════════════════════════════════
  @Prop()
  mainImage?: string;

  @Prop({ type: [String], default: [] })
  images: string[];

  @Prop()
  video?: string;

  // ═════════════════════════════════════
  // Pricing (base - actual prices in ProductPrice)
  // ═════════════════════════════════════
  @Prop({ type: Number, required: true })
  basePrice: number;

  @Prop({ type: Number })
  compareAtPrice?: number; // Original price for showing discount

  @Prop({ type: Number })
  costPrice?: number; // For profit calculations

  // ═════════════════════════════════════
  // Inventory
  // ═════════════════════════════════════
  @Prop({ type: Number, default: 0 })
  stockQuantity: number;

  @Prop({ type: Number, default: 5 })
  lowStockThreshold: number;

  @Prop({ default: true })
  trackInventory: boolean;

  @Prop({ default: false })
  allowBackorder: boolean;

  // ═════════════════════════════════════
  // Ordering
  // ═════════════════════════════════════
  @Prop({ type: Number, default: 1 })
  minOrderQuantity: number;

  @Prop({ type: Number })
  maxOrderQuantity?: number;

  @Prop({ type: Number, default: 1 })
  quantityStep: number; // Must order in multiples of this

  // ═════════════════════════════════════
  // Status & Visibility
  // ═════════════════════════════════════
  @Prop({
    type: String,
    enum: ['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'],
    default: 'draft',
  })
  status: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: false })
  isFeatured: boolean;

  @Prop({ default: false })
  isNewArrival: boolean;

  @Prop({ default: false })
  isBestSeller: boolean;

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
  // Tags
  // ═════════════════════════════════════
  @Prop({ type: [String], default: [] })
  tags: string[];

  // ═════════════════════════════════════
  // Warranty
  // ═════════════════════════════════════
  @Prop({ type: Number })
  warrantyDays?: number;

  @Prop()
  warrantyDescription?: string;

  // ═════════════════════════════════════
  // Statistics (updated via hooks/aggregation)
  // ═════════════════════════════════════
  @Prop({ type: Number, default: 0 })
  viewsCount: number;

  @Prop({ type: Number, default: 0 })
  ordersCount: number;

  @Prop({ type: Number, default: 0 })
  reviewsCount: number;

  @Prop({ type: Number, default: 0 })
  averageRating: number;

  @Prop({ type: Number, default: 0 })
  wishlistCount: number;

  // ═════════════════════════════════════
  // Timestamps
  // ═════════════════════════════════════
  @Prop({ type: Date })
  publishedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const ProductSchema = SchemaFactory.createForClass(Product);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ProductSchema.index({ sku: 1 });
// Note: 'slug' index is automatically created by unique: true
ProductSchema.index({ brandId: 1 });
ProductSchema.index({ categoryId: 1 });
ProductSchema.index({ qualityTypeId: 1 });
ProductSchema.index({ compatibleDevices: 1 });
ProductSchema.index({ relatedProducts: 1 });
ProductSchema.index({ relatedEducationalContent: 1 });
ProductSchema.index({ status: 1 });
ProductSchema.index({ isActive: 1, status: 1 });
ProductSchema.index({ isFeatured: 1 });
ProductSchema.index({ isNewArrival: 1 });
ProductSchema.index({ isBestSeller: 1 });
ProductSchema.index({ tags: 1 });
ProductSchema.index({ basePrice: 1 });
ProductSchema.index({ createdAt: -1 });

// Enhanced text index for advanced search
// Supports search in name, nameAr, tags, description, shortDescription
ProductSchema.index(
  {
    name: 'text',
    nameAr: 'text',
    tags: 'text',
    description: 'text',
    shortDescription: 'text',
    sku: 'text',
  },
  {
    weights: {
      name: 10,
      nameAr: 10,
      tags: 8,
      sku: 5,
      description: 3,
      shortDescription: 2,
    },
  },
);

// Compound indexes for common search patterns
ProductSchema.index({ status: 1, isActive: 1, tags: 1 });
ProductSchema.index({ status: 1, brandId: 1, categoryId: 1 });
// Index for products on offer (compareAtPrice > basePrice)
ProductSchema.index({ compareAtPrice: 1, basePrice: 1, status: 1 });

// ═════════════════════════════════════
// Virtuals
// ═════════════════════════════════════
ProductSchema.virtual('isLowStock').get(function () {
  return this.stockQuantity <= this.lowStockThreshold;
});

ProductSchema.virtual('isOutOfStock').get(function () {
  return this.stockQuantity === 0;
});
