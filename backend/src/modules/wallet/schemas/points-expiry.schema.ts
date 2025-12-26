import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PointsExpiryDocument = PointsExpiry & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ⏰ Points Expiry Schema (Track expiring points)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'points_expiry',
})
export class PointsExpiry {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'LoyaltyTransaction', required: true })
    transactionId: Types.ObjectId;

    @Prop({ type: Number, required: true })
    originalPoints: number;

    @Prop({ type: Number, required: true })
    remainingPoints: number;

    @Prop({ type: Date, required: true, index: true })
    expiresAt: Date;

    @Prop({ default: false })
    isExpired: boolean;

    @Prop({ default: false })
    isNotified: boolean; // Expiry reminder sent

    @Prop({ type: Date })
    notifiedAt?: Date;

    createdAt: Date;
}

export const PointsExpirySchema = SchemaFactory.createForClass(PointsExpiry);

PointsExpirySchema.index({ customerId: 1, expiresAt: 1 });
PointsExpirySchema.index({ expiresAt: 1, isExpired: 1 });
PointsExpirySchema.index({ isNotified: 1, expiresAt: 1 });
