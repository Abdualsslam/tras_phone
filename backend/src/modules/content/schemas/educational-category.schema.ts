import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type EducationalCategoryDocument = EducationalCategory & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📚 Educational Category Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'educational_categories',
})
export class EducationalCategory {
  @Prop({ required: true })
  name: string;

  @Prop()
  nameAr?: string;

  @Prop({ required: true, unique: true, index: true })
  slug: string;

  @Prop()
  description?: string;

  @Prop()
  descriptionAr?: string;

  @Prop()
  icon?: string;

  @Prop()
  image?: string;

  @Prop({ type: Types.ObjectId, ref: 'EducationalCategory' })
  parentId?: Types.ObjectId;

  @Prop({ default: 0 })
  contentCount: number;

  @Prop({ default: 0 })
  sortOrder: number;

  @Prop({ default: true })
  isActive: boolean;

  createdAt: Date;
  updatedAt: Date;
}

export const EducationalCategorySchema =
  SchemaFactory.createForClass(EducationalCategory);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'slug' index is automatically created by unique: true
EducationalCategorySchema.index({ parentId: 1 });
EducationalCategorySchema.index({ isActive: 1 });
EducationalCategorySchema.index({ sortOrder: 1 });
