import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type DailyStatsDocument = DailyStats & Document;

@Schema({ _id: false })
export class SalesStats {
    @Prop({ default: 0 })
    totalOrders: number;

    @Prop({ default: 0 })
    completedOrders: number;

    @Prop({ default: 0 })
    cancelledOrders: number;

    @Prop({ default: 0 })
    returnedOrders: number;

    @Prop({ default: 0 })
    grossRevenue: number;

    @Prop({ default: 0 })
    discounts: number;

    @Prop({ default: 0 })
    shipping: number;

    @Prop({ default: 0 })
    tax: number;

    @Prop({ default: 0 })
    netRevenue: number;

    @Prop({ default: 0 })
    refunds: number;

    @Prop({ default: 0 })
    averageOrderValue: number;

    @Prop({ default: 0 })
    itemsSold: number;
}

@Schema({ _id: false })
export class CustomerStats {
    @Prop({ default: 0 })
    newCustomers: number;

    @Prop({ default: 0 })
    returningCustomers: number;

    @Prop({ default: 0 })
    totalActiveCustomers: number;

    @Prop({ default: 0 })
    guestCheckouts: number;
}

@Schema({ _id: false })
export class TrafficStats {
    @Prop({ default: 0 })
    pageViews: number;

    @Prop({ default: 0 })
    uniqueVisitors: number;

    @Prop({ default: 0 })
    sessions: number;

    @Prop({ default: 0 })
    bounceRate: number;

    @Prop({ default: 0 })
    avgSessionDuration: number; // seconds
}

@Schema({ _id: false })
export class ConversionStats {
    @Prop({ default: 0 })
    addToCartCount: number;

    @Prop({ default: 0 })
    checkoutInitiated: number;

    @Prop({ default: 0 })
    checkoutCompleted: number;

    @Prop({ default: 0 })
    cartAbandonmentRate: number;

    @Prop({ default: 0 })
    conversionRate: number;
}

@Schema({ timestamps: true })
export class DailyStats {
    @Prop({ required: true })
    date: Date; // Date at midnight

    @Prop({ type: SalesStats, default: {} })
    sales: SalesStats;

    @Prop({ type: CustomerStats, default: {} })
    customers: CustomerStats;

    @Prop({ type: TrafficStats, default: {} })
    traffic: TrafficStats;

    @Prop({ type: ConversionStats, default: {} })
    conversion: ConversionStats;

    // Top items
    @Prop({ type: [{ productId: Types.ObjectId, name: String, quantity: Number, revenue: Number }], default: [] })
    topProducts: Array<{ productId: Types.ObjectId; name: string; quantity: number; revenue: number }>;

    @Prop({ type: [{ categoryId: Types.ObjectId, name: String, revenue: Number }], default: [] })
    topCategories: Array<{ categoryId: Types.ObjectId; name: string; revenue: number }>;

    // Payment breakdown
    @Prop({ type: Object, default: {} })
    paymentMethods: Record<string, { count: number; amount: number }>;

    // Geographic breakdown
    @Prop({ type: Object, default: {} })
    ordersByCity: Record<string, number>;
}

export const DailyStatsSchema = SchemaFactory.createForClass(DailyStats);

DailyStatsSchema.index({ date: 1 }, { unique: true });
