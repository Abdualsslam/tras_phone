import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsBoolean, IsArray, IsEnum, IsMongoId, Min } from 'class-validator';
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
  @Min(2)
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
  @Min(1)
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
