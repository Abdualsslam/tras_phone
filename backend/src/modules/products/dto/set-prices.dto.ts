import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsMongoId, IsNumber, IsOptional, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Price Level DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class PriceLevelDto {
    @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Price level ID' })
    @IsMongoId()
    priceLevelId: string;

    @ApiProperty({ example: 950.00, description: 'Price for this level' })
    @IsNumber()
    @Min(0)
    price: number;

    @ApiProperty({ example: 1100.00, required: false, description: 'Compare at price' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    compareAtPrice?: number;

    @ApiProperty({ example: 1, required: false, description: 'Minimum quantity for this price' })
    @IsNumber()
    @IsOptional()
    @Min(1)
    minQuantity?: number;

    @ApiProperty({ example: 10, required: false, description: 'Maximum quantity for this price' })
    @IsNumber()
    @IsOptional()
    @Min(1)
    maxQuantity?: number;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Set Prices DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class SetPricesDto {
    @ApiProperty({
        type: [PriceLevelDto],
        description: 'Array of prices for different price levels',
        example: [
            {
                priceLevelId: '507f1f77bcf86cd799439011',
                price: 950.00,
                compareAtPrice: 1100.00,
            },
        ],
    })
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => PriceLevelDto)
    prices: PriceLevelDto[];
}
