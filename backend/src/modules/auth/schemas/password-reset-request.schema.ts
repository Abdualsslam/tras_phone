import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PasswordResetRequestDocument = PasswordResetRequest & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Password Reset Request Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'password_reset_requests',
})
export class PasswordResetRequest {
  @Prop({ required: true, unique: true, index: true })
  requestNumber: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ required: true, index: true })
  phone: string;

  @Prop({
    type: String,
    enum: ['pending', 'completed', 'rejected'],
    default: 'pending',
    index: true,
  })
  status: string;

  @Prop()
  temporaryPassword?: string; // Hashed password

  @Prop()
  temporaryPasswordPlain?: string; // Plain password (temporary, should be deleted after use)

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  processedBy?: Types.ObjectId;

  @Prop({ type: Date })
  processedAt?: Date;

  @Prop()
  rejectionReason?: string;

  @Prop()
  customerNotes?: string;

  @Prop()
  adminNotes?: string;

  createdAt: Date;
  updatedAt: Date;
}

export const PasswordResetRequestSchema =
  SchemaFactory.createForClass(PasswordResetRequest);

PasswordResetRequestSchema.index({ requestNumber: 1 });
PasswordResetRequestSchema.index({ customerId: 1 });
PasswordResetRequestSchema.index({ phone: 1 });
PasswordResetRequestSchema.index({ status: 1 });
PasswordResetRequestSchema.index({ createdAt: -1 });
PasswordResetRequestSchema.index({ customerId: 1, status: 1 });
