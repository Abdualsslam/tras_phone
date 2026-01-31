import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Checkout Session DTO
 * ═══════════════════════════════════════════════════════════════
 */

/**
 * Product details embedded in cart item
 */
export class CartItemProductDto {
    @ApiProperty({ description: 'Product name' })
    name: string;

    @ApiProperty({ description: 'Product name in Arabic' })
    nameAr: string;

    @ApiPropertyOptional({ description: 'Product image URL' })
    image?: string;

    @ApiProperty({ description: 'Product SKU' })
    sku: string;

    @ApiProperty({ description: 'Is product active' })
    isActive: boolean;

    @ApiProperty({ description: 'Available stock quantity' })
    stockQuantity: number;
}

/**
 * Cart item with product details
 */
export class CheckoutCartItemDto {
    @ApiProperty({ description: 'Product ID' })
    productId: string;

    @ApiProperty({ description: 'Quantity' })
    quantity: number;

    @ApiProperty({ description: 'Unit price' })
    unitPrice: number;

    @ApiProperty({ description: 'Total price for this item' })
    totalPrice: number;

    @ApiProperty({ description: 'Date added to cart' })
    addedAt: Date;

    @ApiProperty({ description: 'Product details', type: CartItemProductDto })
    product: CartItemProductDto;
}

/**
 * Cart with populated product details
 */
export class CheckoutCartDto {
    @ApiProperty({ description: 'Cart ID' })
    id: string;

    @ApiProperty({ description: 'Customer ID' })
    customerId: string;

    @ApiProperty({ description: 'Cart status' })
    status: string;

    @ApiProperty({ description: 'Cart items with product details', type: [CheckoutCartItemDto] })
    items: CheckoutCartItemDto[];

    @ApiProperty({ description: 'Total items count' })
    itemsCount: number;

    @ApiProperty({ description: 'Subtotal amount' })
    subtotal: number;

    @ApiProperty({ description: 'Discount amount' })
    discount: number;

    @ApiProperty({ description: 'Tax amount' })
    taxAmount: number;

    @ApiProperty({ description: 'Shipping cost' })
    shippingCost: number;

    @ApiProperty({ description: 'Total amount' })
    total: number;

    @ApiPropertyOptional({ description: 'Applied coupon code' })
    couponCode?: string;

    @ApiProperty({ description: 'Coupon discount amount' })
    couponDiscount: number;
}

/**
 * Customer basic info for checkout
 */
export class CheckoutCustomerDto {
    @ApiProperty({ description: 'Customer ID' })
    id: string;

    @ApiPropertyOptional({ description: 'Customer name' })
    name?: string;

    @ApiPropertyOptional({ description: 'Customer phone' })
    phone?: string;

    @ApiPropertyOptional({ description: 'Price level ID' })
    priceLevelId?: string;
}

/**
 * Coupon validation result
 */
export class CheckoutCouponDto {
    @ApiProperty({ description: 'Is coupon valid' })
    isValid: boolean;

    @ApiPropertyOptional({ description: 'Coupon code' })
    code?: string;

    @ApiPropertyOptional({ description: 'Discount amount' })
    discountAmount?: number;

    @ApiPropertyOptional({ description: 'Discount type (percentage or fixed)' })
    discountType?: string;

    @ApiPropertyOptional({ description: 'Error message if invalid' })
    message?: string;
}

/**
 * Full checkout session response
 */
export class CheckoutSessionResponseDto {
    @ApiProperty({ description: 'Cart with product details', type: CheckoutCartDto })
    cart: CheckoutCartDto;

    @ApiProperty({ description: 'Customer addresses', type: 'array' })
    addresses: any[];

    @ApiProperty({ description: 'Available payment methods', type: 'array' })
    paymentMethods: any[];

    @ApiProperty({ description: 'Customer basic info', type: CheckoutCustomerDto })
    customer: CheckoutCustomerDto;

    @ApiPropertyOptional({ description: 'Coupon validation result', type: CheckoutCouponDto })
    coupon?: CheckoutCouponDto;
}

/**
 * Query params for checkout session
 */
export class CheckoutSessionQueryDto {
    @ApiPropertyOptional({
        description: 'Platform for filtering payment methods',
        enum: ['web', 'mobile', 'android', 'ios'],
    })
    @IsString()
    @IsOptional()
    platform?: string;

    @ApiPropertyOptional({
        description: 'Coupon code to pre-validate',
    })
    @IsString()
    @IsOptional()
    couponCode?: string;
}
