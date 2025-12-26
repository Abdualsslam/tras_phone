import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type UserSessionDocument = UserSession & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 User Session Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'user_sessions',
})
export class UserSession {
    @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
    userId: Types.ObjectId;

    @Prop({ required: true, unique: true })
    tokenId: string;

    // Device Info
    @Prop()
    deviceType?: string;

    @Prop()
    deviceName?: string;

    @Prop()
    deviceId?: string;

    @Prop()
    appVersion?: string;

    // Location
    @Prop()
    ipAddress?: string;

    @Prop({ type: String })
    userAgent?: string;

    // Activity
    @Prop({ type: Date, default: Date.now })
    lastActivityAt: Date;

    @Prop({ type: Date, required: true, index: true })
    expiresAt: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const UserSessionSchema = SchemaFactory.createForClass(UserSession);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
UserSessionSchema.index({ tokenId: 1 });
UserSessionSchema.index({ userId: 1, expiresAt: 1 });
UserSessionSchema.index({ deviceId: 1 });
UserSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index
