import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsBoolean, Min, Max } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Update Price Level DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UpdatePriceLevelDto {
    @ApiProperty({ example: 'Retail', required: false })
    @IsString()
    @IsOptional()
    name?: string;

    @ApiProperty({ example: 'تجزئة', required: false })
    @IsString()
    @IsOptional()
    nameAr?: string;

    @ApiProperty({ example: 'retail', required: false })
    @IsString()
    @IsOptional()
    code?: string;

    @ApiProperty({ example: 'Retail customers pricing', required: false })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiProperty({ example: 0, required: false })
    @IsNumber()
    @IsOptional()
    @Min(0)
    @Max(100)
    discountPercentage?: number;

    @ApiProperty({ example: 0, required: false })
    @IsNumber()
    @IsOptional()
    @Min(0)
    minOrderAmount?: number;

    @ApiProperty({ example: '#3B82F6', required: false })
    @IsString()
    @IsOptional()
    color?: string;

    @ApiProperty({ example: 0, required: false })
    @IsNumber()
    @IsOptional()
    @Min(0)
    displayOrder?: number;

    @ApiProperty({ example: true, required: false })
    @IsBoolean()
    @IsOptional()
    isActive?: boolean;

    @ApiProperty({ example: false, required: false })
    @IsBoolean()
    @IsOptional()
    isDefault?: boolean;
}
