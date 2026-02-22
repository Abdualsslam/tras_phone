import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsMongoId, IsNumber, IsBoolean, Min, Max, IsEnum, IsArray } from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { PaginationQueryDto } from '@common/dto/pagination-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Product Filter Query DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class ProductFilterQueryDto extends PaginationQueryDto {
    @ApiProperty({ example: 'iPhone', required: false, description: 'Search term (name, description)' })
    @IsString()
    @IsOptional()
    search?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439011', required: false, description: 'Filter by brand ID' })
    @IsMongoId()
    @IsOptional()
    brandId?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439012', required: false, description: 'Filter by category ID' })
    @IsMongoId()
    @IsOptional()
    categoryId?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439013', required: false, description: 'Filter by quality type ID' })
    @IsMongoId()
    @IsOptional()
    qualityTypeId?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439014', required: false, description: 'Filter by device ID' })
    @IsMongoId()
    @IsOptional()
    deviceId?: string;

    @ApiProperty({ example: ['screen', 'original'], required: false, description: 'Filter by tags (comma-separated or array)' })
    @IsOptional()
    @Transform(({ value }) => {
        if (!value) return undefined;
        if (Array.isArray(value)) return value;
        if (typeof value === 'string') return value.split(',').map((t: string) => t.trim()).filter(Boolean);
        return value;
    })
    @IsArray()
    @IsString({ each: true })
    tags?: string[];

    @ApiProperty({ example: 100, required: false, description: 'Minimum price' })
    @IsNumber()
    @Type(() => Number)
    @IsOptional()
    @Min(0)
    minPrice?: number;

    @ApiProperty({ example: 1000, required: false, description: 'Maximum price' })
    @IsNumber()
    @Type(() => Number)
    @IsOptional()
    @Min(0)
    maxPrice?: number;

    @ApiProperty({ example: 3, required: false, description: 'Minimum average rating (1-5)' })
    @IsNumber()
    @Type(() => Number)
    @IsOptional()
    @Min(1)
    @Max(5)
    minRating?: number;

    @ApiProperty({ example: 5, required: false, description: 'Maximum average rating (1-5)' })
    @IsNumber()
    @Type(() => Number)
    @IsOptional()
    @Min(1)
    @Max(5)
    maxRating?: number;

    @ApiProperty({ example: true, required: false, description: 'Filter products in stock (stockQuantity > 0)' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    inStock?: boolean;

    @ApiProperty({ example: 'black', required: false, description: 'Filter by color' })
    @IsString()
    @IsOptional()
    color?: string;

    @ApiProperty({ example: true, required: false, description: 'Filter products that have an offer (compareAtPrice > basePrice)' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    hasOffer?: boolean;

    @ApiProperty({
        example: 'active',
        enum: ['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'],
        required: false,
        description: 'Filter by status',
    })
    @IsString()
    @IsOptional()
    status?: string;

    @ApiProperty({ example: true, required: false, description: 'Filter by active status' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    isActive?: boolean;

    @ApiProperty({ example: true, required: false, description: 'Filter featured products only' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    isFeatured?: boolean;

    @ApiProperty({ example: true, required: false, description: 'Filter new arrival products only' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    isNewArrival?: boolean;

    @ApiProperty({ example: true, required: false, description: 'Filter best seller products only' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    isBestSeller?: boolean;

    @ApiProperty({
        example: 'price',
        enum: ['price', 'name', 'createdAt', 'viewsCount', 'ordersCount', 'averageRating'],
        required: false,
        description: 'Sort field',
    })
    @IsString()
    @IsOptional()
    sortBy?: string;

    @ApiProperty({
        example: 'asc',
        enum: ['asc', 'desc'],
        required: false,
        description: 'Sort order',
    })
    @IsString()
    @IsOptional()
    @IsEnum(['asc', 'desc'])
    sortOrder?: 'asc' | 'desc';
}
