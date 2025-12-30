import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsDateString, IsMongoId } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Create Shipment DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class CreateShipmentDto {
    @ApiProperty({
        description: 'Shipping carrier name',
        example: 'Aramex',
        required: false,
    })
    @IsString()
    @IsOptional()
    carrier?: string;

    @ApiProperty({
        description: 'Tracking number',
        example: 'AR123456789',
        required: false,
    })
    @IsString()
    @IsOptional()
    trackingNumber?: string;

    @ApiProperty({
        description: 'Estimated delivery date',
        example: '2024-01-15T00:00:00.000Z',
        required: false,
    })
    @IsDateString()
    @IsOptional()
    estimatedDeliveryDate?: string;

    @ApiProperty({
        description: 'Shipping cost',
        example: 25.00,
        required: false,
    })
    @IsString()
    @IsOptional()
    cost?: string;
}

