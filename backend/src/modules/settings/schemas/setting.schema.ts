import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SettingDocument = Setting & Document;

export enum SettingType {
    STRING = 'string',
    NUMBER = 'number',
    BOOLEAN = 'boolean',
    JSON = 'json',
    ARRAY = 'array',
    IMAGE = 'image',
    COLOR = 'color',
    EMAIL = 'email',
    URL = 'url',
    TEXTAREA = 'textarea',
    WYSIWYG = 'wysiwyg',
}

export enum SettingGroup {
    GENERAL = 'general',
    STORE = 'store',
    PAYMENT = 'payment',
    SHIPPING = 'shipping',
    EMAIL = 'email',
    SMS = 'sms',
    SOCIAL = 'social',
    SEO = 'seo',
    SECURITY = 'security',
    NOTIFICATION = 'notification',
    LOYALTY = 'loyalty',
    CHECKOUT = 'checkout',
    INVENTORY = 'inventory',
    INTEGRATION = 'integration',
}

@Schema({ timestamps: true })
export class Setting {
    @Prop({ required: true, unique: true, lowercase: true })
    key: string;

    @Prop({ required: true })
    labelAr: string;

    @Prop({ required: true })
    labelEn: string;

    @Prop()
    descriptionAr?: string;

    @Prop()
    descriptionEn?: string;

    @Prop({ type: Object, default: null })
    value: any;

    @Prop({ type: Object })
    defaultValue?: any;

    @Prop({
        type: String,
        enum: Object.values(SettingType),
        default: SettingType.STRING
    })
    type: SettingType;

    @Prop({
        type: String,
        enum: Object.values(SettingGroup),
        required: true
    })
    group: SettingGroup;

    @Prop({ default: 0 })
    sortOrder: number;

    // Validation
    @Prop({ type: [String] })
    options?: string[]; // For select type

    @Prop()
    minValue?: number;

    @Prop()
    maxValue?: number;

    @Prop()
    regex?: string;

    @Prop({ default: false })
    isRequired: boolean;

    // Access control
    @Prop({ default: false })
    isProtected: boolean; // Cannot be deleted

    @Prop({ default: false })
    isEncrypted: boolean; // Value is encrypted (for API keys, passwords)

    @Prop({ default: true })
    isEditable: boolean;

    @Prop({ default: true })
    isVisible: boolean;

    // Audit
    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    lastUpdatedBy?: Types.ObjectId;
}

export const SettingSchema = SchemaFactory.createForClass(Setting);

SettingSchema.index({ key: 1 }, { unique: true });
SettingSchema.index({ group: 1, sortOrder: 1 });
