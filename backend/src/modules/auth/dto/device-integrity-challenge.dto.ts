import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class DeviceIntegrityChallengeDto {
  @ApiProperty({
    example: 'auth.login',
    description: 'Logical action being protected by the integrity request',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  requestType: string;
}
