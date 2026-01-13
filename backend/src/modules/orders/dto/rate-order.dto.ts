import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, Min, Max, IsOptional, IsString } from 'class-validator';

export class RateOrderDto {
  @ApiProperty({
    description: 'Rating (1-5)',
    minimum: 1,
    maximum: 5,
    example: 5,
  })
  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiProperty({
    description: 'Review comment',
    required: false,
    example: 'Great service and fast delivery!',
  })
  @IsOptional()
  @IsString()
  comment?: string;
}
