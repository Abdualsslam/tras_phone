import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SupplierProductDocument = SupplierProduct & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Supplier Product Schema (Products offered by suppliers)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'supplier_products',
})
export class SupplierProduct {
    @Prop({ type: Types.ObjectId, ref: 'Supplier', required: true, index: true })
    supplierId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop()
    supplierSku?: string; // Supplier's SKU

    @Prop({ type: Number, required: true })
    costPrice: number;

    @Prop({ type: Number })
    minOrderQuantity?: number;

    @Prop({ type: Number })
    leadTimeDays?: number; // Days to receive

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isPreferred: boolean; // Preferred supplier for this product

    @Prop({ type: Date })
    lastPurchaseDate?: Date;

    @Prop({ type: Number, default: 0 })
    totalPurchased: number;

    @Prop()
    notes?: string;

    createdAt: Date;
    updatedAt: Date;
}

export const SupplierProductSchema = SchemaFactory.createForClass(SupplierProduct);

SupplierProductSchema.index({ supplierId: 1, productId: 1 }, { unique: true });
SupplierProductSchema.index({ productId: 1, isPreferred: 1 });
