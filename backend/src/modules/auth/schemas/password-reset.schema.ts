import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PasswordResetDocument = PasswordReset & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 Password Reset Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'password_resets',
})
export class PasswordReset {
    @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
    userId: Types.ObjectId;

    @Prop({ required: true, unique: true })
    token: string;

    @Prop()
    otp?: string;

    @Prop({ type: Date, required: true, index: true })
    expiresAt: Date;

    @Prop({ type: Date })
    usedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const PasswordResetSchema =
    SchemaFactory.createForClass(PasswordReset);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
PasswordResetSchema.index({ token: 1 });
PasswordResetSchema.index({ userId: 1 });
PasswordResetSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index
