import { IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ProcessRefundDto {
  @ApiProperty({
    description: 'Refund amount',
    example: 500.0,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  amount: number;

  @ApiPropertyOptional({
    description: 'Notes',
    example: 'تم معالجة الاسترداد',
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({
    description: 'Bank details (if refund method is bank_transfer)',
    type: 'object',
  })
  @IsOptional()
  bankDetails?: {
    bankName?: string;
    accountNumber?: string;
    iban?: string;
    accountHolderName?: string;
  };
}
