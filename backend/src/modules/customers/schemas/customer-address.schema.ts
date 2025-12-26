import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CustomerAddressDocument = CustomerAddress & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📍 Customer Address Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'customer_addresses',
})
export class CustomerAddress {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ required: true })
    label: string;

    @Prop()
    recipientName?: string;

    @Prop()
    phone?: string;

    @Prop({ type: Types.ObjectId, ref: 'City', required: true })
    cityId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Market' })
    marketId?: Types.ObjectId;

    @Prop({ required: true, type: String })
    addressLine: string;

    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;

    @Prop({ default: false })
    isDefault: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const CustomerAddressSchema =
    SchemaFactory.createForClass(CustomerAddress);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
CustomerAddressSchema.index({ customerId: 1 });
CustomerAddressSchema.index({ customerId: 1, isDefault: 1 });
