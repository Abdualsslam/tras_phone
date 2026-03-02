import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsNumber, IsMongoId, Min } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎫 Apply Coupon DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class ApplyCouponDto {
    @ApiProperty({
        description: 'Coupon ID (optional, legacy)',
        example: '507f1f77bcf86cd799439011',
        required: false,
    })
    @IsMongoId()
    @IsOptional()
    couponId?: string;

    @ApiProperty({
        description: 'Coupon code',
        example: 'SUMMER2024',
    })
    @IsString()
    @IsNotEmpty()
    couponCode: string;

    @ApiProperty({
        description: 'Discount amount in currency (ignored by backend)',
        example: 50.00,
        minimum: 0,
        required: false,
    })
    @IsNumber()
    @IsOptional()
    @Min(0)
    discountAmount?: number;
}

