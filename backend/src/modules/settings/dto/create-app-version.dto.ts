import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsNumber,
  IsArray,
  IsEnum,
  IsUrl,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAppVersionDto {
  @ApiProperty({ enum: ['ios', 'android'] })
  @IsEnum(['ios', 'android'])
  @IsNotEmpty()
  platform: 'ios' | 'android';

  @ApiProperty({ example: '1.2.0' })
  @IsString()
  @IsNotEmpty()
  version: string;

  @ApiProperty({ example: 12 })
  @IsNumber()
  buildNumber: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  releaseNotes?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  releaseNotesAr?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsOptional()
  features?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsOptional()
  bugFixes?: string[];

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  isForceUpdate?: boolean;

  @ApiPropertyOptional({ example: '1.0.0' })
  @IsString()
  @IsOptional()
  minSupportedVersion?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isCurrent?: boolean;

  @ApiPropertyOptional()
  @IsUrl()
  @IsOptional()
  storeUrl?: string;

  @ApiPropertyOptional()
  @IsUrl()
  @IsOptional()
  downloadUrl?: string;
}

export class UpdateAppVersionDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  releaseNotes?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  releaseNotesAr?: string;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  features?: string[];

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  bugFixes?: string[];

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isForceUpdate?: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  minSupportedVersion?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isCurrent?: boolean;

  @ApiPropertyOptional()
  @IsUrl()
  @IsOptional()
  storeUrl?: string;

  @ApiPropertyOptional()
  @IsUrl()
  @IsOptional()
  downloadUrl?: string;
}

export class CheckAppVersionDto {
  @ApiProperty({ enum: ['ios', 'android'] })
  @IsEnum(['ios', 'android'])
  @IsNotEmpty()
  platform: 'ios' | 'android';

  @ApiProperty({ example: '1.1.0' })
  @IsString()
  @IsNotEmpty()
  currentVersion: string;
}
