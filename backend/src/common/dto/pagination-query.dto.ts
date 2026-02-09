import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional, IsInt, Min, Max } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📄 Pagination Query DTO
 * ═══════════════════════════════════════════════════════════════
 * Common pagination parameters for list endpoints
 */
export class PaginationQueryDto {
    @ApiProperty({
        example: 1,
        description: 'Page number (starts from 1)',
        required: false,
        minimum: 1,
        default: 1,
    })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(1)
    page?: number = 1;

    @ApiProperty({
        example: 20,
        description: 'Number of items per page',
        required: false,
        minimum: 1,
        maximum: 1000,
        default: 20,
    })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(1)
    @Max(1000)
    limit?: number = 20;
}
