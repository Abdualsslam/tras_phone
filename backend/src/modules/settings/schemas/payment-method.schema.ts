import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PaymentMethodDocument = PaymentMethod & Document;

export enum PaymentMethodType {
    CASH_ON_DELIVERY = 'cash_on_delivery',
    CREDIT_CARD = 'credit_card',
    MADA = 'mada',
    APPLE_PAY = 'apple_pay',
    STC_PAY = 'stc_pay',
    BANK_TRANSFER = 'bank_transfer',
    WALLET = 'wallet',
    INSTALLMENT = 'installment',
}

@Schema({ _id: false })
export class PaymentGatewayConfig {
    @Prop()
    merchantId?: string;

    @Prop()
    apiKey?: string;

    @Prop()
    secretKey?: string;

    @Prop()
    publicKey?: string;

    @Prop()
    webhookSecret?: string;

    @Prop({ default: false })
    testMode: boolean;

    @Prop()
    callbackUrl?: string;

    @Prop({ type: Object })
    additionalConfig?: Record<string, any>;
}

@Schema({ timestamps: true })
export class PaymentMethod {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({
        type: String,
        enum: Object.values(PaymentMethodType),
        required: true,
        unique: true
    })
    type: PaymentMethodType;

    @Prop()
    descriptionAr?: string;

    @Prop()
    descriptionEn?: string;

    @Prop()
    icon?: string;

    @Prop()
    logo?: string;

    // Gateway configuration
    @Prop({
        type: String,
        enum: ['hyperpay', 'moyasar', 'tap', 'payfort', 'internal', 'none']
    })
    gateway?: string;

    @Prop({ type: PaymentGatewayConfig })
    gatewayConfig?: PaymentGatewayConfig;

    // Fees
    @Prop({ default: 0 })
    fixedFee: number;

    @Prop({ default: 0 })
    percentageFee: number;

    // Limits
    @Prop({ default: 0 })
    minAmount: number;

    @Prop()
    maxAmount?: number;

    // Availability
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Country' }] })
    countries?: Types.ObjectId[];

    @Prop({ type: [String], default: ['web', 'mobile'] })
    platforms: string[];

    @Prop({ default: 0 })
    sortOrder: number;

    // Instructions
    @Prop()
    instructionsAr?: string;

    @Prop()
    instructionsEn?: string;

    // For bank transfer
    @Prop({ type: Object })
    bankDetails?: {
        bankNameAr?: string;
        bankNameEn?: string;
        accountName?: string;
        accountNumber?: string;
        iban?: string;
        swiftCode?: string;
    };

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    lastUpdatedBy?: Types.ObjectId;
}

export const PaymentMethodSchema = SchemaFactory.createForClass(PaymentMethod);

// Note: 'type' index is automatically created by unique: true
PaymentMethodSchema.index({ isActive: 1, sortOrder: 1 });
