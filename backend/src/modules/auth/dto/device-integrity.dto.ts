import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class DeviceSecuritySignalsDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  platform: string;

  @ApiProperty()
  @IsBoolean()
  isDebuggable: boolean;

  @ApiProperty()
  @IsBoolean()
  isDebuggerAttached: boolean;

  @ApiProperty()
  @IsBoolean()
  isEmulator: boolean;

  @ApiProperty()
  @IsBoolean()
  hasTestKeys: boolean;

  @ApiProperty()
  @IsBoolean()
  hasRootFiles: boolean;

  @ApiProperty()
  @IsBoolean()
  hasMagiskFiles: boolean;

  @ApiProperty()
  @IsBoolean()
  hasHookFramework: boolean;

  @ApiProperty()
  @IsBoolean()
  hasFridaServer: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  packageName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  appVersion?: string;

  @ApiProperty({ type: [String] })
  @IsArray()
  @IsString({ each: true })
  issues: string[];
}

export class DeviceIntegrityDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  platform: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  requestType: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  requestHash: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  nonce?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  integrityToken?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  packageName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  appVersion?: string;

  @ApiProperty({ type: DeviceSecuritySignalsDto })
  @ValidateNested()
  @Type(() => DeviceSecuritySignalsDto)
  signals: DeviceSecuritySignalsDto;
}
