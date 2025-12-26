import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderItemDocument = OrderItem & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Order Item Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'order_items',
})
export class OrderItem {
    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    // ═════════════════════════════════════
    // Product Snapshot
    // ═════════════════════════════════════
    @Prop({ required: true })
    productSku: string;

    @Prop({ required: true })
    productName: string;

    @Prop()
    productNameAr?: string;

    @Prop()
    productImage?: string;

    // ═════════════════════════════════════
    // Quantity
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    quantity: number;

    @Prop({ type: Number, default: 0 })
    shippedQuantity: number;

    @Prop({ type: Number, default: 0 })
    returnedQuantity: number;

    // ═════════════════════════════════════
    // Pricing
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    unitPrice: number;

    @Prop({ type: Number, default: 0 })
    discount: number;

    @Prop({ type: Number })
    taxRate?: number;

    @Prop({ type: Number, default: 0 })
    taxAmount: number;

    @Prop({ type: Number, required: true })
    totalPrice: number;

    // ═════════════════════════════════════
    // Cost (for profit)
    // ═════════════════════════════════════
    @Prop({ type: Number })
    costPrice?: number;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned'],
        default: 'pending',
    })
    status: string;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const OrderItemSchema = SchemaFactory.createForClass(OrderItem);

OrderItemSchema.index({ orderId: 1 });
OrderItemSchema.index({ productId: 1 });
OrderItemSchema.index({ status: 1 });
