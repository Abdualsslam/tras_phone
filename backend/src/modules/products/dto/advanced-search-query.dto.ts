import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsBoolean, IsArray, IsEnum, IsMongoId, Min, IsNumber, MinLength } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '@common/dto/pagination-query.dto';
import { ProductFilterQueryDto } from './product-filter-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Advanced Search Query DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AdvancedSearchQueryDto extends PaginationQueryDto {
  @ApiProperty({ 
    example: 'iPhone 15 Pro', 
    required: true, 
    description: 'Search query string' 
  })
  @IsString()
  query: string;

  @ApiProperty({ 
    example: ['name', 'nameAr', 'tags'], 
    required: false, 
    description: 'Fields to search in',
    enum: ['name', 'nameAr', 'tags', 'description', 'shortDescription', 'sku']
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  searchFields?: string[];

  @ApiProperty({ 
    example: ['أصلي', 'OEM'], 
    required: false, 
    description: 'Tags to filter by' 
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];

  @ApiProperty({ 
    example: 'OR', 
    enum: ['AND', 'OR'], 
    required: false, 
    description: 'Tag matching mode' 
  })
  @IsEnum(['AND', 'OR'])
  @IsOptional()
  tagMode?: 'AND' | 'OR';

  @ApiProperty({ 
    example: true, 
    required: false, 
    description: 'Enable fuzzy search for typos' 
  })
  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  fuzzy?: boolean;

  @ApiProperty({ 
    example: 'relevance', 
    enum: ['relevance', 'price', 'name', 'createdAt', 'averageRating'], 
    required: false, 
    description: 'Sort field' 
  })
  @IsEnum(['relevance', 'price', 'name', 'createdAt', 'averageRating'])
  @IsOptional()
  sortBy?: 'relevance' | 'price' | 'name' | 'createdAt' | 'averageRating';

  @ApiProperty({ 
    example: 'asc', 
    enum: ['asc', 'desc'], 
    required: false, 
    description: 'Sort order' 
  })
  @IsEnum(['asc', 'desc'])
  @IsOptional()
  sortOrder?: 'asc' | 'desc';

  // Filter properties inherited from ProductFilterQueryDto pattern
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

  @ApiProperty({ example: true, required: false, description: 'Filter featured products only' })
  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  featured?: boolean;

  @ApiProperty({ example: true, required: false, description: 'Filter new arrival products only' })
  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  newArrival?: boolean;

  @ApiProperty({ example: true, required: false, description: 'Filter best seller products only' })
  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  bestSeller?: boolean;
}

/**
 * Search Suggestions Query DTO
 */
export class SearchSuggestionsQueryDto {
  @ApiProperty({ 
    example: 'آيفون', 
    required: true, 
    description: 'Partial search query' 
  })
  @IsString()
  @MinLength(2)
  query: string;

  @ApiProperty({ 
    example: 10, 
    required: false, 
    description: 'Maximum number of suggestions' 
  })
  @Type(() => Number)
  @IsOptional()
  limit?: number;
}

/**
 * Autocomplete Query DTO
 */
export class AutocompleteQueryDto {
  @ApiProperty({ 
    example: 'شا', 
    required: true, 
    description: 'Partial search query' 
  })
  @IsString()
  @MinLength(1)
  query: string;

  @ApiProperty({ 
    example: 5, 
    required: false, 
    description: 'Maximum number of suggestions' 
  })
  @Type(() => Number)
  @IsOptional()
  limit?: number;
}
