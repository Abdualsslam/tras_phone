import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type InvoiceDocument = Invoice & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🧾 Invoice Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'invoices',
})
export class Invoice {
    @Prop({ required: true, unique: true })
    invoiceNumber: string;

    @Prop({ type: Types.ObjectId, ref: 'Order', required: true, index: true })
    orderId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({
        type: String,
        enum: ['draft', 'issued', 'paid', 'partial', 'cancelled', 'refunded'],
        default: 'draft',
    })
    status: string;

    // ═════════════════════════════════════
    // Amounts
    // ═════════════════════════════════════
    @Prop({ type: Number, required: true })
    subtotal: number;

    @Prop({ type: Number, default: 0 })
    taxAmount: number;

    @Prop({ type: Number, default: 0 })
    shippingCost: number;

    @Prop({ type: Number, default: 0 })
    discount: number;

    @Prop({ type: Number, required: true })
    total: number;

    @Prop({ type: Number, default: 0 })
    paidAmount: number;

    // ═════════════════════════════════════
    // Dates
    // ═════════════════════════════════════
    @Prop({ type: Date, required: true })
    issueDate: Date;

    @Prop({ type: Date })
    dueDate?: Date;

    @Prop({ type: Date })
    paidDate?: Date;

    // ═════════════════════════════════════
    // Customer Info Snapshot
    // ═════════════════════════════════════
    @Prop()
    customerName?: string;

    @Prop()
    customerEmail?: string;

    @Prop()
    customerPhone?: string;

    @Prop()
    customerAddress?: string;

    @Prop()
    customerTaxNumber?: string;

    // ═════════════════════════════════════
    // PDF
    // ═════════════════════════════════════
    @Prop()
    pdfUrl?: string;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const InvoiceSchema = SchemaFactory.createForClass(Invoice);

InvoiceSchema.index({ invoiceNumber: 1 });
InvoiceSchema.index({ orderId: 1 });
InvoiceSchema.index({ customerId: 1 });
InvoiceSchema.index({ status: 1 });
InvoiceSchema.index({ issueDate: -1 });
