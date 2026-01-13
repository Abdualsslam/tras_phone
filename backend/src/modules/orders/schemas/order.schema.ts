import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderDocument = Order & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Order Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'orders',
  toJSON: { virtuals: true },
})
export class Order {
  @Prop({ required: true, unique: true })
  orderNumber: string;

  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'PriceLevel' })
  priceLevelId?: Types.ObjectId;

  // ═════════════════════════════════════
  // Status (10 states)
  // ═════════════════════════════════════
  @Prop({
    required: true,
    type: String,
    enum: [
      'pending', // تم الإنشاء - في انتظار التأكيد
      'confirmed', // تم التأكيد
      'processing', // قيد المعالجة
      'ready_for_pickup', // جاهز للاستلام
      'shipped', // تم الشحن
      'out_for_delivery', // في الطريق للتوصيل
      'delivered', // تم التوصيل
      'completed', // مكتمل
      'cancelled', // ملغي
      'refunded', // مسترجع
    ],
    default: 'pending',
  })
  status: string;

  // ═════════════════════════════════════
  // Amounts
  // ═════════════════════════════════════
  @Prop({ type: Number, default: 0 })
  subtotal: number;

  @Prop({ type: Number, default: 0 })
  taxAmount: number;

  @Prop({ type: Number, default: 0 })
  shippingCost: number;

  @Prop({ type: Number, default: 0 })
  discount: number;

  @Prop({ type: Number, default: 0 })
  couponDiscount: number;

  @Prop({ type: Number, default: 0 })
  walletAmountUsed: number;

  @Prop({ type: Number, default: 0 })
  loyaltyPointsUsed: number;

  @Prop({ type: Number, default: 0 })
  loyaltyPointsValue: number;

  @Prop({ type: Number, required: true })
  total: number;

  @Prop({ type: Number, default: 0 })
  paidAmount: number;

  // ═════════════════════════════════════
  // Payment
  // ═════════════════════════════════════
  @Prop({
    type: String,
    enum: ['unpaid', 'partial', 'paid', 'refunded'],
    default: 'unpaid',
  })
  paymentStatus: string;

  @Prop({
    type: String,
    enum: ['cash', 'card', 'bank_transfer', 'wallet', 'credit'],
  })
  paymentMethod?: string;

  // ═════════════════════════════════════
  // Shipping
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'CustomerAddress' })
  shippingAddressId?: Types.ObjectId;

  @Prop({ type: Object })
  shippingAddress?: {
    fullName: string;
    phone: string;
    address: string;
    city: string;
    district?: string;
    postalCode?: string;
    notes?: string;
  };

  @Prop({ type: Types.ObjectId, ref: 'ShippingZone' })
  shippingZoneId?: Types.ObjectId;

  @Prop({ type: Date })
  estimatedDeliveryDate?: Date;

  // ═════════════════════════════════════
  // Warehouse
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'Warehouse' })
  warehouseId?: Types.ObjectId;

  // ═════════════════════════════════════
  // Promotions/Coupons
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'Coupon' })
  couponId?: Types.ObjectId;

  @Prop()
  couponCode?: string;

  @Prop({ type: [Types.ObjectId], ref: 'Promotion' })
  appliedPromotions?: Types.ObjectId[];

  // ═════════════════════════════════════
  // Source
  // ═════════════════════════════════════
  @Prop({
    type: String,
    enum: ['web', 'mobile', 'admin', 'api'],
    default: 'web',
  })
  source: string;

  @Prop()
  ipAddress?: string;

  @Prop()
  userAgent?: string;

  // ═════════════════════════════════════
  // Notes
  // ═════════════════════════════════════
  @Prop()
  customerNotes?: string;

  @Prop()
  internalNotes?: string;

  // ═════════════════════════════════════
  // Tracking
  // ═════════════════════════════════════
  @Prop({ type: Date })
  confirmedAt?: Date;

  @Prop({ type: Date })
  shippedAt?: Date;

  @Prop({ type: Date })
  deliveredAt?: Date;

  @Prop({ type: Date })
  completedAt?: Date;

  @Prop({ type: Date })
  cancelledAt?: Date;

  @Prop()
  cancellationReason?: string;

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  processedBy?: Types.ObjectId;

  // ═════════════════════════════════════
  // Bank Transfer Payment
  // ═════════════════════════════════════
  @Prop({ type: Types.ObjectId, ref: 'BankAccount' })
  bankAccountId?: Types.ObjectId;

  @Prop()
  transferReceiptImage?: string;

  @Prop()
  transferReference?: string;

  @Prop({ type: Date })
  transferDate?: Date;

  @Prop({ type: Date })
  transferVerifiedAt?: Date;

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  transferVerifiedBy?: Types.ObjectId;

  @Prop()
  rejectionReason?: string;

  // ═════════════════════════════════════
  // Customer Rating
  // ═════════════════════════════════════
  @Prop({ type: Number, min: 1, max: 5 })
  customerRating?: number;

  @Prop()
  customerRatingComment?: string;

  @Prop({ type: Date })
  ratedAt?: Date;

  // ═════════════════════════════════════
  // Order Items
  // ═════════════════════════════════════
  @Prop({
    type: [
      {
        productId: { type: Types.ObjectId, ref: 'Product', required: true },
        variantId: { type: Types.ObjectId, ref: 'ProductVariant' },
        sku: { type: String },
        name: { type: String, required: true },
        quantity: { type: Number, required: true, min: 1 },
        unitPrice: { type: Number, required: true },
        discount: { type: Number, default: 0 },
        total: { type: Number, required: true },
        attributes: { type: Object },
      },
    ],
    default: [],
  })
  items: {
    productId: Types.ObjectId;
    variantId?: Types.ObjectId;
    sku?: string;
    name: string;
    quantity: number;
    unitPrice: number;
    discount?: number;
    total: number;
    attributes?: Record<string, any>;
  }[];

  createdAt: Date;
  updatedAt: Date;
}

export const OrderSchema = SchemaFactory.createForClass(Order);

OrderSchema.index({ orderNumber: 1 });
OrderSchema.index({ customerId: 1 });
OrderSchema.index({ status: 1 });
OrderSchema.index({ paymentStatus: 1 });
OrderSchema.index({ createdAt: -1 });
OrderSchema.index({ 'shippingAddress.city': 1 });

// Virtuals
OrderSchema.virtual('remainingAmount').get(function () {
  return this.total - this.paidAmount;
});

OrderSchema.virtual('itemsCount').get(function () {
  return this.items?.length || 0;
});
