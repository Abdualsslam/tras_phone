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

    @ApiProperty({ description: 'City ID', required: false })
    @IsMongoId()
    @IsOptional()
    cityId?: string;

    @ApiProperty({ description: 'City Name (text)', required: false })
    @IsString()
    @IsOptional()
    cityName?: string;

    @ApiProperty({ description: 'Market/Area Name (text)', required: false })
    @IsString()
    @IsOptional()
    marketName?: string;

    @ApiProperty({ example: 'Street 123, Building 5, Floor 2' })
    @IsString()
    @IsNotEmpty()
    addressLine: string;

    @ApiProperty({ description: 'Latitude', example: 24.7136 })
    @IsNumber()
    @IsNotEmpty()
    latitude: number;

    @ApiProperty({ description: 'Longitude', example: 46.6753 })
    @IsNumber()
    @IsNotEmpty()
    longitude: number;

    @ApiProperty({ description: 'Notes (e.g., Delivery during day)', required: false })
    @IsString()
    @IsOptional()
    notes?: string;

    @ApiProperty({ default: false, required: false })
    @IsBoolean()
    @IsOptional()
    isDefault?: boolean;
}
