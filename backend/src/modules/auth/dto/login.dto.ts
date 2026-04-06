import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, Matches, IsOptional, ValidateNested } from 'class-validator';
import { DeviceIntegrityDto } from './device-integrity.dto';

export class LoginDto {
    @ApiProperty({
        example: '+966501234567',
        description: 'User phone number'
    })
    @IsString()
    @IsNotEmpty()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone: string;

    @ApiProperty({
        example: 'StrongP@ss123',
        description: 'User password'
    })
    @IsString()
    @IsNotEmpty()
    password: string;

    @ApiProperty({
        required: false,
        type: DeviceIntegrityDto,
        description: 'Device integrity payload used to bind sessions to trusted app builds'
    })
    @IsOptional()
    @ValidateNested()
    @Type(() => DeviceIntegrityDto)
    deviceIntegrity?: DeviceIntegrityDto;
}
