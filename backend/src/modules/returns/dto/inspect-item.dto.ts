import {
  IsString,
  IsOptional,
  IsArray,
  IsEnum,
  IsNumber,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class InspectItemDto {
  @ApiProperty({
    description: 'Item condition',
    enum: ['good', 'damaged', 'used', 'missing_parts', 'not_original'],
    example: 'good',
  })
  @IsString()
  @IsEnum(['good', 'damaged', 'used', 'missing_parts', 'not_original'])
  condition: string;

  @ApiProperty({
    description: 'Approved quantity',
    example: 1,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  approvedQuantity: number;

  @ApiProperty({
    description: 'Rejected quantity',
    example: 0,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  rejectedQuantity: number;

  @ApiPropertyOptional({
    description: 'Inspection notes',
    example: 'المنتج في حالة جيدة',
  })
  @IsOptional()
  @IsString()
  inspectionNotes?: string;

  @ApiPropertyOptional({
    description: 'Inspection images (URLs)',
    type: [String],
    example: ['https://example.com/inspection1.jpg'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  inspectionImages?: string[];
}
