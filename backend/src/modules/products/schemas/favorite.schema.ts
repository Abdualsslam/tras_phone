import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FavoriteDocument = Favorite & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * ❤️ Favorite Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'favorites',
})
export class Favorite {
    @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
    customerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
    productId: Types.ObjectId;

    @Prop()
    note?: string;

    @Prop({ default: false })
    notifyOnPriceChange: boolean;

    @Prop({ default: false })
    notifyOnBackInStock: boolean;

    createdAt: Date;
}

export const FavoriteSchema = SchemaFactory.createForClass(Favorite);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
FavoriteSchema.index({ customerId: 1, productId: 1 }, { unique: true });
