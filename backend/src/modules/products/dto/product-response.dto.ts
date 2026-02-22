import { ApiProperty } from '@nestjs/swagger';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Product Response DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class ProductResponseDto {
    @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Product ID' })
    _id: string;

    @ApiProperty({ example: 'SKU001', description: 'Product SKU' })
    sku: string;

    @ApiProperty({ example: 'iPhone 15 Pro Max', description: 'Product name' })
    name: string;

    @ApiProperty({ example: 'آيفون 15 برو ماكس', description: 'Product name in Arabic' })
    nameAr: string;

    @ApiProperty({ example: 'iphone-15-pro-max', description: 'URL-friendly slug' })
    slug: string;

    @ApiProperty({ example: 'Latest iPhone with advanced features', required: false })
    description?: string;

    @ApiProperty({ example: 'آخر طراز من آيفون', required: false })
    descriptionAr?: string;

    @ApiProperty({ example: 'Premium smartphone', required: false })
    shortDescription?: string;

    @ApiProperty({ example: 'هاتف ذكي فاخر', required: false })
    shortDescriptionAr?: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Brand ID' })
    brandId: string;

    @ApiProperty({ example: '507f1f77bcf86cd799439012', description: 'Category ID' })
    categoryId: string;

    @ApiProperty({ type: [String], example: [], required: false })
    additionalCategories?: string[];

    @ApiProperty({ example: '507f1f77bcf86cd799439013', description: 'Quality type ID' })
    qualityTypeId: string;

    @ApiProperty({ type: [String], example: [], required: false })
    compatibleDevices?: string[];

    @ApiProperty({ example: 1000.00, description: 'Base price' })
    basePrice: number;

    @ApiProperty({ example: 1200.00, required: false })
    compareAtPrice?: number;

    @ApiProperty({ example: 100, description: 'Stock quantity' })
    stockQuantity: number;

    @ApiProperty({ example: 5, description: 'Low stock threshold' })
    lowStockThreshold: number;

    @ApiProperty({ example: true, description: 'Track inventory' })
    trackInventory: boolean;

    @ApiProperty({ example: false, description: 'Allow backorder' })
    allowBackorder: boolean;

    @ApiProperty({ example: 1, description: 'Minimum order quantity' })
    minOrderQuantity: number;

    @ApiProperty({ example: 10, required: false })
    maxOrderQuantity?: number;

    @ApiProperty({
        example: 'active',
        enum: ['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'],
        description: 'Product status',
    })
    status: string;

    @ApiProperty({ example: true, description: 'Is active' })
    isActive: boolean;

    @ApiProperty({ example: false, description: 'Is featured' })
    isFeatured: boolean;

    @ApiProperty({ example: false, description: 'Is new arrival' })
    isNewArrival: boolean;

    @ApiProperty({ example: false, description: 'Is best seller' })
    isBestSeller: boolean;

    @ApiProperty({ example: 'https://example.com/image.jpg', required: false })
    mainImage?: string;

    @ApiProperty({ type: [String], example: [], required: false })
    images?: string[];

    @ApiProperty({ type: Object, example: {}, required: false })
    specifications?: Record<string, any>;

    @ApiProperty({ example: 200, required: false, description: 'Weight in grams' })
    weight?: number;

    @ApiProperty({ example: '10x5x1', required: false })
    dimensions?: string;

    @ApiProperty({ example: 'Black', required: false })
    color?: string;

    @ApiProperty({ type: [String], example: [], required: false })
    tags?: string[];

    @ApiProperty({ example: 365, required: false, description: 'Warranty days' })
    warrantyDays?: number;

    @ApiProperty({ example: 0, description: 'Views count' })
    viewsCount: number;

    @ApiProperty({ example: 0, description: 'Orders count' })
    ordersCount: number;

    @ApiProperty({ example: 0, description: 'Reviews count' })
    reviewsCount: number;

    @ApiProperty({ example: 0, description: 'Average rating' })
    averageRating: number;

    @ApiProperty({ example: 0, description: 'Favorite count' })
    favoriteCount: number;

    @ApiProperty({ type: [ProductResponseDto], required: false, description: 'Related products' })
    relatedProducts?: ProductResponseDto[];

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Creation timestamp' })
    createdAt: Date;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Last update timestamp' })
    updatedAt: Date;
}
