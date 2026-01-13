import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AppVersionDocument = AppVersion & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 App Version Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'app_versions',
})
export class AppVersion {
  @Prop({
    type: String,
    enum: ['ios', 'android'],
    required: true,
    index: true,
  })
  platform: 'ios' | 'android';

  @Prop({ required: true })
  version: string;

  @Prop({ type: Number, required: true })
  buildNumber: number;

  @Prop()
  releaseNotes?: string;

  @Prop()
  releaseNotesAr?: string;

  @Prop({ type: [String], default: [] })
  features: string[];

  @Prop({ type: [String], default: [] })
  bugFixes: string[];

  // Force Update
  @Prop({ default: false })
  isForceUpdate: boolean;

  @Prop()
  minSupportedVersion?: string;

  // Status
  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: false })
  isCurrent: boolean;

  // Links
  @Prop()
  storeUrl?: string;

  @Prop()
  downloadUrl?: string;

  // Dates
  @Prop({ type: Date })
  releaseDate?: Date;

  // Tracking
  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  createdBy?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const AppVersionSchema = SchemaFactory.createForClass(AppVersion);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
AppVersionSchema.index({ platform: 1, version: 1 }, { unique: true });
AppVersionSchema.index({ platform: 1, isCurrent: 1 });
AppVersionSchema.index({ createdAt: -1 });
