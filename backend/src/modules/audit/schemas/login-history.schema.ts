import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type LoginHistoryDocument = LoginHistory & Document;

export enum LoginStatus {
    SUCCESS = 'success',
    FAILED = 'failed',
    BLOCKED = 'blocked',
    EXPIRED = 'expired',
    LOGOUT = 'logout',
}

export enum LoginMethod {
    PASSWORD = 'password',
    OTP = 'otp',
    SOCIAL_GOOGLE = 'social_google',
    SOCIAL_APPLE = 'social_apple',
    BIOMETRIC = 'biometric',
    TOKEN_REFRESH = 'token_refresh',
}

@Schema({ _id: false })
export class DeviceInfo {
    @Prop()
    browser?: string;

    @Prop()
    browserVersion?: string;

    @Prop()
    os?: string;

    @Prop()
    osVersion?: string;

    @Prop()
    device?: string;

    @Prop()
    deviceType?: string; // mobile, tablet, desktop

    @Prop()
    isMobile?: boolean;
}

@Schema({ _id: false })
export class LocationInfo {
    @Prop()
    country?: string;

    @Prop()
    countryCode?: string;

    @Prop()
    city?: string;

    @Prop()
    region?: string;

    @Prop()
    timezone?: string;

    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;
}

@Schema({ timestamps: true })
export class LoginHistory {
    @Prop({
        type: String,
        enum: ['admin', 'customer'],
        required: true
    })
    userType: string;

    @Prop({ type: Types.ObjectId, required: true })
    userId: Types.ObjectId;

    @Prop({ required: true })
    email: string;

    @Prop()
    phone?: string;

    @Prop({
        type: String,
        enum: Object.values(LoginStatus),
        required: true
    })
    status: LoginStatus;

    @Prop({
        type: String,
        enum: Object.values(LoginMethod),
        default: LoginMethod.PASSWORD
    })
    method: LoginMethod;

    @Prop({ required: true })
    ipAddress: string;

    @Prop()
    userAgent?: string;

    @Prop({ type: DeviceInfo })
    device?: DeviceInfo;

    @Prop({ type: LocationInfo })
    location?: LocationInfo;

    // Session
    @Prop()
    sessionId?: string;

    @Prop()
    tokenId?: string;

    // Failure details
    @Prop()
    failureReason?: string;

    @Prop({ default: 0 })
    failedAttempts: number;

    // Security flags
    @Prop({ default: false })
    isSuspicious: boolean;

    @Prop()
    suspiciousReason?: string;

    @Prop({ default: false })
    isNewDevice: boolean;

    @Prop({ default: false })
    isNewLocation: boolean;

    // Logout info
    @Prop()
    logoutAt?: Date;

    @Prop({
        type: String,
        enum: ['user', 'timeout', 'forced', 'token_expired']
    })
    logoutReason?: string;
}

export const LoginHistorySchema = SchemaFactory.createForClass(LoginHistory);

LoginHistorySchema.index({ userId: 1, userType: 1, createdAt: -1 });
LoginHistorySchema.index({ email: 1, createdAt: -1 });
LoginHistorySchema.index({ ipAddress: 1, createdAt: -1 });
LoginHistorySchema.index({ status: 1, createdAt: -1 });
LoginHistorySchema.index({ isSuspicious: 1 });
LoginHistorySchema.index({ createdAt: -1 });
