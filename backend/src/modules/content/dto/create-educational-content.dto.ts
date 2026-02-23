import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsNumber,
  IsEnum,
  IsArray,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ContentType,
  ContentScope,
} from '../schemas/educational-content.schema';

export class ContentTargetingDto {
  @ApiPropertyOptional({
    type: [String],
    description:
      'Context targeting product IDs used for automatic content matching at runtime',
  })
  @IsArray()
  @IsOptional()
  products?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: 'Context targeting category IDs',
  })
  @IsArray()
  @IsOptional()
  categories?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: 'Context targeting brand IDs',
  })
  @IsArray()
  @IsOptional()
  brands?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: 'Context targeting device IDs',
  })
  @IsArray()
  @IsOptional()
  devices?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: 'Context targeting intent tags (normalized to lowercase)',
  })
  @IsArray()
  @IsOptional()
  intentTags?: string[];
}

export class CreateEducationalContentDto {
  @ApiProperty({ example: 'How to Replace iPhone Screen' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({ example: 'كيفية تبديل شاشة الآيفون' })
  @IsString()
  @IsOptional()
  titleAr?: string;

  @ApiProperty({ example: 'how-to-replace-iphone-screen' })
  @IsString()
  @IsNotEmpty()
  slug: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  categoryId: string;

  @ApiPropertyOptional({ enum: ContentType })
  @IsEnum(ContentType)
  @IsOptional()
  type?: ContentType;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  excerpt?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  excerptAr?: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  contentAr?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  featuredImage?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  videoUrl?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  videoDuration?: number;

  @ApiPropertyOptional({
    type: [String],
    description: 'Attachment URLs (images/videos/files)',
  })
  @IsArray()
  @IsOptional()
  attachments?: string[];

  @ApiPropertyOptional({
    type: [String],
    description:
      'Directly related product IDs shown explicitly as linked products in content UI',
  })
  @IsArray()
  @IsOptional()
  relatedProducts?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: 'Other related educational content IDs',
  })
  @IsArray()
  @IsOptional()
  relatedContent?: string[];

  @ApiPropertyOptional({ enum: ContentScope, default: ContentScope.GENERAL })
  @IsEnum(ContentScope)
  @IsOptional()
  scope?: ContentScope;

  @ApiPropertyOptional({
    type: ContentTargetingDto,
    description:
      'Contextual targeting rules for automatic content retrieval based on runtime context',
  })
  @IsOptional()
  targeting?: ContentTargetingDto;

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsOptional()
  tags?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  metaTitle?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  metaDescription?: string;

  @ApiPropertyOptional({ enum: ['draft', 'published', 'archived'] })
  @IsString()
  @IsOptional()
  status?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  readingTime?: number;

  @ApiPropertyOptional({ enum: ['beginner', 'intermediate', 'advanced'] })
  @IsString()
  @IsOptional()
  difficulty?: string;
}

export class UpdateEducationalContentDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  title?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  titleAr?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsEnum(ContentType)
  @IsOptional()
  type?: ContentType;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  excerpt?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  excerptAr?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  content?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  contentAr?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  featuredImage?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  videoUrl?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  videoDuration?: number;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  attachments?: string[];

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  relatedProducts?: string[];

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  relatedContent?: string[];

  @ApiPropertyOptional({ enum: ContentScope })
  @IsEnum(ContentScope)
  @IsOptional()
  scope?: ContentScope;

  @ApiPropertyOptional({ type: ContentTargetingDto })
  @IsOptional()
  targeting?: ContentTargetingDto;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  tags?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  metaTitle?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  metaDescription?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  status?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  readingTime?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  difficulty?: string;
}
