import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReportDocument = Report & Document;

export enum ReportType {
    SALES = 'sales',
    ORDERS = 'orders',
    CUSTOMERS = 'customers',
    PRODUCTS = 'products',
    INVENTORY = 'inventory',
    RETURNS = 'returns',
    PAYMENTS = 'payments',
    PROMOTIONS = 'promotions',
    SUPPORT = 'support',
    CUSTOM = 'custom',
}

export enum ReportStatus {
    PENDING = 'pending',
    PROCESSING = 'processing',
    COMPLETED = 'completed',
    FAILED = 'failed',
}

export enum ReportFormat {
    PDF = 'pdf',
    EXCEL = 'excel',
    CSV = 'csv',
    JSON = 'json',
}

@Schema({ timestamps: true })
export class Report {
    @Prop({ required: true, trim: true })
    name: string;

    @Prop({
        type: String,
        enum: Object.values(ReportType),
        required: true
    })
    type: ReportType;

    @Prop({
        type: String,
        enum: Object.values(ReportStatus),
        default: ReportStatus.PENDING
    })
    status: ReportStatus;

    @Prop({
        type: String,
        enum: Object.values(ReportFormat),
        default: ReportFormat.EXCEL
    })
    format: ReportFormat;

    // Date range
    @Prop({ required: true })
    startDate: Date;

    @Prop({ required: true })
    endDate: Date;

    // Filters applied
    @Prop({ type: Object, default: {} })
    filters: Record<string, any>;

    // Columns/metrics to include
    @Prop({ type: [String], default: [] })
    columns: string[];

    // Grouping
    @Prop({
        type: String,
        enum: ['day', 'week', 'month', 'category', 'product', 'customer', 'city', 'none'],
        default: 'day'
    })
    groupBy: string;

    // Output
    @Prop()
    fileUrl?: string;

    @Prop()
    fileSize?: number;

    @Prop({ type: Object })
    summary?: Record<string, any>;

    @Prop({ default: 0 })
    rowCount: number;

    // Processing
    @Prop()
    startedAt?: Date;

    @Prop()
    completedAt?: Date;

    @Prop()
    error?: string;

    // Scheduling
    @Prop({ default: false })
    isScheduled: boolean;

    @Prop({
        type: String,
        enum: ['daily', 'weekly', 'monthly']
    })
    scheduleFrequency?: string;

    @Prop()
    nextRunAt?: Date;

    @Prop({ type: [String], default: [] })
    emailRecipients: string[];

    @Prop({ type: Types.ObjectId, ref: 'Admin', required: true })
    createdBy: Types.ObjectId;
}

export const ReportSchema = SchemaFactory.createForClass(Report);

ReportSchema.index({ type: 1, status: 1 });
ReportSchema.index({ createdBy: 1, createdAt: -1 });
ReportSchema.index({ isScheduled: 1, nextRunAt: 1 });
