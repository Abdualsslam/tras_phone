import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum ImportMode {
  CREATE = 'create',
  UPDATE = 'update',
  UPSERT = 'upsert',
}

export class ImportProductsQueryDto {
  @ApiPropertyOptional({
    enum: ImportMode,
    default: ImportMode.UPSERT,
    description: 'Import mode: create only, update only, or upsert (create or update)',
  })
  @IsEnum(ImportMode)
  @IsOptional()
  mode?: ImportMode = ImportMode.UPSERT;

  @ApiPropertyOptional({
    description: 'Skip validation and proceed with import',
    default: false,
  })
  @IsOptional()
  skipValidation?: boolean = false;
}

export class ImportProductsResponseDto {
  @ApiPropertyOptional()
  success: boolean;

  @ApiPropertyOptional()
  summary: {
    total: number;
    created: number;
    updated: number;
    skipped: number;
    errors: number;
  };

  @ApiPropertyOptional()
  errors: Array<{
    row: number;
    sheet: string;
    field: string;
    message: string;
    value?: any;
  }>;

  @ApiPropertyOptional()
  warnings: Array<{
    row: number;
    sheet: string;
    field: string;
    message: string;
  }>;

  @ApiPropertyOptional()
  missingReferences?: {
    brands: string[];
    categories: string[];
    qualityTypes: string[];
    devices: string[];
  };
}

export class ValidationResultDto {
  @ApiPropertyOptional()
  isValid: boolean;

  @ApiPropertyOptional()
  totalRows: number;

  @ApiPropertyOptional()
  references: {
    brands: { slug: string; name: string; exists: boolean }[];
    categories: { slug: string; name: string; exists: boolean }[];
    qualityTypes: { code: string; name: string; exists: boolean }[];
    devices: { slug: string; name: string; exists: boolean }[];
  };

  @ApiPropertyOptional()
  errors: Array<{
    row: number;
    sheet: string;
    field: string;
    message: string;
    value?: any;
  }>;

  @ApiPropertyOptional()
  missingReferences: {
    brands: string[];
    categories: string[];
    qualityTypes: string[];
    devices: string[];
  };
}
