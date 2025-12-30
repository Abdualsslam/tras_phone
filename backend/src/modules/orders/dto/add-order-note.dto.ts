import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Add Order Note DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AddOrderNoteDto {
    @ApiProperty({
        description: 'Note content',
        example: 'Customer requested priority handling',
    })
    @IsString()
    @IsNotEmpty()
    content: string;

    @ApiProperty({
        description: 'Note type',
        enum: ['internal', 'customer', 'system'],
        example: 'internal',
        default: 'internal',
        required: false,
    })
    @IsString()
    @IsOptional()
    @IsEnum(['internal', 'customer', 'system'])
    type?: string;
}

