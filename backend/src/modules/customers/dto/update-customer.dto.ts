import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsMongoId, IsNumber, IsDateString, Min, IsEmail, Matches, IsBoolean } from 'class-validator';

export class UpdateCustomerDto {
    // ═════════════════════════════════════
    // User fields (for updating linked user)
    // ═════════════════════════════════════
    @ApiProperty({ 
        required: false,
        example: '+966501234567',
        description: 'User phone number with country code'
    })
    @IsString()
    @IsOptional()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone?: string;

    @ApiProperty({ 
        required: false,
        example: 'user@example.com',
        description: 'User email address'
    })
    @IsEmail()
    @IsOptional()
    email?: string;

    @ApiProperty({ 
        enum: ['pending', 'active', 'suspended', 'deleted'],
        required: false,
        description: 'User account status'
    })
    @IsEnum(['pending', 'active', 'suspended', 'deleted'])
    @IsOptional()
    userStatus?: string;

    // ═════════════════════════════════════
    // Customer fields
    // ═════════════════════════════════════
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

    // ═════════════════════════════════════
    // Additional Customer fields
    // ═════════════════════════════════════
    @ApiProperty({ required: false, description: 'Wallet balance' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    walletBalance?: number;

    @ApiProperty({ required: false, description: 'Loyalty points' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    loyaltyPoints?: number;

    @ApiProperty({ enum: ['bronze', 'silver', 'gold', 'platinum'], required: false })
    @IsEnum(['bronze', 'silver', 'gold', 'platinum'])
    @IsOptional()
    loyaltyTier?: string;

    @ApiProperty({ required: false, description: 'Assigned sales representative ID' })
    @IsMongoId()
    @IsOptional()
    assignedSalesRepId?: string;

    @ApiProperty({ required: false, description: 'Is customer flagged' })
    @IsBoolean()
    @IsOptional()
    isFlagged?: boolean;

    @ApiProperty({ required: false, description: 'Flag reason' })
    @IsString()
    @IsOptional()
    flagReason?: string;

    // ═════════════════════════════════════
    // Payment & Refund Permissions
    // ═════════════════════════════════════
    @ApiProperty({ required: false, description: 'Allow cash refund (original payment method or bank transfer)', default: false })
    @IsBoolean()
    @IsOptional()
    canCashRefund?: boolean;

    @ApiProperty({ required: false, description: 'Allow cash on delivery payment method', default: true })
    @IsBoolean()
    @IsOptional()
    canCashOnDelivery?: boolean;
}
