import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SearchAnalyticsDocument = SearchAnalytics & Document;

@Schema({ timestamps: true })
export class SearchAnalytics {
    @Prop({ required: true, lowercase: true, trim: true })
    query: string;

    @Prop({ required: true })
    date: Date;

    @Prop({ default: 0 })
    searchCount: number;

    @Prop({ default: 0 })
    resultsCount: number; // Average results returned

    @Prop({ default: 0 })
    clickCount: number; // Clicks on results

    @Prop({ default: 0 })
    purchaseCount: number; // Purchases from search

    @Prop({ default: 0 })
    noResultsCount: number;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Product' }], default: [] })
    topClickedProducts: Types.ObjectId[];

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Product' }], default: [] })
    topPurchasedProducts: Types.ObjectId[];

    // Refinements
    @Prop({ type: [String], default: [] })
    filters: string[]; // Filters applied after search

    @Prop({ type: [String], default: [] })
    sortOptions: string[]; // Sort options used
}

export const SearchAnalyticsSchema = SchemaFactory.createForClass(SearchAnalytics);

SearchAnalyticsSchema.index({ query: 1, date: 1 }, { unique: true });
SearchAnalyticsSchema.index({ date: 1 });
SearchAnalyticsSchema.index({ searchCount: -1 });
