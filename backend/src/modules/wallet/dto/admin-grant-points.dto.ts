import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';

export class AdminGrantPointsDto {
    @ApiProperty({ description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @IsMongoId()
    customerId: string;

    @ApiProperty({ description: 'Points to grant', example: 250, minimum: 1 })
    @IsNumber()
    @Min(1)
    points: number;

    @ApiProperty({ description: 'Reason for points adjustment', example: 'Compensation for delayed shipment' })
    @IsString()
    @IsNotEmpty()
    reason: string;
}
