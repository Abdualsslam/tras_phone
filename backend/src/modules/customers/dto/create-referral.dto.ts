import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsNotEmpty } from 'class-validator';

export class CreateReferralDto {
    @ApiProperty({ description: 'Referrer customer ID' })
    @IsMongoId()
    @IsNotEmpty()
    referrerId: string;

    @ApiProperty({ description: 'Referred customer ID' })
    @IsMongoId()
    @IsNotEmpty()
    referredId: string;

    @ApiProperty({ description: 'Referral code used' })
    @IsNotEmpty()
    referralCode: string;
}
