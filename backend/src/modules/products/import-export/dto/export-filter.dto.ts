import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsMongoId, IsOptional, IsEnum, IsBoolean, IsString } from 'class-validator';
import { Transform } from 'class-transformer';

export enum ExportFormat {
  XLSX = 'xlsx',
  CSV = 'csv',
}

export class ExportProductsQueryDto {
  @ApiPropertyOptional({ description: 'Filter by brand ID' })
  @IsMongoId()
  @IsOptional()
  brandId?: string;

  @ApiPropertyOptional({ description: 'Filter by category ID' })
  @IsMongoId()
  @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional({ description: 'Filter by status' })
  @IsEnum(['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'])
  @IsOptional()
  status?: string;

  @ApiPropertyOptional({ description: 'Filter by quality type ID' })
  @IsMongoId()
  @IsOptional()
  qualityTypeId?: string;

  @ApiPropertyOptional({ description: 'Include inactive products' })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  includeInactive?: boolean = false;

  @ApiPropertyOptional({ description: 'Include device compatibility data' })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  includeCompatibility?: boolean = true;

  @ApiPropertyOptional({ description: 'Include full reference sheets' })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value !== 'false')
  includeReferences?: boolean = true;

  @ApiPropertyOptional({ description: 'Export format' })
  @IsEnum(ExportFormat)
  @IsOptional()
  format?: ExportFormat = ExportFormat.XLSX;

  @ApiPropertyOptional({ description: 'Search query' })
  @IsString()
  @IsOptional()
  search?: string;
}

export class PartialUpdateQueryDto {
  @ApiPropertyOptional({
    description: 'Fields to update (comma-separated)',
    example: 'basePrice,stockQuantity,status',
  })
  @IsString()
  @IsOptional()
  fields?: string;
}
