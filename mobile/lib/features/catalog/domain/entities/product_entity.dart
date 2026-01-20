/// Product Entity - Domain layer representation of a product
library;

import 'package:equatable/equatable.dart';
import '../enums/product_enums.dart';

export '../enums/product_enums.dart';

/// Product entity
class ProductEntity extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? shortDescription;
  final String? shortDescriptionAr;

  // Relations
  final String brandId;
  final String categoryId;
  final List<String> additionalCategories;
  final String qualityTypeId;
  final List<String> compatibleDevices;

  // Images
  final String? mainImage;
  final List<String> images;
  final String? video;

  // Pricing
  final double basePrice;
  final double? compareAtPrice;

  // Inventory
  final int stockQuantity;
  final int lowStockThreshold;
  final bool trackInventory;
  final bool allowBackorder;

  // Order
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  final int quantityStep;

  // Status
  final ProductStatus status;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isBestSeller;

  // Specifications
  final Map<String, dynamic>? specifications;
  final double? weight;
  final String? dimensions;
  final String? color;

  // Warranty
  final int? warrantyDays;
  final String? warrantyDescription;

  // Stats
  final int viewsCount;
  final int ordersCount;
  final int salesCount;
  final int reviewsCount;
  final double averageRating;
  final int wishlistCount;

  // Related products
  final List<String>? relatedProducts;

  // Tags
  final List<String> tags;

  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated relations (optional)
  final String? brandName;
  final String? brandNameAr;
  final String? categoryName;
  final String? categoryNameAr;
  final String? qualityTypeName;
  final String? qualityTypeNameAr;

  const ProductEntity({
    required this.id,
    required this.sku,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.shortDescription,
    this.shortDescriptionAr,
    required this.brandId,
    required this.categoryId,
    this.additionalCategories = const [],
    required this.qualityTypeId,
    this.compatibleDevices = const [],
    this.mainImage,
    this.images = const [],
    this.video,
    required this.basePrice,
    this.compareAtPrice,
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.trackInventory = true,
    this.allowBackorder = false,
    this.minOrderQuantity = 1,
    this.maxOrderQuantity,
    this.quantityStep = 1,
    this.status = ProductStatus.active,
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.specifications,
    this.weight,
    this.dimensions,
    this.color,
    this.warrantyDays,
    this.warrantyDescription,
    this.viewsCount = 0,
    this.ordersCount = 0,
    this.salesCount = 0,
    this.reviewsCount = 0,
    this.averageRating = 0,
    this.wishlistCount = 0,
    this.relatedProducts,
    this.tags = const [],
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.brandName,
    this.brandNameAr,
    this.categoryName,
    this.categoryNameAr,
    this.qualityTypeName,
    this.qualityTypeNameAr,
  });

  /// Name by locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// Description by locale
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  /// Short description by locale
  String? getShortDescription(String locale) =>
      locale == 'ar' ? shortDescriptionAr : shortDescription;

  /// Has discount?
  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > basePrice;

  /// Discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((compareAtPrice! - basePrice) / compareAtPrice! * 100).round();
  }

  /// Is low stock?
  bool get isLowStock => stockQuantity <= lowStockThreshold;

  /// Is out of stock?
  bool get isOutOfStock => stockQuantity == 0;

  /// Can order?
  bool get canOrder => isActive && (stockQuantity > 0 || allowBackorder);

  /// Image URL (backward compatibility)
  String? get imageUrl =>
      mainImage ?? (images.isNotEmpty ? images.first : null);

  /// Price (backward compatibility)
  double get price => basePrice;

  /// Original price (backward compatibility)
  double? get originalPrice => compareAtPrice;

  /// Rating (backward compatibility)
  double get rating => averageRating;

  /// Is in stock? (backward compatibility)
  bool get isInStock => stockQuantity > 0;

  @override
  List<Object?> get props => [id, sku];
}
