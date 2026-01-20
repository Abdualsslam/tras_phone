import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RejectPasswordResetDto {
  @ApiProperty({
    description: 'Reason for rejecting the password reset request',
    example: 'Customer identity could not be verified',
  })
  @IsString()
  @IsNotEmpty()
  rejectionReason: string;

  @ApiPropertyOptional({
    description: 'Admin notes about rejecting the request',
    example: 'Customer needs to contact support directly',
  })
  @IsString()
  @IsOptional()
  adminNotes?: string;
}
