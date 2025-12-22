import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches } from 'class-validator';

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
}
