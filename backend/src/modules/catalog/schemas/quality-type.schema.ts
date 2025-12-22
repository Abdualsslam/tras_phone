import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type QualityTypeDocument = QualityType & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ⭐ Quality Type Schema
 * ═══════════════════════════════════════════════════════════════
 * Product quality levels (Original, OEM, Copy, etc.)
 */
@Schema({
    timestamps: true,
    collection: 'quality_types',
})
export class QualityType {
    @Prop({ required: true })
    name: string; // "Original", "OEM", "AAA Copy", "Copy"

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true })
    code: string; // "original", "oem", "aaa", "copy"

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    // ═════════════════════════════════════
    // Display
    // ═════════════════════════════════════
    @Prop()
    color?: string; // Badge color (hex)

    @Prop()
    icon?: string;

    @Prop({ default: 0 })
    displayOrder: number;

    @Prop({ default: true })
    isActive: boolean;

    // ═════════════════════════════════════
    // Warranty
    // ═════════════════════════════════════
    @Prop({ type: Number })
    defaultWarrantyDays?: number; // Default warranty for this quality

    createdAt: Date;
    updatedAt: Date;
}

export const QualityTypeSchema = SchemaFactory.createForClass(QualityType);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
QualityTypeSchema.index({ code: 1 });
QualityTypeSchema.index({ isActive: 1 });
QualityTypeSchema.index({ displayOrder: 1 });
