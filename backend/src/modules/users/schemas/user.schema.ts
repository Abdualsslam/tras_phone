import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

export type UserDocument = User & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 👤 User Schema (Base for all user types)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'users',
    toJSON: {
        virtuals: true,
        transform: function (doc: any, ret: any) {
            delete ret.password;
            delete ret.twoFactorSecret;
            delete ret.__v;
            return ret;
        },
    },
})
export class User {
    @Prop({ type: String, default: () => uuidv4() })
    uuid: string;

    @Prop({ required: true, unique: true, trim: true })
    phone: string;

    @Prop({ unique: true, sparse: true, trim: true, lowercase: true })
    email?: string;

    @Prop({ required: true, select: false })
    password: string;

    @Prop({
        type: String,
        enum: ['customer', 'admin'],
        required: true
    })
    userType: string;

    @Prop({
        type: String,
        enum: ['pending', 'active', 'suspended', 'deleted'],
        default: 'pending'
    })
    status: string;

    // ═════════════════════════════════════
    // Profile
    // ═════════════════════════════════════
    @Prop()
    avatar?: string;

    // ═════════════════════════════════════
    // Verification
    // ═════════════════════════════════════
    @Prop({ type: Date })
    phoneVerifiedAt?: Date;

    @Prop({ type: Date })
    emailVerifiedAt?: Date;

    // ═════════════════════════════════════
    // Two Factor Authentication
    // ═════════════════════════════════════
    @Prop({ default: false })
    twoFactorEnabled: boolean;

    @Prop({ select: false })
    twoFactorSecret?: string;

    // ═════════════════════════════════════
    // Social Login
    // ═════════════════════════════════════
    @Prop()
    googleId?: string;

    @Prop()
    appleId?: string;

    // ═════════════════════════════════════
    // Login Tracking
    // ═════════════════════════════════════
    @Prop({ type: Date })
    lastLoginAt?: Date;

    @Prop()
    lastLoginIp?: string;

    @Prop({ default: 0 })
    failedLoginAttempts: number;

    @Prop({ type: Date })
    lockedUntil?: Date;

    // ═════════════════════════════════════
    // Device & FCM
    // ═════════════════════════════════════
    @Prop()
    fcmToken?: string;

    @Prop({ type: Object })
    deviceInfo?: Record<string, any>;

    // ═════════════════════════════════════
    // Preferences
    // ═════════════════════════════════════
    @Prop({ default: 'ar' })
    language: string;

    @Prop({ default: 'Asia/Riyadh' })
    timezone: string;

    @Prop({ type: Object })
    notificationPreferences?: Record<string, any>;

    // ═════════════════════════════════════
    // Marketing
    // ═════════════════════════════════════
    @Prop({ default: true })
    acceptsMarketing: boolean;

    @Prop({ type: Date })
    marketingConsentAt?: Date;

    // ═════════════════════════════════════
    // Referral
    // ═════════════════════════════════════
    @Prop({ unique: true, sparse: true })
    referralCode?: string;

    @Prop({ type: String, ref: 'User' })
    referredBy?: string;

    // ═════════════════════════════════════
    // Timestamps
    // ═════════════════════════════════════
    @Prop({ type: Date })
    deletedAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
UserSchema.index({ phone: 1 });
UserSchema.index({ email: 1 });
UserSchema.index({ uuid: 1 });
UserSchema.index({ userType: 1, status: 1 });
UserSchema.index({ referralCode: 1 });
UserSchema.index({ googleId: 1 });
UserSchema.index({ appleId: 1 });
UserSchema.index({ createdAt: -1 });

// ═════════════════════════════════════
// Virtual for ID
// ═════════════════════════════════════
UserSchema.virtual('id').get(function () {
    return this._id.toHexString();
});
