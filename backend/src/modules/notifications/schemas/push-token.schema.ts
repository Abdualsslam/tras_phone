import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PushTokenDocument = PushToken & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 Push Token Schema (FCM/APNS)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'push_tokens',
})
export class PushToken {
    @Prop({ type: Types.ObjectId, ref: 'Customer', index: true })
    customerId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser', index: true })
    adminUserId?: Types.ObjectId;

    @Prop({ required: true })
    token: string;

    @Prop({
        required: true,
        type: String,
        enum: ['fcm', 'apns', 'web'],
    })
    provider: string;

    @Prop({
        type: String,
        enum: ['ios', 'android', 'web'],
        required: true,
    })
    platform: string;

    @Prop()
    deviceId?: string;

    @Prop()
    deviceName?: string;

    @Prop()
    deviceModel?: string;

    @Prop()
    appVersion?: string;

    @Prop()
    osVersion?: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ type: Date })
    lastUsedAt?: Date;

    @Prop({ type: Date })
    invalidatedAt?: Date;

    @Prop()
    invalidReason?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const PushTokenSchema = SchemaFactory.createForClass(PushToken);

PushTokenSchema.index({ token: 1 }, { unique: true });
PushTokenSchema.index({ customerId: 1, isActive: 1 });
PushTokenSchema.index({ adminUserId: 1, isActive: 1 });
PushTokenSchema.index({ platform: 1 });
