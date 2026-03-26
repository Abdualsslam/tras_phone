import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsMongoId,
  IsOptional,
  IsEnum,
  IsBoolean,
  IsString,
} from 'class-validator';
import { Transform } from 'class-transformer';

function normalizeOptionalFields(value: unknown): string[] | undefined {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }

  const rawValues = Array.isArray(value) ? value : [value];
  const normalized = rawValues
    .flatMap((item) => String(item).split(','))
    .map((item) => item.trim())
    .filter(Boolean);

  return normalized.length ? normalized : undefined;
}

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

  @ApiPropertyOptional({
    description:
      'Optional product fields to include in export. Accepts comma-separated values.',
    type: [String],
    example: ['description', 'images', 'tags'],
  })
  @IsOptional()
  @Transform(({ value }) => normalizeOptionalFields(value))
  @IsArray()
  @IsString({ each: true })
  optionalFields?: string[];
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
