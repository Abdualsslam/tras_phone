import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsString, IsOptional, IsArray, Min, Max, ArrayMaxSize } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * ⭐ Add Product Review DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class AddReviewDto {
    @ApiProperty({
        example: 5,
        description: 'Rating (1-5)',
        minimum: 1,
        maximum: 5,
    })
    @IsNumber()
    @Min(1)
    @Max(5)
    rating: number;

    @ApiProperty({
        example: 'Great product!',
        description: 'Review title',
        required: false,
    })
    @IsString()
    @IsOptional()
    title?: string;

    @ApiProperty({
        example: 'Excellent quality and fast delivery. Highly recommended!',
        description: 'Review comment',
        required: false,
    })
    @IsString()
    @IsOptional()
    comment?: string;

    @ApiProperty({
        type: [String],
        example: ['https://example.com/review1.jpg'],
        description: 'Review images URLs',
        required: false,
        maxItems: 5,
    })
    @IsArray()
    @IsString({ each: true })
    @ArrayMaxSize(5)
    @IsOptional()
    images?: string[];
}
