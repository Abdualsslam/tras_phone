import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsString,
  IsNumber,
  IsOptional,
  IsMongoId,
  Min,
  ValidateNested,
  IsNotEmpty,
} from 'class-validator';
import { Type } from 'class-transformer';

class OrderItemDto {
  @ApiPropertyOptional({
    description: 'Order item ID (for existing items, omit for new items)',
    example: '507f1f77bcf86cd799439011',
  })
  @IsOptional()
  @IsMongoId()
  orderItemId?: string;

  @ApiProperty({
    description: 'Product ID',
    example: '507f1f77bcf86cd799439012',
  })
  @IsMongoId()
  @IsNotEmpty()
  productId: string;

  @ApiProperty({
    description: 'Quantity',
    example: 2,
    minimum: 1,
  })
  @IsNumber()
  @Min(1)
  quantity: number;

  @ApiPropertyOptional({
    description: 'Unit price (if not provided, will use product price from price level)',
    example: 150.00,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  unitPrice?: number;
}

export class UpdateOrderItemsDto {
  @ApiProperty({
    description: 'List of order items (replace all items)',
    type: [OrderItemDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[];

  @ApiPropertyOptional({
    description: 'Reason for modification',
    example: 'Customer requested to change quantity',
  })
  @IsOptional()
  @IsString()
  reason?: string;
}
