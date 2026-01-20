import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsMongoId,
  IsNumber,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Sync Cart Item DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class SyncCartItemDto {
  @ApiProperty({
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
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
  @IsNotEmpty()
  @Min(1)
  quantity: number;

  @ApiProperty({
    description: 'Unit price at the time of adding to local cart',
    example: 150.00,
    minimum: 0,
  })
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  unitPrice: number;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Sync Cart DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class SyncCartDto {
  @ApiProperty({
    description: 'Cart items to sync',
    type: [SyncCartItemDto],
  })
  @IsArray()
  @IsNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => SyncCartItemDto)
  items: SyncCartItemDto[];
}
