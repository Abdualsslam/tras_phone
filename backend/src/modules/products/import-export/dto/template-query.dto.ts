import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsArray, IsOptional, IsString } from 'class-validator';

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

export class TemplateQueryDto {
  @ApiPropertyOptional({
    description:
      'Optional product fields to include in template. Accepts comma-separated values.',
    type: [String],
    example: ['description', 'images', 'tags'],
  })
  @IsOptional()
  @Transform(({ value }) => normalizeOptionalFields(value))
  @IsArray()
  @IsString({ each: true })
  optionalFields?: string[];
}
