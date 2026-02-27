import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class AdminDebitWalletDto {
    @ApiProperty({ description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @IsMongoId()
    customerId: string;

    @ApiProperty({ description: 'Amount to deduct from wallet', example: 75, minimum: 0.01 })
    @IsNumber()
    @Min(0.01)
    amount: number;

    @ApiProperty({ description: 'Reason/description for debit action', example: 'Correction for duplicated credit' })
    @IsString()
    @IsNotEmpty()
    description: string;

    @ApiProperty({ description: 'Optional reference number', example: 'CASE-20260227-019', required: false })
    @IsString()
    @IsOptional()
    reference?: string;
}
