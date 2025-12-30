import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsMongoId, IsEnum, IsObject } from 'class-validator';

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
        enum: ['cash', 'card', 'bank_transfer', 'wallet', 'credit'],
        example: 'credit',
        required: false,
    })
    @IsString()
    @IsOptional()
    @IsEnum(['cash', 'card', 'bank_transfer', 'wallet', 'credit'])
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
}

