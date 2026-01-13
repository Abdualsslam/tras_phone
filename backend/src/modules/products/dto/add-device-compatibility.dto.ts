import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, IsOptional, IsBoolean } from 'class-validator';

export class AddDeviceCompatibilityDto {
  @ApiProperty({
    description: 'Device IDs to link with product',
    type: [String],
    example: ['507f1f77bcf86cd799439011'],
  })
  @IsArray()
  deviceIds: string[];

  @ApiProperty({
    description: 'Compatibility notes',
    required: false,
    example: 'Compatible with iPhone 14 and iPhone 14 Pro',
  })
  @IsOptional()
  @IsString()
  compatibilityNotes?: string;

  @ApiProperty({
    description: 'Whether compatibility is verified',
    required: false,
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;
}
