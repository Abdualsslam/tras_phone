import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class VerifyPaymentDto {
  @ApiProperty({
    description: 'Verification status',
    example: true,
  })
  @IsBoolean()
  verified: boolean;

  @ApiProperty({
    description: 'Rejection reason (if not verified)',
    required: false,
    example: 'Receipt image is unclear',
  })
  @IsOptional()
  @IsString()
  rejectionReason?: string;

  @ApiProperty({
    description: 'Admin notes',
    required: false,
    example: 'Payment verified and approved',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
