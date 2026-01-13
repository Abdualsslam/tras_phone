import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type TagDocument = Tag & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏷️ Tag Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'tags',
})
export class Tag {
  @Prop({ required: true })
  name: string;

  @Prop()
  nameAr?: string;

  @Prop({ required: true, unique: true, index: true })
  slug: string;

  createdAt: Date;
}

export const TagSchema = SchemaFactory.createForClass(Tag);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'slug' index is automatically created by unique: true
