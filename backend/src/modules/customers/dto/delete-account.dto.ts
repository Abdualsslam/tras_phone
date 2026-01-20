import { IsString, IsOptional, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🗑️ Delete Account DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class DeleteAccountDto {
  @ApiProperty({
    description: 'Reason for account deletion (optional)',
    example: 'I no longer need this account',
    maxLength: 500,
    required: false,
  })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  reason?: string;
}
