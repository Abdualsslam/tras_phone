import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsMongoId } from 'class-validator';

export class UploadReceiptDto {
  @ApiProperty({
    description: 'Receipt image URL or base64',
    example: 'https://example.com/receipt.jpg',
  })
  @IsString()
  receiptImage: string;

  @ApiProperty({
    description: 'Transfer reference number',
    required: false,
    example: 'TRF123456789',
  })
  @IsOptional()
  @IsString()
  transferReference?: string;

  @ApiProperty({
    description: 'Transfer date',
    required: false,
    example: '2024-01-15',
  })
  @IsOptional()
  @IsString()
  transferDate?: string;

  @ApiProperty({
    description: 'Notes',
    required: false,
    example: 'Payment completed via bank transfer',
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({
    description: 'Selected bank account ID',
    required: false,
    example: '507f1f77bcf86cd799439011',
  })
  @IsOptional()
  @IsMongoId()
  bankAccountId?: string;
}
