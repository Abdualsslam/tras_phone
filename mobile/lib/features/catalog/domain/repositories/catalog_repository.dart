/// Catalog Repository - Abstract interface for catalog operations
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/product_review_model.dart';
import '../entities/brand_entity.dart';
import '../entities/category_entity.dart';
import '../entities/device_entity.dart';
import '../entities/quality_type_entity.dart';

/// Abstract repository interface for catalog operations
abstract class CatalogRepository {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRANDS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all brands, optionally filtered by featured status
  Future<Either<Failure, List<BrandEntity>>> getBrands({bool? featured});

  /// Get a single brand by its slug
  Future<Either<Failure, BrandEntity>> getBrandBySlug(String slug);

  /// Get products for a brand by ID with pagination and filters
  Future<Either<Failure, Map<String, dynamic>>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get root level categories
  Future<Either<Failure, List<CategoryEntity>>> getRootCategories();

  /// Get full category tree with nested children
  Future<Either<Failure, List<CategoryEntity>>> getCategoryTree();

  /// Get a category by ID with its breadcrumb navigation
  Future<Either<Failure, CategoryWithBreadcrumb>> getCategoryById(String id);

  /// Get children of a category
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren(
    String parentId,
  );

  /// Get products for a category by identifier (id or slug) with pagination and filters
  Future<Either<Failure, Map<String, dynamic>>> getCategoryProducts(
    String categoryIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get popular devices with optional limit
  Future<Either<Failure, List<DeviceEntity>>> getPopularDevices({int? limit});

  /// Get devices for a specific brand
  Future<Either<Failure, List<DeviceEntity>>> getDevicesByBrand(String brandId);

  /// Get a single device by its slug
  Future<Either<Failure, DeviceEntity>> getDeviceBySlug(String slug);

  // ═══════════════════════════════════════════════════════════════════════════
  // QUALITY TYPES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all quality types
  Future<Either<Failure, List<QualityTypeEntity>>> getQualityTypes();

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get reviews for a product
  Future<Either<Failure, List<ProductReviewModel>>> getProductReviews(
    String productId,
  );

  /// Add a review for a product
  Future<Either<Failure, ProductReviewModel>> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  });
}
