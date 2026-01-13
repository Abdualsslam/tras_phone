import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PageDocument = Page & Document;

export enum PageStatus {
    DRAFT = 'draft',
    PUBLISHED = 'published',
    SCHEDULED = 'scheduled',
    ARCHIVED = 'archived',
}

export enum PageType {
    STATIC = 'static',
    POLICY = 'policy',
    ABOUT = 'about',
    LANDING = 'landing',
    CUSTOM = 'custom',
}

@Schema({ _id: false })
export class PageSeo {
    @Prop()
    titleAr?: string;

    @Prop()
    titleEn?: string;

    @Prop()
    descriptionAr?: string;

    @Prop()
    descriptionEn?: string;

    @Prop({ type: [String] })
    keywordsAr?: string[];

    @Prop({ type: [String] })
    keywordsEn?: string[];

    @Prop()
    ogImage?: string;

    @Prop({ default: true })
    indexable: boolean;

    @Prop()
    canonicalUrl?: string;
}

@Schema({ timestamps: true })
export class Page {
    @Prop({ required: true, trim: true })
    titleAr: string;

    @Prop({ required: true, trim: true })
    titleEn: string;

    @Prop({ required: true, unique: true, lowercase: true })
    slug: string;

    @Prop({
        type: String,
        enum: Object.values(PageType),
        default: PageType.STATIC
    })
    type: PageType;

    @Prop({ required: true })
    contentAr: string;

    @Prop({ required: true })
    contentEn: string;

    @Prop()
    excerptAr?: string;

    @Prop()
    excerptEn?: string;

    @Prop()
    featuredImage?: string;

    @Prop({
        type: String,
        enum: Object.values(PageStatus),
        default: PageStatus.DRAFT
    })
    status: PageStatus;

    @Prop()
    publishedAt?: Date;

    @Prop()
    scheduledAt?: Date;

    // SEO
    @Prop({ type: PageSeo, default: {} })
    seo: PageSeo;

    // Template
    @Prop({ default: 'default' })
    template: string;

    // Settings
    @Prop({ default: true })
    showInFooter: boolean;

    @Prop({ default: false })
    showInHeader: boolean;

    @Prop({ default: 0 })
    sortOrder: number;

    // Statistics
    @Prop({ default: 0 })
    viewCount: number;

    // Parent page for hierarchical structure
    @Prop({ type: Types.ObjectId, ref: 'Page' })
    parent?: Types.ObjectId;

    // Version control
    @Prop({ default: 1 })
    version: number;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    updatedBy?: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    publishedBy?: Types.ObjectId;
}

export const PageSchema = SchemaFactory.createForClass(Page);

// Note: 'slug' index is automatically created by unique: true
PageSchema.index({ status: 1, type: 1 });
PageSchema.index({ showInFooter: 1, sortOrder: 1 });
PageSchema.index({ showInHeader: 1, sortOrder: 1 });
PageSchema.index({ parent: 1 });
