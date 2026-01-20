import { ApiProperty } from '@nestjs/swagger';
import {
    IsString,
    IsNotEmpty,
    IsOptional,
    IsNumber,
    IsBoolean,
    IsArray,
    Min,
    Max,
} from 'class-validator';

export class CreateTierDto {
    @ApiProperty({ example: 'Bronze', description: 'Tier name in English' })
    @IsString()
    @IsNotEmpty()
    name: string;

    @ApiProperty({ example: 'برونزي', description: 'Tier name in Arabic' })
    @IsString()
    @IsNotEmpty()
    nameAr: string;

    @ApiProperty({ example: 'bronze', description: 'Unique tier code' })
    @IsString()
    @IsNotEmpty()
    code: string;

    @ApiProperty({ example: 0, description: 'Minimum points required to reach this tier' })
    @IsNumber()
    @Min(0)
    minPoints: number;

    @ApiProperty({ example: 1, description: 'Points multiplier (1x, 1.5x, 2x)', default: 1 })
    @IsNumber()
    @Min(0.1)
    pointsMultiplier: number;

    @ApiProperty({ example: 0, description: 'Discount percentage (0-100)', default: 0, required: false })
    @IsNumber()
    @Min(0)
    @Max(100)
    @IsOptional()
    discountPercentage?: number;

    @ApiProperty({ example: false, description: 'Free shipping benefit', default: false, required: false })
    @IsBoolean()
    @IsOptional()
    freeShipping?: boolean;

    @ApiProperty({ example: false, description: 'Priority support benefit', default: false, required: false })
    @IsBoolean()
    @IsOptional()
    prioritySupport?: boolean;

    @ApiProperty({ example: false, description: 'Early access to sales', default: false, required: false })
    @IsBoolean()
    @IsOptional()
    earlyAccess?: boolean;

    @ApiProperty({ example: '#CD7F32', description: 'Tier color (hex)', required: false })
    @IsString()
    @IsOptional()
    color?: string;

    @ApiProperty({ example: 1, description: 'Display order', default: 0, required: false })
    @IsNumber()
    @IsOptional()
    displayOrder?: number;

    @ApiProperty({ example: 'Basic tier for all customers', description: 'Tier description in English', required: false })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiProperty({ example: 'المستوى الأساسي لجميع العملاء', description: 'Tier description in Arabic', required: false })
    @IsString()
    @IsOptional()
    descriptionAr?: string;

    @ApiProperty({ example: 0, description: 'Minimum spend amount (alternative qualification)', required: false })
    @IsNumber()
    @Min(0)
    @IsOptional()
    minSpend?: number;

    @ApiProperty({ example: 0, description: 'Minimum order count (alternative qualification)', required: false })
    @IsNumber()
    @Min(0)
    @IsOptional()
    minOrders?: number;

    @ApiProperty({ example: ['icon-name'], description: 'Tier icon name', required: false })
    @IsString()
    @IsOptional()
    icon?: string;

    @ApiProperty({ example: 'https://example.com/badge.png', description: 'Badge image URL', required: false })
    @IsString()
    @IsOptional()
    badgeImage?: string;

    @ApiProperty({ example: ['Benefit 1', 'Benefit 2'], description: 'Custom benefits list', required: false })
    @IsArray()
    @IsString({ each: true })
    @IsOptional()
    customBenefits?: string[];

    @ApiProperty({ example: true, description: 'Is tier active', default: true, required: false })
    @IsBoolean()
    @IsOptional()
    isActive?: boolean;
}
