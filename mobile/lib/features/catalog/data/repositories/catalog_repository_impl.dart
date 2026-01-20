/// Catalog Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/quality_type_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';
import '../models/product_review_model.dart';

/// Implementation of CatalogRepository using remote data source
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl({required CatalogRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  // ═══════════════════════════════════════════════════════════════════════════
  // BRANDS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands({bool? featured}) async {
    try {
      final brands = await _remoteDataSource.getBrands(featured: featured);
      return Right(brands);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BrandEntity>> getBrandBySlug(String slug) async {
    try {
      final brand = await _remoteDataSource.getBrandBySlug(slug);
      if (brand == null) {
        return const Left(NotFoundFailure(message: 'العلامة التجارية غير موجودة'));
      }
      return Right(brand);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final result = await _remoteDataSource.getBrandProducts(
        brandId,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<CategoryEntity>>> getRootCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoryTree() async {
    try {
      final tree = await _remoteDataSource.getCategoriesTree();
      return Right(tree);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryWithBreadcrumb>> getCategoryById(
    String id,
  ) async {
    try {
      final result = await _remoteDataSource.getCategoryById(id);
      if (result == null) {
        return const Left(NotFoundFailure(message: 'القسم غير موجود'));
      }
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren(
    String parentId,
  ) async {
    try {
      final children = await _remoteDataSource.getCategoryChildren(parentId);
      return Right(children);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<DeviceEntity>>> getPopularDevices({
    int? limit,
  }) async {
    try {
      final devices = await _remoteDataSource.getDevices(limit: limit);
      return Right(devices);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDevicesByBrand(
    String brandId,
  ) async {
    try {
      final devices = await _remoteDataSource.getDevicesByBrand(brandId);
      return Right(devices);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> getDeviceBySlug(String slug) async {
    try {
      final device = await _remoteDataSource.getDeviceBySlug(slug);
      if (device == null) {
        return const Left(NotFoundFailure(message: 'الجهاز غير موجود'));
      }
      return Right(device);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUALITY TYPES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<QualityTypeEntity>>> getQualityTypes() async {
    try {
      final qualityTypes = await _remoteDataSource.getQualityTypes();
      return Right(qualityTypes);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<ProductReviewModel>>> getProductReviews(
    String productId,
  ) async {
    try {
      final reviews = await _remoteDataSource.getProductReviews(productId);
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductReviewModel>> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final review = await _remoteDataSource.addReview(
        productId: productId,
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      );
      return Right(review);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
