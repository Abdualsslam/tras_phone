/// Catalog Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/quality_type_entity.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/device_model.dart';
import '../models/product_filter_query.dart';
import '../models/product_model.dart';
import '../models/product_review_model.dart';
import '../models/quality_type_model.dart';

part 'catalog_remote_datasource_support.dart';
part 'catalog_remote_datasource_taxonomy.dart';
part 'catalog_remote_datasource_products.dart';
part 'catalog_remote_datasource_reviews.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryWithBreadcrumb?> getCategoryById(String id);
  Future<List<CategoryEntity>> getCategoryChildren(String parentId);
  Future<List<CategoryEntity>> getCategoriesTree();
  Future<Map<String, dynamic>> getCategoryProducts(
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

  Future<List<BrandEntity>> getBrands({bool? featured});
  Future<BrandEntity?> getBrandBySlug(String slug);
  Future<BrandEntity?> getBrandById(String id);
  Future<Map<String, dynamic>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  });

  Future<List<DeviceEntity>> getDevices({int? limit, bool? popular});
  Future<List<DeviceEntity>> getDevicesByBrand(String brandId);
  Future<DeviceEntity?> getDeviceBySlug(String slug);
  Future<Map<String, dynamic>> getDeviceProducts(
    String deviceIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  });

  Future<List<QualityTypeEntity>> getQualityTypes();

  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? brandId,
    String? deviceId,
    bool? featured,
    String? search,
    String? sortBy,
    String? sortOrder,
    int page,
    int limit,
  });
  Future<ProductsResponse> getProductsWithFilter(ProductFilterQuery filter);
  Future<ProductEntity?> getProduct(String identifier);
  Future<ProductEntity?> getProductById(String id);
  Future<ProductEntity?> getProductBySku(String sku);
  Future<List<ProductEntity>> getFeaturedProducts({int? limit});
  Future<List<ProductEntity>> getNewArrivals({int? limit});
  Future<List<ProductEntity>> getBestSellers({int? limit});
  Future<ProductsResponse> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  });

  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page,
    int limit,
  });
  Future<List<String>> getSearchSuggestions(String query);
  Future<List<String>> getPopularSearches();
  Future<List<ProductEntity>> advancedSearch({
    required String query,
    List<String>? tags,
    String? tagMode,
    bool? fuzzy,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page,
    int limit,
  });
  Future<Map<String, dynamic>> getAdvancedSearchSuggestions(
    String query, {
    int? limit,
  });
  Future<List<String>> getAutocompleteSuggestions(String query, {int? limit});
  Future<List<String>> getAllTags();
  Future<List<Map<String, dynamic>>> getPopularTags({int? limit});

  Future<List<ProductReviewModel>> getProductReviews(String productId);
  Future<ProductReviewModel?> getMyReview(String productId);
  Future<ProductReviewModel> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  });
  Future<ProductReviewModel> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  });

  Future<List<BannerEntity>> getBanners({String? placement});
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient _apiClient;

  late final _CatalogRemoteSupport _support;
  late final _CatalogTaxonomyRemote _taxonomyRemote;
  late final _CatalogProductsRemote _productsRemote;
  late final _CatalogReviewsRemote _reviewsRemote;

  CatalogRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient {
    _support = _CatalogRemoteSupport(apiClient: _apiClient);
    _taxonomyRemote = _CatalogTaxonomyRemote(_support);
    _productsRemote = _CatalogProductsRemote(_support);
    _reviewsRemote = _CatalogReviewsRemote(_support);
  }

  @override
  Future<List<CategoryEntity>> getCategories() =>
      _taxonomyRemote.getCategories();

  @override
  Future<CategoryWithBreadcrumb?> getCategoryById(String id) =>
      _taxonomyRemote.getCategoryById(id);

  @override
  Future<List<CategoryEntity>> getCategoryChildren(String parentId) =>
      _taxonomyRemote.getCategoryChildren(parentId);

  @override
  Future<List<CategoryEntity>> getCategoriesTree() =>
      _taxonomyRemote.getCategoriesTree();

  @override
  Future<Map<String, dynamic>> getCategoryProducts(
    String categoryIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) => _taxonomyRemote.getCategoryProducts(
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
  Future<List<BrandEntity>> getBrands({bool? featured}) =>
      _taxonomyRemote.getBrands(featured: featured);

  @override
  Future<BrandEntity?> getBrandBySlug(String slug) =>
      _taxonomyRemote.getBrandBySlug(slug);

  @override
  Future<BrandEntity?> getBrandById(String id) =>
      _taxonomyRemote.getBrandById(id);

  @override
  Future<Map<String, dynamic>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) => _taxonomyRemote.getBrandProducts(
    brandId,
    page: page,
    limit: limit,
    minPrice: minPrice,
    maxPrice: maxPrice,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  @override
  Future<List<DeviceEntity>> getDevices({int? limit, bool? popular}) =>
      _taxonomyRemote.getDevices(limit: limit, popular: popular);

  @override
  Future<List<DeviceEntity>> getDevicesByBrand(String brandId) =>
      _taxonomyRemote.getDevicesByBrand(brandId);

  @override
  Future<DeviceEntity?> getDeviceBySlug(String slug) =>
      _taxonomyRemote.getDeviceBySlug(slug);

  @override
  Future<Map<String, dynamic>> getDeviceProducts(
    String deviceIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) => _taxonomyRemote.getDeviceProducts(
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
  Future<List<QualityTypeEntity>> getQualityTypes() =>
      _taxonomyRemote.getQualityTypes();

  @override
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? brandId,
    String? deviceId,
    bool? featured,
    String? search,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) => _productsRemote.getProducts(
    categoryId: categoryId,
    brandId: brandId,
    deviceId: deviceId,
    featured: featured,
    search: search,
    sortBy: sortBy,
    sortOrder: sortOrder,
    page: page,
    limit: limit,
  );

  @override
  Future<ProductsResponse> getProductsWithFilter(ProductFilterQuery filter) =>
      _productsRemote.getProductsWithFilter(filter);

  @override
  Future<ProductEntity?> getProduct(String identifier) =>
      _productsRemote.getProduct(identifier);

  @override
  Future<ProductEntity?> getProductById(String id) =>
      _productsRemote.getProductById(id);

  @override
  Future<ProductEntity?> getProductBySku(String sku) =>
      _productsRemote.getProductBySku(sku);

  @override
  Future<List<ProductEntity>> getFeaturedProducts({int? limit}) =>
      _productsRemote.getFeaturedProducts(limit: limit);

  @override
  Future<List<ProductEntity>> getNewArrivals({int? limit}) =>
      _productsRemote.getNewArrivals(limit: limit);

  @override
  Future<List<ProductEntity>> getBestSellers({int? limit}) =>
      _productsRemote.getBestSellers(limit: limit);

  @override
  Future<ProductsResponse> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) => _productsRemote.getProductsOnOffer(
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
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 1,
    int limit = 20,
  }) => _productsRemote.searchProducts(query, page: page, limit: limit);

  @override
  Future<List<String>> getSearchSuggestions(String query) =>
      _productsRemote.getSearchSuggestions(query);

  @override
  Future<List<String>> getPopularSearches() =>
      _productsRemote.getPopularSearches();

  @override
  Future<List<ProductEntity>> advancedSearch({
    required String query,
    List<String>? tags,
    String? tagMode,
    bool? fuzzy,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) => _productsRemote.advancedSearch(
    query: query,
    tags: tags,
    tagMode: tagMode,
    fuzzy: fuzzy,
    sortBy: sortBy,
    sortOrder: sortOrder,
    brandId: brandId,
    categoryId: categoryId,
    minPrice: minPrice,
    maxPrice: maxPrice,
    page: page,
    limit: limit,
  );

  @override
  Future<Map<String, dynamic>> getAdvancedSearchSuggestions(
    String query, {
    int? limit,
  }) => _productsRemote.getAdvancedSearchSuggestions(query, limit: limit);

  @override
  Future<List<String>> getAutocompleteSuggestions(String query, {int? limit}) =>
      _productsRemote.getAutocompleteSuggestions(query, limit: limit);

  @override
  Future<List<String>> getAllTags() => _productsRemote.getAllTags();

  @override
  Future<List<Map<String, dynamic>>> getPopularTags({int? limit}) =>
      _productsRemote.getPopularTags(limit: limit);

  @override
  Future<List<ProductReviewModel>> getProductReviews(String productId) =>
      _reviewsRemote.getProductReviews(productId);

  @override
  Future<ProductReviewModel?> getMyReview(String productId) =>
      _reviewsRemote.getMyReview(productId);

  @override
  Future<ProductReviewModel> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) => _reviewsRemote.addReview(
    productId: productId,
    rating: rating,
    title: title,
    comment: comment,
    images: images,
  );

  @override
  Future<ProductReviewModel> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) => _reviewsRemote.updateReview(
    productId: productId,
    reviewId: reviewId,
    rating: rating,
    title: title,
    comment: comment,
    images: images,
  );

  @override
  Future<List<BannerEntity>> getBanners({String? placement}) =>
      _taxonomyRemote.getBanners(placement: placement);
}
