import { ApiProperty } from '@nestjs/swagger';
import {
    IsString,
    IsNotEmpty,
    IsOptional,
    IsMongoId,
    IsBoolean,
    IsNumber,
} from 'class-validator';

export class CreateAddressDto {
    @ApiProperty({ example: 'Home' })
    @IsString()
    @IsNotEmpty()
    label: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    recipientName?: string;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    phone?: string;

    @ApiProperty({ description: 'City ID' })
    @IsMongoId()
    @IsNotEmpty()
    cityId: string;

    @ApiProperty({ description: 'Market ID', required: false })
    @IsMongoId()
    @IsOptional()
    marketId?: string;

    @ApiProperty({ example: 'Street 123, Building 5, Floor 2' })
    @IsString()
    @IsNotEmpty()
    addressLine: string;

    @ApiProperty({ required: false })
    @IsNumber()
    @IsOptional()
    latitude?: number;

    @ApiProperty({ required: false })
    @IsNumber()
    @IsOptional()
    longitude?: number;

    @ApiProperty({ default: false, required: false })
    @IsBoolean()
    @IsOptional()
    isDefault?: boolean;
}
