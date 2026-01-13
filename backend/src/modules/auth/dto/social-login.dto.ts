import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum, IsOptional } from 'class-validator';

export class SocialLoginDto {
  @ApiProperty({
    description: 'Social provider',
    enum: ['google', 'apple'],
    example: 'google',
  })
  @IsEnum(['google', 'apple'])
  provider: 'google' | 'apple';

  @ApiProperty({
    description: 'Access token from social provider',
    example: 'ya29.a0AfB_byD...',
  })
  @IsString()
  accessToken: string;

  @ApiProperty({
    description: 'ID token from social provider (for Apple)',
    required: false,
    example: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  @IsOptional()
  @IsString()
  idToken?: string;

  @ApiProperty({
    description: 'FCM token for push notifications',
    required: false,
    example: 'dGhpc2lzYW5mY210b2tlbg==',
  })
  @IsOptional()
  @IsString()
  fcmToken?: string;
}
