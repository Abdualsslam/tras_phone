import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type StockLocationDocument = StockLocation & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📍 Stock Location Schema (Bins/Shelves within Warehouse)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'stock_locations',
})
export class StockLocation {
    @Prop({ type: Types.ObjectId, ref: 'Warehouse', required: true, index: true })
    warehouseId: Types.ObjectId;

    @Prop({ required: true })
    name: string; // e.g., "A-01-01" (Zone-Row-Shelf)

    @Prop()
    zone?: string;

    @Prop()
    row?: string;

    @Prop()
    shelf?: string;

    @Prop()
    bin?: string;

    @Prop({
        type: String,
        enum: ['picking', 'bulk', 'damaged', 'returns', 'staging'],
        default: 'bulk',
    })
    locationType: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ type: Number, default: 0 })
    currentQuantity: number;

    createdAt: Date;
    updatedAt: Date;
}

export const StockLocationSchema = SchemaFactory.createForClass(StockLocation);

StockLocationSchema.index({ warehouseId: 1, name: 1 }, { unique: true });
StockLocationSchema.index({ locationType: 1 });
