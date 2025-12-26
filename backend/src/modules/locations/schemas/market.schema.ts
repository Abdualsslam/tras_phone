import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type MarketDocument = Market & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏪 Market Schema
 * ═══════════════════════════════════════════════════════════════
 * Markets/Districts within cities
 */
@Schema({
    timestamps: true,
    collection: 'markets',
})
export class Market {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ type: Types.ObjectId, ref: 'City', required: true, index: true })
    cityId: Types.ObjectId;

    // ═════════════════════════════════════
    // Location Data
    // ═════════════════════════════════════
    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;

    // ═════════════════════════════════════
    // Business Info
    // ═════════════════════════════════════
    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    @Prop({ type: [String] })
    landmarks?: string[]; // nearby landmarks

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    displayOrder: number;

    createdAt: Date;
    updatedAt: Date;
}

export const MarketSchema = SchemaFactory.createForClass(Market);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
MarketSchema.index({ cityId: 1 });
MarketSchema.index({ isActive: 1 });
MarketSchema.index({ name: 'text', nameAr: 'text' });
