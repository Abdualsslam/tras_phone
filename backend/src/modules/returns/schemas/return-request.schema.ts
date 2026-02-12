import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReturnRequestDocument = ReturnRequest & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔄 Return Request Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'return_requests',
})
export class ReturnRequest {
    @Prop({ required: true, unique: true })
    returnNumber: string;

    @Prop({ type: [Types.ObjectId], ref: 'Order', required: true, index: true })
    orderIds: Types.ObjectId[];

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({
        type: String,
        enum: [
            'pending',        // في انتظار المراجعة
            'approved',       // تمت الموافقة
            'rejected',       // مرفوض
            'pickup_scheduled', // تم جدولة الاستلام
            'picked_up',      // تم الاستلام
            'inspecting',     // قيد الفحص
            'completed',      // مكتمل
            'cancelled',      // ملغي
        ],
        default: 'pending',
    })
    status: string;

    @Prop({
        type: String,
        enum: ['refund', 'exchange', 'store_credit'],
        required: true,
    })
    returnType: string;

    @Prop({ type: Types.ObjectId, ref: 'ReturnReason', required: true })
    reasonId: Types.ObjectId;

    @Prop()
    customerNotes?: string;

    @Prop({ type: [String] })
    customerImages?: string[]; // Photos of items to return

    // ═════════════════════════════════════
    // Amounts
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalItemsValue: number;

    @Prop({ type: Number, default: 0 })
    restockingFee: number;

    @Prop({ type: Number, default: 0 })
    shippingDeduction: number;

    @Prop({ type: Number, default: 0 })
    refundAmount: number;

    // ═════════════════════════════════════
    // Pickup
    // ═════════════════════════════════════
    @Prop({ type: Date })
    scheduledPickupDate?: Date;

    @Prop()
    pickupTrackingNumber?: string;

    // ═════════════════════════════════════
    // Exchange (if returnType = 'exchange')
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'Order' })
    exchangeOrderId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Processing
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    processedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    @Prop({ type: Date })
    rejectedAt?: Date;

    @Prop()
    rejectionReason?: string;

    @Prop({ type: Date })
    completedAt?: Date;

    @Prop()
    internalNotes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const ReturnRequestSchema = SchemaFactory.createForClass(ReturnRequest);

ReturnRequestSchema.index({ returnNumber: 1 });
ReturnRequestSchema.index({ orderIds: 1 });
ReturnRequestSchema.index({ customerId: 1 });
ReturnRequestSchema.index({ status: 1 });
ReturnRequestSchema.index({ createdAt: -1 });
