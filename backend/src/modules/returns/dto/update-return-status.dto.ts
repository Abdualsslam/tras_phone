import { IsString, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateReturnStatusDto {
  @ApiProperty({
    description: 'New status',
    enum: [
      'pending',
      'approved',
      'rejected',
      'pickup_scheduled',
      'picked_up',
      'inspecting',
      'completed',
      'cancelled',
    ],
    example: 'approved',
  })
  @IsString()
  @IsEnum([
    'pending',
    'approved',
    'rejected',
    'pickup_scheduled',
    'picked_up',
    'inspecting',
    'completed',
    'cancelled',
  ])
  status: string;

  @ApiPropertyOptional({
    description: 'Admin notes',
    example: 'تمت الموافقة على طلب الإرجاع',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
