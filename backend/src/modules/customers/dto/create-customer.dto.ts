import { ApiProperty } from '@nestjs/swagger';
import {
    IsString,
    IsNotEmpty,
    IsOptional,
    IsEnum,
    IsMongoId,
    IsNumber,
    IsDateString,
    IsBoolean,
    Min,
    Max,
} from 'class-validator';

export class CreateCustomerDto {
    @ApiProperty({
        description: 'User ID (must be an existing user with userType=customer)',
    })
    @IsMongoId()
    @IsNotEmpty()
    userId: string;

    @ApiProperty({ example: 'Ahmed Ali' })
    @IsString()
    @IsNotEmpty()
    responsiblePersonName: string;

    @ApiProperty({ example: 'Phone Repair Center' })
    @IsString()
    @IsNotEmpty()
    shopName: string;

    @ApiProperty({ example: 'مركز صيانة الجوالات', required: false })
    @IsString()
    @IsOptional()
    shopNameAr?: string;

    @ApiProperty({
        enum: ['shop', 'technician', 'distributor', 'other'],
        default: 'shop',
    })
    @IsEnum(['shop', 'technician', 'distributor', 'other'])
    @IsOptional()
    businessType?: string;

    @ApiProperty({ description: 'City ID' })
    @IsMongoId()
    @IsNotEmpty()
    cityId: string;

    @ApiProperty({ description: 'Market ID', required: false })
    @IsMongoId()
    @IsOptional()
    marketId?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    address?: string;

    @ApiProperty({ required: false })
    @IsNumber()
    @IsOptional()
    latitude?: number;

    @ApiProperty({ required: false })
    @IsNumber()
    @IsOptional()
    longitude?: number;

    // Documents
    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    commercialLicenseFile?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    commercialLicenseNumber?: string;

    @ApiProperty({ required: false })
    @IsDateString()
    @IsOptional()
    commercialLicenseExpiry?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    taxNumber?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    nationalId?: string;

    // Pricing
    @ApiProperty({ description: 'Price Level ID' })
    @IsMongoId()
    @IsNotEmpty()
    priceLevelId: string;

    @ApiProperty({ default: 0, required: false })
    @IsNumber()
    @IsOptional()
    @Min(0)
    creditLimit?: number;

    // Preferences
    @ApiProperty({
        enum: ['cod', 'bank_transfer', 'wallet'],
        required: false,
    })
    @IsEnum(['cod', 'bank_transfer', 'wallet'])
    @IsOptional()
    preferredPaymentMethod?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    preferredShippingTime?: string;

    @ApiProperty({
        enum: ['phone', 'whatsapp', 'email'],
        default: 'whatsapp',
        required: false,
    })
    @IsEnum(['phone', 'whatsapp', 'email'])
    @IsOptional()
    preferredContactMethod?: string;

    // Social Media
    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    instagramHandle?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    twitterHandle?: string;

    // Personal
    @ApiProperty({ required: false })
    @IsDateString()
    @IsOptional()
    birthDate?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    internalNotes?: string;

    @ApiProperty({
        required: false,
        default: true,
        description: 'Whether tax should be applied to this customer',
    })
    @IsBoolean()
    @IsOptional()
    isTaxable?: boolean;
}
