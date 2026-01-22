import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CustomerDocument = Customer & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 👥 Customer Schema
 * ═══════════════════════════════════════════════════════════════
 * B2B customers (shop owners, technicians, distributors)
 */
@Schema({
    timestamps: true,
    collection: 'customers',
    toJSON: { virtuals: true },
})
export class Customer {
    @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true })
    userId: Types.ObjectId;

    @Prop({ required: true, unique: true })
    customerCode: string;

    // ═════════════════════════════════════
    // Business Info
    // ═════════════════════════════════════
    @Prop({ required: true })
    responsiblePersonName: string;

    @Prop({ required: true })
    shopName: string;

    @Prop()
    shopNameAr?: string;

    @Prop({
        type: String,
        enum: ['shop', 'technician', 'distributor', 'other'],
        default: 'shop',
    })
    businessType: string;

    // ═════════════════════════════════════
    // Location
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'City', required: false })
    cityId?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Market' })
    marketId?: Types.ObjectId;

    @Prop({ type: String })
    address?: string;

    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;

    // ═════════════════════════════════════
    // Documents
    // ═════════════════════════════════════
    @Prop()
    commercialLicenseFile?: string;

    @Prop()
    commercialLicenseNumber?: string;

    @Prop({ type: Date })
    commercialLicenseExpiry?: Date;

    @Prop()
    taxNumber?: string;

    @Prop()
    nationalId?: string;

    // ═════════════════════════════════════
    // Pricing & Credit
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'PriceLevel', required: true })
    priceLevelId: Types.ObjectId;

    @Prop({ type: Number, default: 0 })
    creditLimit: number;

    @Prop({ type: Number, default: 0 })
    creditUsed: number;

    // ═════════════════════════════════════
    // Wallet
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    walletBalance: number;

    // ═════════════════════════════════════
    // Loyalty
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    loyaltyPoints: number;

    @Prop({
        type: String,
        enum: ['bronze', 'silver', 'gold', 'platinum'],
        default: 'bronze',
    })
    loyaltyTier: string;

    // ═════════════════════════════════════
    // Preferences
    // ═════════════════════════════════════
    @Prop({
        type: String,
        enum: ['cod', 'bank_transfer', 'wallet'],
    })
    preferredPaymentMethod?: string;

    @Prop()
    preferredShippingTime?: string;

    @Prop({
        type: String,
        enum: ['phone', 'whatsapp', 'email'],
        default: 'whatsapp',
    })
    preferredContactMethod: string;

    // ═════════════════════════════════════
    // Social Media
    // ═════════════════════════════════════
    @Prop()
    instagramHandle?: string;

    @Prop()
    twitterHandle?: string;

    // ═════════════════════════════════════
    // Risk Assessment
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 50, min: 0, max: 100 })
    riskScore: number;

    @Prop({ default: false })
    isFlagged: boolean;

    @Prop({ type: String })
    flagReason?: string;

    // ═════════════════════════════════════
    // Assignment
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    assignedSalesRepId?: Types.ObjectId;

    // ═════════════════════════════════════
    // Personal
    // ═════════════════════════════════════
    @Prop({ type: Date })
    birthDate?: Date;

    // ═════════════════════════════════════
    // Statistics
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalOrders: number;

    @Prop({ type: Number, default: 0 })
    totalSpent: number;

    @Prop({ type: Number, default: 0 })
    averageOrderValue: number;

    @Prop({ type: Date })
    lastOrderAt?: Date;

    // ═════════════════════════════════════
    // Admin Notes
    // ═════════════════════════════════════
    @Prop({ type: String })
    internalNotes?: string;

    // ═════════════════════════════════════
    // Approval
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    approvedBy?: Types.ObjectId;

    @Prop({ type: Date })
    approvedAt?: Date;

    @Prop({ type: String })
    rejectionReason?: string;

    // ═════════════════════════════════════
    // Timestamps
    // ═════════════════════════════════════
    createdAt: Date;
    updatedAt: Date;
}

export const CustomerSchema = SchemaFactory.createForClass(Customer);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
CustomerSchema.index({ userId: 1 });
CustomerSchema.index({ customerCode: 1 });
CustomerSchema.index({ cityId: 1 });
CustomerSchema.index({ priceLevelId: 1 });
CustomerSchema.index({ loyaltyTier: 1 });
CustomerSchema.index({ createdAt: -1 });
CustomerSchema.index({ shopName: 'text', shopNameAr: 'text' });

// ═════════════════════════════════════
// Virtual for available credit
// ═════════════════════════════════════
CustomerSchema.virtual('availableCredit').get(function () {
    return this.creditLimit - this.creditUsed;
});

// ═════════════════════════════════════
// Virtual for status (derived from approval fields)
// ═════════════════════════════════════
CustomerSchema.virtual('status').get(function () {
    if (this.rejectionReason) {
        return 'rejected';
    }
    if (this.approvedAt) {
        return 'approved';
    }
    return 'pending';
});

// ═════════════════════════════════════
// Virtual for ID
// ═════════════════════════════════════
CustomerSchema.virtual('id').get(function () {
    return this._id.toHexString();
});
