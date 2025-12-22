import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WarehouseDocument = Warehouse & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏭 Warehouse Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'warehouses',
})
export class Warehouse {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    nameAr: string;

    @Prop({ required: true, unique: true })
    code: string;

    @Prop()
    description?: string;

    // ═════════════════════════════════════
    // Location
    // ═════════════════════════════════════
    @Prop({ type: Types.ObjectId, ref: 'City' })
    cityId?: Types.ObjectId;

    @Prop()
    address?: string;

    @Prop({ type: Number })
    latitude?: number;

    @Prop({ type: Number })
    longitude?: number;

    // ═════════════════════════════════════
    // Contact
    // ═════════════════════════════════════
    @Prop()
    phone?: string;

    @Prop()
    email?: string;

    @Prop()
    managerName?: string;

    // ═════════════════════════════════════
    // Settings
    // ═════════════════════════════════════
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isDefault: boolean; // Primary warehouse

    @Prop({ default: true })
    allowNegativeStock: boolean;

    @Prop({ default: true })
    trackSerialNumbers: boolean;

    // ═════════════════════════════════════
    // Statistics
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalProducts: number;

    @Prop({ type: Number, default: 0 })
    totalQuantity: number;

    @Prop({ type: Number, default: 0 })
    totalValue: number;

    createdAt: Date;
    updatedAt: Date;
}

export const WarehouseSchema = SchemaFactory.createForClass(Warehouse);

WarehouseSchema.index({ code: 1 });
WarehouseSchema.index({ isActive: 1 });
WarehouseSchema.index({ isDefault: 1 });
WarehouseSchema.index({ cityId: 1 });
