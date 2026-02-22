import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsNumber, IsBoolean, IsArray, IsMongoId, Min, Max, ArrayMinSize } from 'class-validator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Create Product DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class CreateProductDto {
    @ApiProperty({ example: 'SKU001', description: 'Product SKU (unique)' })
    @IsString()
    @IsNotEmpty()
    sku: string;

    @ApiProperty({ example: 'iPhone 15 Pro Max', description: 'Product name' })
    @IsString()
    @IsNotEmpty()
    name: string;

    @ApiProperty({ example: 'آيفون 15 برو ماكس', description: 'Product name in Arabic' })
    @IsString()
    @IsNotEmpty()
    nameAr: string;

    @ApiProperty({ example: 'iphone-15-pro-max', description: 'URL-friendly slug (unique)' })
    @IsString()
    @IsNotEmpty()
    slug: string;

    @ApiProperty({ example: 'Latest iPhone with advanced features', required: false })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiProperty({ example: 'آخر طراز من آيفون مع ميزات متقدمة', required: false })
    @IsString()
    @IsOptional()
    descriptionAr?: string;

    @ApiProperty({ example: 'Premium smartphone', required: false })
    @IsString()
    @IsOptional()
    shortDescription?: string;

    @ApiProperty({ example: 'هاتف ذكي فاخر', required: false })
    @IsString()
    @IsOptional()
    shortDescriptionAr?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Brand ID' })
    @IsMongoId()
    @IsNotEmpty()
    brandId: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439012', description: 'Category ID' })
    @IsMongoId()
    @IsNotEmpty()
    categoryId: string;

    @ApiProperty({ type: [String], example: [], required: false, description: 'Additional category IDs' })
    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    additionalCategories?: string[];

    @ApiProperty({ example: '507f1f77bcf86cd799439013', description: 'Quality type ID' })
    @IsMongoId()
    @IsNotEmpty()
    qualityTypeId: string;

    @ApiProperty({ type: [String], example: [], required: false, description: 'Compatible device IDs' })
    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    compatibleDevices?: string[];

    @ApiProperty({ example: 1000.00, description: 'Base price' })
    @IsNumber()
    @IsNotEmpty()
    @Min(0)
    basePrice: number;

    @ApiProperty({ example: 1200.00, required: false, description: 'Compare at price (original price)' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    compareAtPrice?: number;

    @ApiProperty({ example: 800.00, required: false, description: 'Cost price' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    costPrice?: number;

    @ApiProperty({ example: 100, description: 'Stock quantity', default: 0 })
    @IsNumber()
    @IsOptional()
    @Min(0)
    stockQuantity?: number;

    @ApiProperty({ example: 5, description: 'Low stock threshold', default: 5 })
    @IsNumber()
    @IsOptional()
    @Min(0)
    lowStockThreshold?: number;

    @ApiProperty({ example: true, description: 'Track inventory', default: true })
    @IsBoolean()
    @IsOptional()
    trackInventory?: boolean;

    @ApiProperty({ example: false, description: 'Allow backorder', default: false })
    @IsBoolean()
    @IsOptional()
    allowBackorder?: boolean;

    @ApiProperty({ example: 1, description: 'Minimum order quantity', default: 1 })
    @IsNumber()
    @IsOptional()
    @Min(1)
    minOrderQuantity?: number;

    @ApiProperty({ example: 10, required: false, description: 'Maximum order quantity' })
    @IsNumber()
    @IsOptional()
    @Min(1)
    maxOrderQuantity?: number;

    @ApiProperty({ example: 'draft', enum: ['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'], default: 'draft' })
    @IsString()
    @IsOptional()
    status?: string;

    @ApiProperty({ example: true, description: 'Is active', default: true })
    @IsBoolean()
    @IsOptional()
    isActive?: boolean;

    @ApiProperty({ example: false, description: 'Is featured', default: false })
    @IsBoolean()
    @IsOptional()
    isFeatured?: boolean;

    @ApiProperty({ example: 'https://example.com/image.jpg', required: false, description: 'Main image URL' })
    @IsString()
    @IsOptional()
    mainImage?: string;

    @ApiProperty({ type: [String], example: [], required: false, description: 'Additional image URLs' })
    @IsArray()
    @IsString({ each: true })
    @IsOptional()
    images?: string[];

    @ApiProperty({ type: Object, example: {}, required: false, description: 'Product specifications' })
    @IsOptional()
    specifications?: Record<string, any>;

    @ApiProperty({ example: 200, required: false, description: 'Weight in grams' })
    @IsNumber()
    @IsOptional()
    @Min(0)
    weight?: number;

    @ApiProperty({ example: '10x5x1', required: false, description: 'Dimensions (LxWxH in cm)' })
    @IsString()
    @IsOptional()
    dimensions?: string;

    @ApiProperty({ example: 'Black', required: false })
    @IsString()
    @IsOptional()
    color?: string;

    @ApiProperty({ type: [String], example: [], required: false, description: 'Product tags' })
    @IsArray()
    @IsString({ each: true })
    @IsOptional()
    tags?: string[];

    @ApiProperty({ type: [String], example: [], required: false, description: 'Related product IDs' })
    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    relatedProducts?: string[];

    @ApiProperty({ type: [String], example: [], required: false, description: 'Related educational content IDs' })
    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    relatedEducationalContent?: string[];
}
