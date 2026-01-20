import { IsString, IsNotEmpty, Matches, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RequestPasswordResetDto {
  @ApiProperty({
    description: 'Phone number in international format',
    example: '+966501234567',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{1,14}$/, {
    message: 'Phone number must be in valid international format',
  })
  phone: string;

  @ApiPropertyOptional({
    description: 'Customer notes about the password reset request',
    example: 'I forgot my password and cannot access my account',
  })
  @IsString()
  @IsOptional()
  customerNotes?: string;
}
