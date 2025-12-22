import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches, Length } from 'class-validator';

export class VerifyOtpDto {
    @ApiProperty({
        example: '+966501234567',
        description: 'Phone number',
    })
    @IsString()
    @IsNotEmpty()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone: string;

    @ApiProperty({
        example: '123456',
        description: '6-digit OTP code',
    })
    @IsString()
    @IsNotEmpty()
    @Length(6, 6, { message: 'OTP must be exactly 6 digits' })
    otp: string;

    @ApiProperty({
        example: 'registration',
        enum: ['registration', 'login', 'password_reset', 'phone_change'],
        description: 'Purpose of OTP',
    })
    @IsString()
    @IsNotEmpty()
    purpose: 'registration' | 'login' | 'password_reset' | 'phone_change';
}
