import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CustomerPriceLevelHistoryDocument =
    CustomerPriceLevelHistory & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Customer Price Level History Schema
 * ═══════════════════════════════════════════════════════════════
 * Track changes in customer price levels over time
 */
@Schema({
    timestamps: true,
    collection: 'customer_price_level_history',
})
export class CustomerPriceLevelHistory {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'PriceLevel' })
    fromPriceLevelId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'PriceLevel', required: true })
    toPriceLevelId: Types.ObjectId;

    @Prop()
    reason?: string;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    changedBy?: Types.ObjectId;

    createdAt: Date;
}

export const CustomerPriceLevelHistorySchema = SchemaFactory.createForClass(
    CustomerPriceLevelHistory,
);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
CustomerPriceLevelHistorySchema.index({ customerId: 1 });
CustomerPriceLevelHistorySchema.index({ createdAt: -1 });
