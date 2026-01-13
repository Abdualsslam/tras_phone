import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum, IsOptional, IsNumber, Min } from 'class-validator';

export class CreateStockAlertDto {
  @ApiProperty({
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @IsString()
  productId: string;

  @ApiProperty({
    description: 'Alert type',
    enum: ['back_in_stock', 'low_stock', 'price_drop'],
    example: 'back_in_stock',
  })
  @IsEnum(['back_in_stock', 'low_stock', 'price_drop'])
  alertType: 'back_in_stock' | 'low_stock' | 'price_drop';

  @ApiProperty({
    description: 'Target price (for price_drop alerts)',
    required: false,
    example: 199.99,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  targetPrice?: number;
}
