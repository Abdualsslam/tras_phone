import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsMongoId, Matches } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Create Admin User DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class CreateAdminDto {
    @ApiProperty({
        description: 'User ID (must be an existing user with userType=admin)',
        example: '507f1f77bcf86cd799439011',
    })
    @IsMongoId()
    @IsNotEmpty()
    userId: string;

    @ApiProperty({
        example: 'Ahmed Ali',
        description: 'Full name of the admin user',
    })
    @IsString()
    @IsNotEmpty()
    fullName: string;

    @ApiProperty({
        example: 'أحمد علي',
        description: 'Full name in Arabic',
        required: false,
    })
    @IsString()
    @IsOptional()
    fullNameAr?: string;

    @ApiProperty({
        example: 'IT',
        description: 'Department name',
        required: false,
    })
    @IsString()
    @IsOptional()
    department?: string;

    @ApiProperty({
        example: 'Software Engineer',
        description: 'Job position',
        required: false,
    })
    @IsString()
    @IsOptional()
    position?: string;

    @ApiProperty({
        example: '+966501234567',
        description: 'Direct phone number',
        required: false,
    })
    @IsString()
    @IsOptional()
    @Matches(/^\+?[1-9]\d{1,14}$/, {
        message: 'Phone number must be a valid international format',
    })
    directPhone?: string;

    @ApiProperty({
        example: '1234',
        description: 'Phone extension',
        required: false,
    })
    @IsString()
    @IsOptional()
    extension?: string;

    @ApiProperty({
        example: false,
        description: 'Whether this admin is a super admin',
        default: false,
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    isSuperAdmin?: boolean;

    @ApiProperty({
        example: false,
        description: 'Whether this admin can access mobile app',
        default: false,
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    canAccessMobile?: boolean;

    @ApiProperty({
        example: true,
        description: 'Whether this admin can access web dashboard',
        default: true,
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    canAccessWeb?: boolean;
}
