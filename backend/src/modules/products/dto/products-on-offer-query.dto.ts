import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional, IsEnum, IsNumber, Min, Max, IsMongoId } from 'class-validator';
import { PaginationQueryDto } from '@common/dto/pagination-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Products on Offer Query DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class ProductsOnOfferQueryDto extends PaginationQueryDto {
    @ApiProperty({
        enum: ['discount', 'price', 'createdAt'],
        default: 'discount',
        description: 'Sort field',
        required: false,
    })
    @IsOptional()
    @IsEnum(['discount', 'price', 'createdAt'])
    sortBy?: 'discount' | 'price' | 'createdAt' = 'discount';

    @ApiProperty({
        enum: ['asc', 'desc'],
        default: 'desc',
        description: 'Sort order',
        required: false,
    })
    @IsOptional()
    @IsEnum(['asc', 'desc'])
    sortOrder?: 'asc' | 'desc' = 'desc';

    @ApiProperty({
        example: 10,
        description: 'Minimum discount percentage',
        required: false,
        minimum: 0,
        maximum: 100,
    })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    @Min(0)
    @Max(100)
    minDiscount?: number;

    @ApiProperty({
        example: 50,
        description: 'Maximum discount percentage',
        required: false,
        minimum: 0,
        maximum: 100,
    })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    @Min(0)
    @Max(100)
    maxDiscount?: number;

    @ApiProperty({
        example: '507f1f77bcf86cd799439011',
        description: 'Filter by category ID',
        required: false,
    })
    @IsOptional()
    @IsMongoId()
    categoryId?: string;

    @ApiProperty({
        example: '507f1f77bcf86cd799439012',
        description: 'Filter by brand ID',
        required: false,
    })
    @IsOptional()
    @IsMongoId()
    brandId?: string;
}
