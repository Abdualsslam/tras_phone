import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type BannerDocument = Banner & Document;

export enum BannerType {
    HERO = 'hero',
    PROMOTIONAL = 'promotional',
    CATEGORY = 'category',
    POPUP = 'popup',
    SIDEBAR = 'sidebar',
    INLINE = 'inline',
}

export enum BannerPosition {
    HOME_TOP = 'home_top',
    HOME_MIDDLE = 'home_middle',
    HOME_BOTTOM = 'home_bottom',
    CATEGORY_TOP = 'category_top',
    PRODUCT_TOP = 'product_top',
    CART_TOP = 'cart_top',
    CHECKOUT_TOP = 'checkout_top',
    GLOBAL_POPUP = 'global_popup',
}

@Schema({ _id: false })
export class BannerMedia {
    @Prop({ required: true })
    imageDesktopAr: string;

    @Prop({ required: true })
    imageDesktopEn: string;

    @Prop()
    imageMobileAr?: string;

    @Prop()
    imageMobileEn?: string;

    @Prop()
    videoUrl?: string;

    @Prop()
    altTextAr?: string;

    @Prop()
    altTextEn?: string;
}

@Schema({ _id: false })
export class BannerAction {
    @Prop({
        type: String,
        enum: ['link', 'product', 'category', 'brand', 'page', 'none'],
        default: 'none'
    })
    type: string;

    @Prop()
    url?: string;

    @Prop({ type: Types.ObjectId, refPath: 'action.refModel' })
    refId?: Types.ObjectId;

    @Prop({ type: String, enum: ['Product', 'Category', 'Brand', 'Page'] })
    refModel?: string;

    @Prop({ default: false })
    openInNewTab: boolean;
}

@Schema({ _id: false })
export class BannerContent {
    @Prop()
    headingAr?: string;

    @Prop()
    headingEn?: string;

    @Prop()
    subheadingAr?: string;

    @Prop()
    subheadingEn?: string;

    @Prop()
    buttonTextAr?: string;

    @Prop()
    buttonTextEn?: string;

    @Prop()
    textColor?: string;

    @Prop()
    overlayColor?: string;

    @Prop({ type: Number, min: 0, max: 1 })
    overlayOpacity?: number;
}

@Schema({ _id: false })
export class BannerTargeting {
    @Prop({ type: [String], default: [] })
    customerSegments: string[];

    @Prop({ type: [{ type: Types.ObjectId, ref: 'Category' }] })
    categories?: Types.ObjectId[];

    @Prop({ type: [String], enum: ['guest', 'registered', 'all'], default: ['all'] })
    userTypes: string[];

    @Prop({ type: [String], default: [] })
    devices: string[]; // mobile, tablet, desktop
}

@Schema({ timestamps: true })
export class Banner {
    @Prop({ required: true, trim: true })
    nameAr: string;

    @Prop({ required: true, trim: true })
    nameEn: string;

    @Prop({
        type: String,
        enum: Object.values(BannerType),
        required: true
    })
    type: BannerType;

    @Prop({
        type: String,
        enum: Object.values(BannerPosition),
        required: true
    })
    position: BannerPosition;

    @Prop({ type: BannerMedia, required: true })
    media: BannerMedia;

    @Prop({ type: BannerAction, default: {} })
    action: BannerAction;

    @Prop({ type: BannerContent, default: {} })
    content: BannerContent;

    @Prop({ type: BannerTargeting, default: {} })
    targeting: BannerTargeting;

    // Schedule
    @Prop()
    startDate?: Date;

    @Prop()
    endDate?: Date;

    // Status
    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: 0 })
    sortOrder: number;

    @Prop({ default: 0 })
    priority: number;

    // Statistics
    @Prop({ default: 0 })
    impressions: number;

    @Prop({ default: 0 })
    clicks: number;

    @Prop({ type: Types.ObjectId, ref: 'Admin' })
    createdBy?: Types.ObjectId;
}

export const BannerSchema = SchemaFactory.createForClass(Banner);

BannerSchema.index({ type: 1, position: 1, isActive: 1 });
BannerSchema.index({ startDate: 1, endDate: 1, isActive: 1 });
BannerSchema.index({ sortOrder: 1, priority: -1 });

// Virtual for CTR
BannerSchema.virtual('ctr').get(function () {
    if (this.impressions === 0) return 0;
    return ((this.clicks / this.impressions) * 100).toFixed(2);
});
