import { ApiProperty } from '@nestjs/swagger';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Admin User Response DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UserBasicInfoDto {
    @ApiProperty({ example: '507f1f77bcf86cd799439011' })
    _id: string;

    @ApiProperty({ example: '+966501234567' })
    phone: string;

    @ApiProperty({ example: 'user@example.com', required: false })
    email?: string;

    @ApiProperty({ example: 'https://example.com/avatar.jpg', required: false })
    avatar?: string;
}

export class AdminResponseDto {
    @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Admin user ID' })
    _id: string;

    @ApiProperty({ type: UserBasicInfoDto, description: 'Associated user information' })
    userId: UserBasicInfoDto;

    @ApiProperty({ example: 'EMP001', description: 'Employee code' })
    employeeCode: string;

    @ApiProperty({ example: 'Ahmed Ali', description: 'Full name' })
    fullName: string;

    @ApiProperty({ example: 'أحمد علي', required: false, description: 'Full name in Arabic' })
    fullNameAr?: string;

    @ApiProperty({ example: 'IT', required: false, description: 'Department' })
    department?: string;

    @ApiProperty({ example: 'Software Engineer', required: false, description: 'Position' })
    position?: string;

    @ApiProperty({ example: false, description: 'Whether user is super admin' })
    isSuperAdmin: boolean;

    @ApiProperty({ example: false, description: 'Can access mobile app' })
    canAccessMobile: boolean;

    @ApiProperty({ example: true, description: 'Can access web dashboard' })
    canAccessWeb: boolean;

    @ApiProperty({ example: '+966501234567', required: false, description: 'Direct phone' })
    directPhone?: string;

    @ApiProperty({ example: '1234', required: false, description: 'Extension' })
    extension?: string;

    @ApiProperty({
        example: 'active',
        enum: ['active', 'on_leave', 'suspended', 'terminated'],
        description: 'Employment status',
    })
    employmentStatus: string;

    @ApiProperty({ example: 150, description: 'Total orders processed' })
    totalOrdersProcessed: number;

    @ApiProperty({ example: 50, description: 'Total customers managed' })
    totalCustomersManaged: number;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', required: false, description: 'Last activity timestamp' })
    lastActivityAt?: Date;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Creation timestamp' })
    createdAt: Date;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Last update timestamp' })
    updatedAt: Date;
}
