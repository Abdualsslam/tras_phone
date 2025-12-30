import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, Matches } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Update Admin User DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UpdateAdminDto {
    @ApiProperty({
        example: 'Ahmed Ali',
        description: 'Full name of the admin user',
        required: false,
    })
    @IsString()
    @IsOptional()
    fullName?: string;

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
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    isSuperAdmin?: boolean;

    @ApiProperty({
        example: false,
        description: 'Whether this admin can access mobile app',
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    canAccessMobile?: boolean;

    @ApiProperty({
        example: true,
        description: 'Whether this admin can access web dashboard',
        required: false,
    })
    @IsBoolean()
    @IsOptional()
    canAccessWeb?: boolean;

    @ApiProperty({
        example: 'active',
        enum: ['active', 'on_leave', 'suspended', 'terminated'],
        description: 'Employment status',
        required: false,
    })
    @IsString()
    @IsOptional()
    employmentStatus?: string;
}
