import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsNumber, IsBoolean, Min, Max } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Create Price Level DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class CreatePriceLevelDto {
    @ApiProperty({ example: 'Retail', description: 'Price level name' })
    @IsString()
    @IsNotEmpty()
    name: string;

    @ApiProperty({ example: 'تجزئة', description: 'Price level name in Arabic' })
    @IsString()
    @IsNotEmpty()
    nameAr: string;

    @ApiProperty({ example: 'retail', description: 'Unique code for price level' })
    @IsString()
    @IsNotEmpty()
    code: string;

    @ApiProperty({ example: 'Retail customers pricing', required: false })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiProperty({ example: 0, description: 'Default discount percentage', default: 0 })
    @IsNumber()
    @IsOptional()
    @Min(0)
    @Max(100)
    discountPercentage?: number;

    @ApiProperty({ example: 0, required: false, description: 'Minimum order amount to qualify' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    minOrderAmount?: number;

    @ApiProperty({ example: '#3B82F6', required: false, description: 'Color code for display' })
    @IsString()
    @IsOptional()
    color?: string;

    @ApiProperty({ example: 0, description: 'Display order', default: 0 })
    @IsNumber()
    @IsOptional()
    @Min(0)
    displayOrder?: number;

    @ApiProperty({ example: true, description: 'Is active', default: true })
    @IsBoolean()
    @IsOptional()
    isActive?: boolean;

    @ApiProperty({ example: false, description: 'Is default for new customers', default: false })
    @IsBoolean()
    @IsOptional()
    isDefault?: boolean;
}
