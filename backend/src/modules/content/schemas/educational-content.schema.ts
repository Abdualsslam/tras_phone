import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type EducationalContentDocument = EducationalContent & Document;

export enum ContentType {
  ARTICLE = 'article',
  VIDEO = 'video',
  TUTORIAL = 'tutorial',
  TIP = 'tip',
  GUIDE = 'guide',
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 📖 Educational Content Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'educational_content',
})
export class EducationalContent {
  @Prop({ required: true })
  title: string;

  @Prop()
  titleAr?: string;

  @Prop({ required: true, unique: true, index: true })
  slug: string;

  @Prop({
    type: Types.ObjectId,
    ref: 'EducationalCategory',
    required: true,
    index: true,
  })
  categoryId: Types.ObjectId;

  @Prop({
    type: String,
    enum: Object.values(ContentType),
    default: ContentType.ARTICLE,
  })
  type: ContentType;

  // Content
  @Prop()
  excerpt?: string;

  @Prop()
  excerptAr?: string;

  @Prop({ required: true })
  content: string;

  @Prop()
  contentAr?: string;

  // Media
  @Prop()
  featuredImage?: string;

  @Prop()
  videoUrl?: string;

  @Prop()
  videoDuration?: number; // in seconds

  @Prop({ type: [String], default: [] })
  attachments: string[];

  // Related
  @Prop({ type: [Types.ObjectId], ref: 'Product' })
  relatedProducts?: Types.ObjectId[];

  @Prop({ type: [Types.ObjectId], ref: 'EducationalContent' })
  relatedContent?: Types.ObjectId[];

  @Prop({ type: [String], default: [] })
  tags: string[];

  // SEO
  @Prop()
  metaTitle?: string;

  @Prop()
  metaDescription?: string;

  // Status
  @Prop({
    type: String,
    enum: ['draft', 'published', 'archived'],
    default: 'draft',
  })
  status: string;

  @Prop({ type: Date })
  publishedAt?: Date;

  @Prop({ default: false })
  isFeatured: boolean;

  // Stats
  @Prop({ type: Number, default: 0 })
  viewCount: number;

  @Prop({ type: Number, default: 0 })
  likeCount: number;

  @Prop({ type: Number, default: 0 })
  shareCount: number;

  // Reading
  @Prop({ type: Number })
  readingTime?: number; // in minutes

  @Prop({
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner',
  })
  difficulty: string;

  // Tracking
  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  createdBy?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  updatedBy?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const EducationalContentSchema =
  SchemaFactory.createForClass(EducationalContent);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'slug' index is automatically created by unique: true
// Note: 'categoryId' index is automatically created by index: true
EducationalContentSchema.index({ status: 1 });
EducationalContentSchema.index({ isFeatured: 1 });
EducationalContentSchema.index({ type: 1 });
EducationalContentSchema.index({ tags: 1 });
EducationalContentSchema.index({ createdAt: -1 });
EducationalContentSchema.index({ '$**': 'text' });
