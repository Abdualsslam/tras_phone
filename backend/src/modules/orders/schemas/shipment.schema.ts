import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ShipmentDocument = Shipment & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🚚 Shipment Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'shipments',
})
export class Shipment {
    @Prop({ required: true, unique: true })
    shipmentNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Warehouse' })
    warehouseId?: Types.ObjectId;

    @Prop({
        type: String,
        enum: ['pending', 'picked', 'packed', 'shipped', 'in_transit', 'out_for_delivery', 'delivered', 'failed', 'returned'],
        default: 'pending',
    })
    status: string;

    // ═════════════════════════════════════
    // Carrier
    // ═════════════════════════════════════
    @Prop()
    carrier?: string; // SMSA, Aramex, etc.

    @Prop()
    trackingNumber?: string;

    @Prop()
    trackingUrl?: string;

    // ═════════════════════════════════════
    // Shipping Address
    // ═════════════════════════════════════
    @Prop({ type: Object })
    shippingAddress: {
        fullName: string;
        phone: string;
        address: string;
        city: string;
        district?: string;
        postalCode?: string;
        notes?: string;
        latitude?: number;
        longitude?: number;
    };

    // ═════════════════════════════════════
    // Items
    // ═════════════════════════════════════
    @Prop({
        type: [{
            orderItemId: { type: Types.ObjectId, ref: 'OrderItem', required: true },
            productId: { type: Types.ObjectId, ref: 'Product', required: true },
            quantity: { type: Number, required: true },
        }],
        default: [],
    })
    items: {
        orderItemId: Types.ObjectId;
        productId: Types.ObjectId;
        quantity: number;
    }[];

    // ═════════════════════════════════════
    // Package
    // ═════════════════════════════════════
    @Prop({ type: Number })
    weight?: number; // in kg

    @Prop()
    dimensions?: string; // LxWxH

    @Prop({ type: Number })
    packagesCount?: number;

    // ═════════════════════════════════════
    // Cost
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    shippingCost: number;

    @Prop({ default: false })
    isCOD: boolean; // Cash on delivery

    @Prop({ type: Number })
    codAmount?: number;

    // ═════════════════════════════════════
    // Dates
    // ═════════════════════════════════════
    @Prop({ type: Date })
    pickedAt?: Date;

    @Prop({ type: Date })
    packedAt?: Date;

    @Prop({ type: Date })
    shippedAt?: Date;

    @Prop({ type: Date })
    estimatedDeliveryDate?: Date;

    @Prop({ type: Date })
    deliveredAt?: Date;

    // ═════════════════════════════════════
    // Proof
    // ═════════════════════════════════════
    @Prop()
    deliveryProofImage?: string;

    @Prop()
    recipientName?: string;

    @Prop()
    recipientSignature?: string;

    @Prop()
    notes?: string;

    @Prop()
    failureReason?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const ShipmentSchema = SchemaFactory.createForClass(Shipment);

ShipmentSchema.index({ shipmentNumber: 1 });
ShipmentSchema.index({ orderId: 1 });
ShipmentSchema.index({ trackingNumber: 1 });
ShipmentSchema.index({ status: 1 });
ShipmentSchema.index({ createdAt: -1 });
