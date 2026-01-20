import { IsOptional, IsString, IsEnum, IsArray, IsDateString, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { TicketStatus, TicketPriority } from '../schemas/ticket.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔍 Advanced Search DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AdvancedSearchDto {
    @ApiProperty({ required: false, description: 'Search in ticket number, subject, description, and messages' })
    @IsOptional()
    @IsString()
    query?: string;

    @ApiProperty({ required: false, enum: TicketStatus })
    @IsOptional()
    @IsEnum(TicketStatus)
    status?: TicketStatus;

    @ApiProperty({ required: false, enum: TicketPriority })
    @IsOptional()
    @IsEnum(TicketPriority)
    priority?: TicketPriority;

    @ApiProperty({ required: false, description: 'Category ID' })
    @IsOptional()
    @IsString()
    categoryId?: string;

    @ApiProperty({ required: false, description: 'Assigned agent ID' })
    @IsOptional()
    @IsString()
    assignedTo?: string;

    @ApiProperty({ required: false, description: 'Customer ID' })
    @IsOptional()
    @IsString()
    customerId?: string;

    @ApiProperty({ required: false, description: 'Customer name' })
    @IsOptional()
    @IsString()
    customerName?: string;

    @ApiProperty({ required: false, description: 'Customer email' })
    @IsOptional()
    @IsString()
    customerEmail?: string;

    @ApiProperty({ required: false, description: 'Order ID' })
    @IsOptional()
    @IsString()
    orderId?: string;

    @ApiProperty({ required: false, description: 'Product ID' })
    @IsOptional()
    @IsString()
    productId?: string;

    @ApiProperty({ required: false, description: 'Tags', type: [String] })
    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    tags?: string[];

    @ApiProperty({ required: false, description: 'Start date (ISO format)' })
    @IsOptional()
    @IsDateString()
    fromDate?: string;

    @ApiProperty({ required: false, description: 'End date (ISO format)' })
    @IsOptional()
    @IsDateString()
    toDate?: string;

    @ApiProperty({ required: false, description: 'Has attachments' })
    @IsOptional()
    hasAttachments?: boolean;

    @ApiProperty({ required: false, description: 'SLA breached' })
    @IsOptional()
    slaBreached?: boolean;

    @ApiProperty({ required: false, description: 'Has rating' })
    @IsOptional()
    hasRating?: boolean;

    @ApiProperty({ required: false, description: 'Search in messages content' })
    @IsOptional()
    @IsString()
    messageContent?: string;

    @ApiProperty({ required: false, description: 'Page number', minimum: 1, default: 1 })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    @Min(1)
    page?: number = 1;

    @ApiProperty({ required: false, description: 'Items per page', minimum: 1, maximum: 100, default: 20 })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    @Min(1)
    @Max(100)
    limit?: number = 20;

    @ApiProperty({ required: false, description: 'Sort field', default: 'createdAt' })
    @IsOptional()
    @IsString()
    sortBy?: string = 'createdAt';

    @ApiProperty({ required: false, description: 'Sort order', enum: ['asc', 'desc'], default: 'desc' })
    @IsOptional()
    @IsEnum(['asc', 'desc'])
    sortOrder?: 'asc' | 'desc' = 'desc';
}
