import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsMongoId,
  IsEnum,
  IsObject,
  IsNumber,
  IsBoolean,
  IsDateString,
} from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Create Order DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class CreateOrderDto {
  @ApiProperty({
    description: 'Shipping address ID',
    example: '507f1f77bcf86cd799439011',
    required: false,
  })
  @IsMongoId()
  @IsOptional()
  shippingAddressId?: string;

  @ApiProperty({
    description: 'Payment method',
    enum: [
      'cash_on_delivery',
      'credit_card',
      'mada',
      'apple_pay',
      'stc_pay',
      'bank_transfer',
      'wallet',
      'credit',
      'cash',
      'card',
      'cod',
    ],
    example: 'credit',
    required: false,
  })
  @IsString()
  @IsOptional()
  @IsEnum([
    'cash_on_delivery',
    'credit_card',
    'mada',
    'apple_pay',
    'stc_pay',
    'bank_transfer',
    'wallet',
    'credit',
    'cash',
    'card',
    'cod',
  ])
  paymentMethod?: string;

  @ApiProperty({
    description: 'Customer notes',
    example: 'Please deliver before 5 PM',
    required: false,
  })
  @IsString()
  @IsOptional()
  customerNotes?: string;

  @ApiProperty({
    description: 'Coupon code to apply',
    example: 'SUMMER2024',
    required: false,
  })
  @IsString()
  @IsOptional()
  couponCode?: string;

  @ApiProperty({
    description: 'Shipping address object (if not using addressId)',
    type: Object,
    required: false,
  })
  @IsObject()
  @IsOptional()
  shippingAddress?: {
    fullName: string;
    phone: string;
    address: string;
    city: string;
    district?: string;
    postalCode?: string;
    notes?: string;
  };

  @ApiProperty({
    description: 'Order source',
    enum: ['web', 'mobile', 'admin'],
    example: 'mobile',
    required: false,
  })
  @IsString()
  @IsOptional()
  @IsEnum(['web', 'mobile', 'admin'])
  source?: string;

  @ApiProperty({
    description:
      'Deprecated: wallet amount is auto-applied by backend using available balance up to order total.',
    example: 50,
    required: false,
  })
  @IsNumber()
  @IsOptional()
  walletAmountUsed?: number;

  @ApiProperty({
    description: 'Whether to use loyalty points',
    example: true,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  useLoyaltyPoints?: boolean;

  @ApiProperty({
    description: 'Amount of loyalty points to use',
    example: 100,
    required: false,
  })
  @IsNumber()
  @IsOptional()
  loyaltyPointsAmount?: number;

  @ApiProperty({
    description:
      'Bank transfer receipt image (base64 or URL). Required for bank transfer orders that still need payment.',
    example: 'data:image/jpeg;base64,/9j/4AAQSk...',
    required: false,
  })
  @IsOptional()
  @IsString()
  receiptImage?: string;

  @ApiProperty({
    description: 'Transfer reference number',
    example: 'TRF123456789',
    required: false,
  })
  @IsOptional()
  @IsString()
  transferReference?: string;

  @ApiProperty({
    description: 'Transfer date (YYYY-MM-DD)',
    example: '2026-02-27',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  transferDate?: string;

  @ApiProperty({
    description: 'Transfer notes',
    example: 'Payment completed via bank transfer',
    required: false,
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({
    description: 'Selected bank account ID for bank transfer',
    example: '507f1f77bcf86cd799439011',
    required: false,
  })
  @IsOptional()
  @IsMongoId()
  bankAccountId?: string;
}
