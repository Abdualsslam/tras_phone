/// Catalog Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/quality_type_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';
import '../models/product_filter_query.dart';
import '../models/product_model.dart';
import '../models/product_review_model.dart';
import '../services/product_cache_service.dart';

/// Implementation of CatalogRepository using remote data source
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;
  final ProductCacheService? _cacheService;

  CatalogRepositoryImpl({
    required CatalogRemoteDataSource remoteDataSource,
    ProductCacheService? cacheService,
  }) : _remoteDataSource = remoteDataSource,
       _cacheService = cacheService;

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
        return const Left(
          NotFoundFailure(message: 'العلامة التجارية غير موجودة'),
        );
      }
      return Right(brand);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BrandEntity>> getBrandById(String id) async {
    try {
      final brand = await _remoteDataSource.getBrandById(id);
      if (brand == null) {
        return const Left(
          NotFoundFailure(message: 'العلامة التجارية غير موجودة'),
        );
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
      // Try to get from cache first
      if (_cacheService != null) {
        final cachedData = await _cacheService.getProductsList(
          brandId: brandId,
          page: page,
        );
        if (cachedData != null &&
            await _cacheService.isProductsListCacheValid(
              brandId: brandId,
              page: page,
            )) {
          // Load fresh data in background
          _loadBrandProductsInBackground(
            brandId,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
          );
          return Right({
            'products': cachedData.products,
            'pagination': cachedData.pagination,
          });
        }
      }

      // If no cache or expired, load from API
      final result = await _remoteDataSource.getBrandProducts(
        brandId,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // Save to cache
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          brandId: brandId,
          page: page,
        );
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Load brand products in background and update cache
  Future<void> _loadBrandProductsInBackground(
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
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          brandId: brandId,
          page: page,
        );
      }
    } catch (e) {
      // Ignore background update errors
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

  @override
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
  }) async {
    try {
      // Try to get from cache first
      if (_cacheService != null) {
        final cachedData = await _cacheService.getProductsList(
          categoryId: categoryIdentifier,
          page: page,
        );
        if (cachedData != null &&
            await _cacheService.isProductsListCacheValid(
              categoryId: categoryIdentifier,
              page: page,
            )) {
          // Load fresh data in background
          _loadCategoryProductsInBackground(
            categoryIdentifier,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
            brandId: brandId,
            qualityTypeId: qualityTypeId,
          );
          return Right({
            'products': cachedData.products,
            'pagination': cachedData.pagination,
          });
        }
      }

      // If no cache or expired, load from API
      final result = await _remoteDataSource.getCategoryProducts(
        categoryIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );

      // Save to cache
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          categoryId: categoryIdentifier,
          page: page,
        );
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Load category products in background and update cache
  Future<void> _loadCategoryProductsInBackground(
    String categoryIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    try {
      final result = await _remoteDataSource.getCategoryProducts(
        categoryIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          categoryId: categoryIdentifier,
          page: page,
        );
      }
    } catch (e) {
      // Ignore background update errors
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
      final devices = await _remoteDataSource.getDevices(
        limit: limit,
        popular: true,
      );
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceProducts(
    String deviceIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    try {
      // Try to get from cache first
      if (_cacheService != null) {
        final cachedData = await _cacheService.getProductsList(
          deviceId: deviceIdentifier,
          page: page,
        );
        if (cachedData != null &&
            await _cacheService.isProductsListCacheValid(
              deviceId: deviceIdentifier,
              page: page,
            )) {
          // Load fresh data in background
          _loadDeviceProductsInBackground(
            deviceIdentifier,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
            brandId: brandId,
            qualityTypeId: qualityTypeId,
          );
          return Right({
            'products': cachedData.products,
            'pagination': cachedData.pagination,
          });
        }
      }

      // If no cache or expired, load from API
      final result = await _remoteDataSource.getDeviceProducts(
        deviceIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );

      // Save to cache
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          deviceId: deviceIdentifier,
          page: page,
        );
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Load device products in background and update cache
  Future<void> _loadDeviceProductsInBackground(
    String deviceIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    try {
      final result = await _remoteDataSource.getDeviceProducts(
        deviceIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      if (_cacheService != null) {
        final products = result['products'] as List<ProductEntity>;
        await _cacheService.saveProductsList(
          products: products,
          pagination: result['pagination'] as Map<String, dynamic>?,
          deviceId: deviceIdentifier,
          page: page,
        );
      }
    } catch (e) {
      // Ignore background update errors
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
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, ProductsResponse>> getProducts(
    ProductFilterQuery filter,
  ) async {
    try {
      // Try to get from cache first
      if (_cacheService != null) {
        final cachedData = await _cacheService.getProductsList(
          page: filter.page,
          filter: filter,
        );
        if (cachedData != null &&
            await _cacheService.isProductsListCacheValid(
              page: filter.page,
              filter: filter,
            )) {
          // Load fresh data in background
          _loadProductsInBackground(filter);
          // Convert to ProductsResponse
          final products = cachedData.products;
          final pagination = cachedData.pagination;
          // Convert entities to models
          final productModels = products
              .map((e) {
                try {
                  return ProductModel.fromJson(e as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<ProductModel>()
              .toList();
          return Right(
            ProductsResponse(
              products: productModels,
              total: pagination?['total'] ?? products.length,
              page: pagination?['page'] ?? filter.page,
              pages: pagination?['pages'] ?? 1,
            ),
          );
        }
      }

      // If no cache or expired, load from API
      final response = await _remoteDataSource.getProductsWithFilter(filter);

      // Save to cache
      if (_cacheService != null) {
        await _cacheService.saveProductsList(
          products: response.toEntities(),
          pagination: {
            'total': response.total,
            'page': response.page,
            'pages': response.pages,
          },
          page: filter.page,
          filter: filter,
        );
      }

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Load products in background and update cache
  Future<void> _loadProductsInBackground(ProductFilterQuery filter) async {
    try {
      final response = await _remoteDataSource.getProductsWithFilter(filter);
      if (_cacheService != null) {
        await _cacheService.saveProductsList(
          products: response.toEntities(),
          pagination: {
            'total': response.total,
            'page': response.page,
            'pages': response.pages,
          },
          page: filter.page,
          filter: filter,
        );
      }
    } catch (e) {
      // Ignore background update errors
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String identifier) async {
    try {
      // Try to get from cache first
      if (_cacheService != null) {
        final cachedProduct = await _cacheService.getProduct(identifier);
        if (cachedProduct != null &&
            await _cacheService.isProductCacheValid(identifier)) {
          // Load fresh data in background
          _loadProductInBackground(identifier);
          return Right(cachedProduct);
        }
      }

      // If no cache or expired, load from API
      final product = await _remoteDataSource.getProduct(identifier);
      if (product == null) {
        return const Left(NotFoundFailure(message: 'المنتج غير موجود'));
      }

      // Save to cache
      if (_cacheService != null) {
        await _cacheService.saveProduct(identifier, product);
      }

      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Load product in background and update cache
  Future<void> _loadProductInBackground(String identifier) async {
    try {
      final product = await _remoteDataSource.getProduct(identifier);
      if (product != null && _cacheService != null) {
        await _cacheService.saveProduct(identifier, product);
      }
    } catch (e) {
      // Ignore background update errors
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int? limit,
  }) async {
    try {
      final products = await _remoteDataSource.getFeaturedProducts(
        limit: limit,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals({
    int? limit,
  }) async {
    try {
      final products = await _remoteDataSource.getNewArrivals(limit: limit);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers({
    int? limit,
  }) async {
    try {
      final products = await _remoteDataSource.getBestSellers(limit: limit);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductsResponse>> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) async {
    try {
      final response = await _remoteDataSource.getProductsOnOffer(
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
        minDiscount: minDiscount,
        maxDiscount: maxDiscount,
        categoryId: categoryId,
        brandId: brandId,
      );
      return Right(response);
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
      final msg = e is AppException ? e.message : e.toString();
      final isDuplicate = msg.contains('E11000') ||
          msg.contains('duplicate key') ||
          msg.contains('dup key') ||
          msg.contains('productId_1_customerId_1');
      return Left(ServerFailure(
        message: isDuplicate ? 'لقد قمت بتقييم هذا المنتج مسبقاً' : msg,
      ));
    }
  }
}
