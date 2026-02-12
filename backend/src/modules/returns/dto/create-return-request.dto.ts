import {
  IsString,
  IsArray,
  IsOptional,
  ValidateNested,
  IsNumber,
  Min,
  IsEnum,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ReturnItemDto {
  @ApiProperty({
    description: 'Order item ID to return',
    example: '507f1f77bcf86cd799439011',
  })
  @IsString()
  orderItemId: string;

  @ApiProperty({
    description: 'Quantity to return',
    example: 1,
    minimum: 1,
  })
  @IsNumber()
  @Min(1)
  quantity: number;
}

export class CreateReturnRequestDto {
  @ApiProperty({
    description: 'Return type',
    enum: ['refund', 'exchange', 'store_credit'],
    example: 'refund',
  })
  @IsString()
  @IsEnum(['refund', 'exchange', 'store_credit'])
  returnType: string;

  @ApiProperty({
    description: 'Return reason ID',
    example: '507f1f77bcf86cd799439011',
  })
  @IsString()
  reasonId: string;

  @ApiProperty({
    description: 'Items to return',
    type: [ReturnItemDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReturnItemDto)
  items: ReturnItemDto[];

  @ApiPropertyOptional({
    description: 'Customer notes',
    example: 'الشاشة بها خدوش',
  })
  @IsOptional()
  @IsString()
  customerNotes?: string;

  @ApiPropertyOptional({
    description: 'Customer images (URLs)',
    type: [String],
    example: ['https://example.com/image1.jpg'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  customerImages?: string[];
}
