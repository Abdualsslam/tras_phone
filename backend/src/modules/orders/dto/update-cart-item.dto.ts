import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsNotEmpty, Min } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Update Cart Item Quantity DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UpdateCartItemDto {
    @ApiProperty({
        description: 'New quantity for the item',
        example: 3,
        minimum: 1,
    })
    @IsNumber()
    @IsNotEmpty()
    @Min(1)
    quantity: number;
}

