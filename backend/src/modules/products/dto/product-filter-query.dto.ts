import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsMongoId, IsNumber, IsBoolean, Min, Max, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';
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

    @ApiProperty({ example: true, required: false, description: 'Filter featured products only (based on isFeatured field in schema)' })
    @IsBoolean()
    @Type(() => Boolean)
    @IsOptional()
    isFeatured?: boolean;

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
