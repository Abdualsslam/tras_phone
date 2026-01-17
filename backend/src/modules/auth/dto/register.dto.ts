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
    IsMongoId,
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

    // ═════════════════════════════════════
    // Customer Profile Fields (Optional)
    // ═════════════════════════════════════
    @ApiProperty({
        example: 'Ahmed Ali',
        description: 'Responsible person name (required if userType is customer)',
        required: false
    })
    @IsString()
    @IsOptional()
    responsiblePersonName?: string;

    @ApiProperty({
        example: 'Phone Repair Center',
        description: 'Shop name (required if userType is customer)',
        required: false
    })
    @IsString()
    @IsOptional()
    shopName?: string;

    @ApiProperty({
        example: 'مركز صيانة الجوالات',
        description: 'Shop name in Arabic',
        required: false
    })
    @IsString()
    @IsOptional()
    shopNameAr?: string;

    @ApiProperty({
        description: 'City ID (required if userType is customer)',
        required: false
    })
    @IsMongoId()
    @IsOptional()
    cityId?: string;

    @ApiProperty({
        enum: ['shop', 'technician', 'distributor', 'other'],
        default: 'shop',
        description: 'Business type',
        required: false
    })
    @IsEnum(['shop', 'technician', 'distributor', 'other'])
    @IsOptional()
    businessType?: string;
}
