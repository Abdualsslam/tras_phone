import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsMongoId } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎭 Assign Role DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AssignRoleDto {
    @ApiProperty({
        description: 'Role ID to assign',
        example: '507f1f77bcf86cd799439011',
    })
    @IsMongoId()
    @IsNotEmpty()
    roleId: string;

    @ApiProperty({
        description: 'ID of admin who is assigning the role',
        example: '507f1f77bcf86cd799439012',
        required: false,
    })
    @IsMongoId()
    @IsOptional()
    assignedBy?: string;
}
