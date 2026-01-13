import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type LoginAttemptDocument = LoginAttempt & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Login Attempt Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'login_attempts',
})
export class LoginAttempt {
  @Prop({ required: true, index: true })
  identifier: string;

  @Prop({
    type: String,
    enum: ['phone', 'email', 'ip'],
    required: true,
    index: true,
  })
  identifierType: 'phone' | 'email' | 'ip';

  @Prop({ required: true, index: true })
  ipAddress: string;

  @Prop({ type: String })
  userAgent?: string;

  @Prop({
    type: String,
    enum: ['success', 'failed', 'blocked'],
    required: true,
  })
  status: 'success' | 'failed' | 'blocked';

  @Prop()
  failureReason?: string;

  createdAt: Date;
}

export const LoginAttemptSchema = SchemaFactory.createForClass(LoginAttempt);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
LoginAttemptSchema.index({ identifier: 1, identifierType: 1 });
LoginAttemptSchema.index({ ipAddress: 1 });
LoginAttemptSchema.index({ createdAt: 1 });
LoginAttemptSchema.index({ createdAt: 1 }, { expireAfterSeconds: 86400 * 90 }); // Keep for 90 days
