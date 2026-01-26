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

    @Prop({ type: Types.ObjectId, ref: 'City' })
    cityId?: Types.ObjectId;

    @Prop()
    cityName?: string;

    @Prop()
    marketName?: string;

    @Prop({ required: true, type: String })
    addressLine: string;

    @Prop({ type: Number, required: true })
    latitude: number;

    @Prop({ type: Number, required: true })
    longitude: number;

    @Prop()
    notes?: string;

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
