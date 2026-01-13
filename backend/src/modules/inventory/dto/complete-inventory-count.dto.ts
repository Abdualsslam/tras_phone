import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsOptional, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class InventoryCountItemDto {
  @ApiProperty({
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  productId: string;

  @ApiProperty({
    description: 'Counted quantity',
    example: 50,
  })
  countedQuantity: number;

  @ApiProperty({
    description: 'Notes',
    required: false,
  })
  @IsOptional()
  notes?: string;
}

export class CompleteInventoryCountDto {
  @ApiProperty({
    description: 'Count items with quantities',
    type: [InventoryCountItemDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InventoryCountItemDto)
  items: InventoryCountItemDto[];
}
