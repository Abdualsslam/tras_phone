import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsNumber, IsMongoId, Min } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Add Cart Item DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AddCartItemDto {
    @ApiProperty({
        description: 'Product ID',
        example: '507f1f77bcf86cd799439011',
    })
    @IsMongoId()
    @IsNotEmpty()
    productId: string;

    @ApiProperty({
        description: 'Quantity to add',
        example: 2,
        minimum: 1,
    })
    @IsNumber()
    @IsNotEmpty()
    @Min(1)
    quantity: number;

    @ApiProperty({
        description: 'Unit price at the time of adding to cart',
        example: 100.00,
        minimum: 0,
    })
    @IsNumber()
    @IsNotEmpty()
    @Min(0)
    unitPrice: number;
}

