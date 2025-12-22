import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class SendOtpDto {
    @ApiProperty({
        example: '+966501234567',
        description: 'Phone number to send OTP to',
    })
    @IsString()
    @IsNotEmpty()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone: string;

    @ApiProperty({
        example: 'registration',
        enum: ['registration', 'login', 'password_reset', 'phone_change'],
        description: 'Purpose of OTP',
    })
    @IsString()
    @IsNotEmpty()
    purpose: 'registration' | 'login' | 'password_reset' | 'phone_change';
}
