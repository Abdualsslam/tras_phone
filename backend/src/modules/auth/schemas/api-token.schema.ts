import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ApiTokenDocument = ApiToken & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 API Token Schema (for external integrations)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'api_tokens',
})
export class ApiToken {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true, index: true })
  token: string;

  // Permissions
  @Prop({ type: [String], default: [] })
  abilities?: string[];

  // Limits
  @Prop({ type: Number, default: 1000 })
  rateLimit: number;

  // Status
  @Prop({ type: Boolean, default: true })
  isActive: boolean;

  @Prop({ type: Date })
  lastUsedAt?: Date;

  @Prop({ type: Date })
  expiresAt?: Date;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const ApiTokenSchema = SchemaFactory.createForClass(ApiToken);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
ApiTokenSchema.index({ token: 1 });
ApiTokenSchema.index({ isActive: 1 });
ApiTokenSchema.index({ expiresAt: 1 });
