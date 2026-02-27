import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class AdminCreditWalletDto {
    @ApiProperty({ description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @IsMongoId()
    customerId: string;

    @ApiProperty({ description: 'Amount to add to wallet', example: 150, minimum: 0.01 })
    @IsNumber()
    @Min(0.01)
    amount: number;

    @ApiProperty({ description: 'Reason/description for credit action', example: 'Manual adjustment for support case' })
    @IsString()
    @IsNotEmpty()
    description: string;

    @ApiProperty({ description: 'Optional reference number', example: 'SUP-20260227-001', required: false })
    @IsString()
    @IsOptional()
    reference?: string;
}
