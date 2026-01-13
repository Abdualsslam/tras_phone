import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type DeviceDocument = Device & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 Device Schema (Phone Models)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'devices',
})
export class Device {
    @Prop({ type: Types.ObjectId, ref: 'Brand', required: true, index: true })
    brandId: Types.ObjectId;

    @Prop({ required: true })
    name: string; // e.g., "iPhone 15 Pro Max"

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true, lowercase: true })
    slug: string;

    @Prop()
    modelNumber?: string; // e.g., "A2849"

    @Prop()
    image?: string;

    // ═════════════════════════════════════
    // Device Specifications (for compatibility)
    // ═════════════════════════════════════
    @Prop()
    screenSize?: string; // e.g., "6.7 inch"

    @Prop()
    releaseYear?: number;

    @Prop({ type: [String] })
    colors?: string[];

    @Prop({ type: [String] })
    storageOptions?: string[]; // ["128GB", "256GB", "512GB", "1TB"]

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isPopular: boolean;

    @Prop({ default: 0 })
    displayOrder: number;

    // ═════════════════════════════════════
    // Statistics
    // ═════════════════════════════════════
    @Prop({ default: 0 })
    productsCount: number;

    createdAt: Date;
    updatedAt: Date;
}

export const DeviceSchema = SchemaFactory.createForClass(Device);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
DeviceSchema.index({ brandId: 1 });
// Note: 'slug' index is automatically created by unique: true
DeviceSchema.index({ isActive: 1 });
DeviceSchema.index({ isPopular: 1 });
DeviceSchema.index({ releaseYear: -1 });
DeviceSchema.index({ name: 'text', nameAr: 'text' });
