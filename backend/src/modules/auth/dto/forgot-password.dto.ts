import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class ForgotPasswordDto {
    @ApiProperty({
        example: '+966501234567',
        description: 'Phone number to send password reset OTP',
    })
    @IsString()
    @IsNotEmpty()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone: string;
}
