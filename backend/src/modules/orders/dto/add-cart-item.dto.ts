import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsNumber, IsMongoId, Min, IsOptional } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Add Cart Item DTO
 * ═══════════════════════════════════════════════════════════════
 * Note: unitPrice is ignored - server computes price from customer's price level
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
        description: 'Unit price (deprecated - server uses customer price level)',
        example: 100.00,
        minimum: 0,
        required: false,
    })
    @IsNumber()
    @IsOptional()
    @Min(0)
    unitPrice?: number;
}

