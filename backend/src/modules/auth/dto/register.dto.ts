import { ApiProperty } from '@nestjs/swagger';
import {
    IsString,
    IsNotEmpty,
    IsEmail,
    IsOptional,
    MinLength,
    MaxLength,
    Matches,
    IsEnum,
} from 'class-validator';

export class RegisterDto {
    @ApiProperty({
        example: '+966501234567',
        description: 'User phone number with country code'
    })
    @IsString()
    @IsNotEmpty()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    phone: string;

    @ApiProperty({
        example: 'user@example.com',
        description: 'User email address',
        required: false
    })
    @IsEmail()
    @IsOptional()
    email?: string;

    @ApiProperty({
        example: 'StrongP@ss123',
        description: 'User password (min 8 characters, must include uppercase, lowercase, number, and special character)'
    })
    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    @MaxLength(50)
    @Matches(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
        {
            message:
                'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character',
        },
    )
    password: string;

    @ApiProperty({
        example: 'customer',
        enum: ['customer', 'admin'],
        description: 'User type'
    })
    @IsString()
    @IsNotEmpty()
    @IsEnum(['customer', 'admin'])
    userType: string;
}
