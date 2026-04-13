/// Catalog Repository Implementation
library;

import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/repository_guard.dart';
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

part 'catalog_repository_impl_support.dart';
part 'catalog_repository_impl_taxonomy.dart';
part 'catalog_repository_impl_products.dart';
part 'catalog_repository_impl_reviews.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;
  final ProductCacheService? _cacheService;
  final RepositoryGuard _repositoryGuard;

  late final _CatalogRepositorySupport _support;
  late final _CatalogTaxonomyRepositoryDelegate _taxonomyDelegate;
  late final _CatalogProductsRepositoryDelegate _productsDelegate;
  late final _CatalogReviewsRepositoryDelegate _reviewsDelegate;

  CatalogRepositoryImpl({
    required CatalogRemoteDataSource remoteDataSource,
    ProductCacheService? cacheService,
    required RepositoryGuard repositoryGuard,
  }) : _remoteDataSource = remoteDataSource,
       _cacheService = cacheService,
       _repositoryGuard = repositoryGuard {
    _support = _CatalogRepositorySupport(
      cacheService: _cacheService,
      repositoryGuard: _repositoryGuard,
    );
    _taxonomyDelegate = _CatalogTaxonomyRepositoryDelegate(
      remoteDataSource: _remoteDataSource,
      support: _support,
    );
    _productsDelegate = _CatalogProductsRepositoryDelegate(
      remoteDataSource: _remoteDataSource,
      support: _support,
    );
    _reviewsDelegate = _CatalogReviewsRepositoryDelegate(
      remoteDataSource: _remoteDataSource,
      support: _support,
    );
  }

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands({bool? featured}) =>
      _taxonomyDelegate.getBrands(featured: featured);

  @override
  Future<Either<Failure, BrandEntity>> getBrandBySlug(String slug) =>
      _taxonomyDelegate.getBrandBySlug(slug);

  @override
  Future<Either<Failure, BrandEntity>> getBrandById(String id) =>
      _taxonomyDelegate.getBrandById(id);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) => _taxonomyDelegate.getBrandProducts(
    brandId,
    page: page,
    limit: limit,
    minPrice: minPrice,
    maxPrice: maxPrice,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  @override
  Future<Either<Failure, List<CategoryEntity>>> getRootCategories() =>
      _taxonomyDelegate.getRootCategories();

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoryTree() =>
      _taxonomyDelegate.getCategoryTree();

  @override
  Future<Either<Failure, CategoryWithBreadcrumb>> getCategoryById(String id) =>
      _taxonomyDelegate.getCategoryById(id);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren(
    String parentId,
  ) => _taxonomyDelegate.getCategoryChildren(parentId);

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
  }) => _taxonomyDelegate.getCategoryProducts(
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

  @override
  Future<Either<Failure, List<DeviceEntity>>> getPopularDevices({int? limit}) =>
      _taxonomyDelegate.getPopularDevices(limit: limit);

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDevicesByBrand(
    String brandId,
  ) => _taxonomyDelegate.getDevicesByBrand(brandId);

  @override
  Future<Either<Failure, DeviceEntity>> getDeviceBySlug(String slug) =>
      _taxonomyDelegate.getDeviceBySlug(slug);

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
  }) => _taxonomyDelegate.getDeviceProducts(
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

  @override
  Future<Either<Failure, List<QualityTypeEntity>>> getQualityTypes() =>
      _taxonomyDelegate.getQualityTypes();

  @override
  Future<Either<Failure, ProductsResponse>> getProducts(
    ProductFilterQuery filter,
  ) => _productsDelegate.getProducts(filter);

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String identifier) =>
      _productsDelegate.getProduct(identifier);

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int? limit,
  }) => _productsDelegate.getFeaturedProducts(limit: limit);

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals({int? limit}) =>
      _productsDelegate.getNewArrivals(limit: limit);

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers({int? limit}) =>
      _productsDelegate.getBestSellers(limit: limit);

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
  }) => _productsDelegate.getProductsOnOffer(
    page: page,
    limit: limit,
    sortBy: sortBy,
    sortOrder: sortOrder,
    minDiscount: minDiscount,
    maxDiscount: maxDiscount,
    categoryId: categoryId,
    brandId: brandId,
  );

  @override
  Future<Either<Failure, List<ProductReviewModel>>> getProductReviews(
    String productId,
  ) => _reviewsDelegate.getProductReviews(productId);

  @override
  Future<Either<Failure, ProductReviewModel>> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) => _reviewsDelegate.addReview(
    productId: productId,
    rating: rating,
    title: title,
    comment: comment,
    images: images,
  );

  @override
  Future<Either<Failure, ProductReviewModel?>> getMyReview(String productId) =>
      _reviewsDelegate.getMyReview(productId);

  @override
  Future<Either<Failure, ProductReviewModel>> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) => _reviewsDelegate.updateReview(
    productId: productId,
    reviewId: reviewId,
    rating: rating,
    title: title,
    comment: comment,
    images: images,
  );
}
