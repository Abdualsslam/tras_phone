import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsMongoId, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '@common/dto/pagination-query.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Order Filter Query DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class OrderFilterQueryDto extends PaginationQueryDto {
    @ApiProperty({ example: '507f1f77bcf86cd799439011', required: false, description: 'Filter by customer ID' })
    @IsMongoId()
    @IsOptional()
    customerId?: string;

    @ApiProperty({
        example: 'pending',
        enum: ['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled', 'refunded'],
        required: false,
        description: 'Filter by order status',
    })
    @IsString()
    @IsOptional()
    @IsEnum(['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled', 'refunded'])
    status?: string;

    @ApiProperty({
        example: 'unpaid',
        enum: ['unpaid', 'partial', 'paid', 'refunded'],
        required: false,
        description: 'Filter by payment status',
    })
    @IsString()
    @IsOptional()
    @IsEnum(['unpaid', 'partial', 'paid', 'refunded'])
    paymentStatus?: string;

    @ApiProperty({ example: 'ORD-2024-001', required: false, description: 'Search by order number' })
    @IsString()
    @IsOptional()
    orderNumber?: string;

    @ApiProperty({
        example: 'createdAt',
        enum: ['createdAt', 'orderNumber', 'total', 'status'],
        required: false,
        description: 'Sort field',
    })
    @IsString()
    @IsOptional()
    @IsEnum(['createdAt', 'orderNumber', 'total', 'status'])
    sortBy?: string;

    @ApiProperty({
        example: 'desc',
        enum: ['asc', 'desc'],
        required: false,
        description: 'Sort order',
    })
    @IsString()
    @IsOptional()
    @IsEnum(['asc', 'desc'])
    sortOrder?: 'asc' | 'desc';
}

