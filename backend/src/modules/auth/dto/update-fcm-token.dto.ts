import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsObject } from 'class-validator';

export class UpdateFcmTokenDto {
  @ApiProperty({
    description: 'FCM token for push notifications',
    example: 'dGhpc2lzYW5mY210b2tlbg==',
  })
  @IsString()
  fcmToken: string;

  @ApiProperty({
    description: 'Device information',
    required: false,
    example: {
      deviceType: 'mobile',
      deviceName: 'iPhone 14 Pro',
      deviceId: 'unique-device-id',
      appVersion: '1.0.0',
    },
  })
  @IsOptional()
  @IsObject()
  deviceInfo?: Record<string, any>;
}
