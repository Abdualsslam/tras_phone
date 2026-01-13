import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsArray,
  IsDate,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class SendNotificationDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  customerId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  adminUserId?: string;

  @ApiProperty({ example: 'order' })
  @IsString()
  @IsNotEmpty()
  category: string;

  @ApiProperty({ example: 'Order Confirmed' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ example: 'تم تأكيد الطلب' })
  @IsString()
  @IsNotEmpty()
  titleAr: string;

  @ApiProperty({ example: 'Your order #123 has been confirmed' })
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiProperty({ example: 'تم تأكيد طلبك رقم #123' })
  @IsString()
  @IsNotEmpty()
  bodyAr: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  image?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionType?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionUrl?: string;

  @ApiPropertyOptional({ type: [String], default: ['push'] })
  @IsArray()
  @IsOptional()
  channels?: string[];

  @ApiPropertyOptional()
  @Type(() => Date)
  @IsDate()
  @IsOptional()
  scheduledAt?: Date;
}

export class CreateNotificationTemplateDto {
  @ApiProperty({ example: 'order_confirmed' })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({ example: 'Order Confirmed' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ example: 'تأكيد الطلب' })
  @IsString()
  @IsOptional()
  nameAr?: string;

  @ApiProperty({ example: 'order' })
  @IsString()
  @IsNotEmpty()
  category: string;

  @ApiProperty({ example: 'Order Confirmed ✅' })
  @IsString()
  @IsNotEmpty()
  pushTitle: string;

  @ApiProperty({ example: 'تم تأكيد طلبك ✅' })
  @IsString()
  @IsNotEmpty()
  pushTitleAr: string;

  @ApiProperty({ example: 'Your order #{{orderNumber}} has been confirmed' })
  @IsString()
  @IsNotEmpty()
  pushBody: string;

  @ApiProperty({ example: 'تم تأكيد طلبك رقم #{{orderNumber}}' })
  @IsString()
  @IsNotEmpty()
  pushBodyAr: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  pushImage?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsOptional()
  variables?: string[];

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  pushEnabled?: boolean;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  smsEnabled?: boolean;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  emailEnabled?: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  smsTemplate?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  emailSubject?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  emailTemplate?: string;
}

export class CreateCampaignDto {
  @ApiProperty({ example: 'Eid Sale Campaign' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ example: 'Big Eid Sale! 🎉' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ example: 'عروض العيد الكبرى! 🎉' })
  @IsString()
  @IsNotEmpty()
  titleAr: string;

  @ApiProperty({ example: 'Get up to 50% off on all products' })
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiProperty({ example: 'خصومات تصل إلى 50% على جميع المنتجات' })
  @IsString()
  @IsNotEmpty()
  bodyAr: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  image?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionType?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  actionUrl?: string;

  @ApiPropertyOptional({ type: [String], default: ['push'] })
  @IsArray()
  @IsOptional()
  channels?: string[];

  // Target Audience
  @ApiPropertyOptional({ example: 'all' })
  @IsString()
  @IsOptional()
  targetType?: string; // all, segment, specific

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsOptional()
  targetCustomerIds?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  targetFilters?: any;

  // Schedule
  @ApiPropertyOptional()
  @Type(() => Date)
  @IsDate()
  @IsOptional()
  scheduledAt?: Date;
}

export class RegisterPushTokenDto {
  @ApiProperty({ example: 'fcm_token_here...' })
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({ enum: ['fcm', 'apns'] })
  @IsString()
  @IsNotEmpty()
  provider: string;

  @ApiProperty({ enum: ['ios', 'android', 'web'] })
  @IsString()
  @IsNotEmpty()
  platform: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  deviceId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  deviceName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  appVersion?: string;
}
