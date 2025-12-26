import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsMongoId, IsNumber, IsDateString, Min } from 'class-validator';

export class UpdateCustomerDto {
    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    responsiblePersonName?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    shopName?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    shopNameAr?: string;

    @ApiProperty({ enum: ['shop', 'technician', 'distributor', 'other'], required: false })
    @IsEnum(['shop', 'technician', 'distributor', 'other'])
    @IsOptional()
    businessType?: string;

    @ApiProperty({ required: false })
    @IsMongoId()
    @IsOptional()
    cityId?: string;

    @ApiProperty({ required: false })
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

    @ApiProperty({ required: false })
    @IsMongoId()
    @IsOptional()
    priceLevelId?: string;

    @ApiProperty({ required: false })
    @IsNumber()
    @IsOptional()
    @Min(0)
    creditLimit?: number;

    @ApiProperty({ enum: ['cod', 'bank_transfer', 'wallet'], required: false })
    @IsEnum(['cod', 'bank_transfer', 'wallet'])
    @IsOptional()
    preferredPaymentMethod?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    preferredShippingTime?: string;

    @ApiProperty({ enum: ['phone', 'whatsapp', 'email'], required: false })
    @IsEnum(['phone', 'whatsapp', 'email'])
    @IsOptional()
    preferredContactMethod?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    instagramHandle?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    twitterHandle?: string;

    @ApiProperty({ required: false })
    @IsDateString()
    @IsOptional()
    birthDate?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    internalNotes?: string;
}
