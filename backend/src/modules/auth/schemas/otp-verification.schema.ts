import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type OtpVerificationDocument = OtpVerification & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 OTP Verification Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'otp_verifications',
})
export class OtpVerification {
    @Prop({ required: true, index: true })
    phone: string;

    @Prop({ required: true })
    otp: string;

    @Prop({
        type: String,
        enum: ['registration', 'login', 'password_reset', 'phone_change'],
        required: true,
    })
    purpose: string;

    @Prop({ default: 0 })
    attempts: number;

    @Prop({ default: 3 })
    maxAttempts: number;

    @Prop({ type: Date })
    verifiedAt?: Date;

    @Prop({ type: Date, required: true, index: true })
    expiresAt: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const OtpVerificationSchema =
    SchemaFactory.createForClass(OtpVerification);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
OtpVerificationSchema.index({ phone: 1, purpose: 1 });
OtpVerificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index
