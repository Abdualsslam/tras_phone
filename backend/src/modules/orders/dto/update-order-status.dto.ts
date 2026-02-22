import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum, ValidateIf } from 'class-validator';

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

    @ApiProperty({
        description: 'Shipping label URL (required when status is shipped)',
        example: 'https://storage.example.com/shipping-labels/label-123.pdf',
        required: false,
    })
    @ValidateIf((o) => o.status === 'shipped')
    @IsNotEmpty({ message: 'shippingLabelUrl is required when status is shipped' })
    @IsString()
    shippingLabelUrl?: string;
}

