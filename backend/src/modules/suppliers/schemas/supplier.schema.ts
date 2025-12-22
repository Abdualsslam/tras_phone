import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SupplierDocument = Supplier & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏢 Supplier Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'suppliers',
})
export class Supplier {
    @Prop({ required: true, unique: true })
    code: string;

    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({
        type: String,
        enum: ['manufacturer', 'distributor', 'wholesaler', 'importer'],
        default: 'distributor',
    })
    type: string;

    // ═════════════════════════════════════
    // Contact Information
    // ═════════════════════════════════════
    @Prop()
    contactPerson?: string;

    @Prop()
    email?: string;

    @Prop()
    phone?: string;

    @Prop()
    mobile?: string;

    @Prop()
    website?: string;

    // ═════════════════════════════════════
    // Address
    // ═════════════════════════════════════
    @Prop()
    address?: string;

    @Prop({ type: Types.ObjectId, ref: 'City' })
    cityId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Country' })
    countryId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Business Information
    // ═════════════════════════════════════
    @Prop()
    taxNumber?: string;

    @Prop()
    commercialRegister?: string;

    @Prop()
    bankName?: string;

    @Prop()
    bankAccountNumber?: string;

    @Prop()
    iban?: string;

    // ═════════════════════════════════════
    // Terms
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    paymentTermDays: number; // Net 30, Net 60, etc.

    @Prop({ type: Number, default: 0 })
    creditLimit: number;

    @Prop({ type: Number, default: 0 })
    currentBalance: number; // Amount owed

    @Prop()
    currency?: string;

    // ═════════════════════════════════════
    // Performance
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalOrders: number;

    @Prop({ type: Number, default: 0 })
    totalPurchases: number;

    @Prop({ type: Number, default: 0, min: 0, max: 5 })
    rating: number;

    @Prop({ type: Date })
    lastOrderDate?: Date;

    // ═════════════════════════════════════
    // Status
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isPreferred: boolean;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const SupplierSchema = SchemaFactory.createForClass(Supplier);

SupplierSchema.index({ code: 1 });
SupplierSchema.index({ name: 'text', nameAr: 'text' });
SupplierSchema.index({ isActive: 1 });
SupplierSchema.index({ isPreferred: 1 });
SupplierSchema.index({ type: 1 });
