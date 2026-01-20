import { IsString, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class ProcessPasswordResetDto {
  @ApiPropertyOptional({
    description: 'Admin notes about processing the request',
    example: 'Password reset and sent to customer via WhatsApp',
  })
  @IsString()
  @IsOptional()
  adminNotes?: string;
}
