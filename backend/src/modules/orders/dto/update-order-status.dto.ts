import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Update Order Status DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UpdateOrderStatusDto {
    @ApiProperty({
        description: 'New order status',
        enum: ['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled', 'refunded'],
        example: 'confirmed',
    })
    @IsString()
    @IsNotEmpty()
    @IsEnum(['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled', 'refunded'])
    status: string;

    @ApiProperty({
        description: 'Notes about the status change',
        example: 'Order confirmed and ready for processing',
        required: false,
    })
    @IsString()
    @IsOptional()
    notes?: string;
}

