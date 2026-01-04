/// Catalog Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
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
import '../models/product_model.dart';
import '../models/quality_type_model.dart';

/// Abstract interface for catalog data source
abstract class CatalogRemoteDataSource {
  // Categories
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryWithBreadcrumb?> getCategoryById(String id);
  Future<List<CategoryEntity>> getCategoryChildren(String parentId);
  Future<List<CategoryEntity>> getCategoriesTree();

  // Brands
  Future<List<BrandEntity>> getBrands({bool? featured});
  Future<BrandEntity?> getBrandBySlug(String slug);

  // Devices
  Future<List<DeviceEntity>> getDevices({int? limit});
  Future<List<DeviceEntity>> getDevicesByBrand(String brandId);
  Future<DeviceEntity?> getDeviceBySlug(String slug);

  // Quality Types
  Future<List<QualityTypeEntity>> getQualityTypes();

  // Products
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
  Future<ProductEntity?> getProductById(String id);
  Future<ProductEntity?> getProductBySku(String sku);
  Future<List<ProductEntity>> getFeaturedProducts();
  Future<List<ProductEntity>> getNewArrivals();
  Future<List<ProductEntity>> getBestSellers();
  Future<List<ProductEntity>> getProductsOnOffer();

  // Search
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page,
    int limit,
  });
  Future<List<String>> getSearchSuggestions(String query);
  Future<List<String>> getPopularSearches();

  // Banners
  Future<List<BannerEntity>> getBanners({String? placement});
}

/// Implementation of CatalogRemoteDataSource using API client
class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient _apiClient;

  CatalogRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<CategoryEntity>> getCategories() async {
    developer.log('Fetching root categories', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.categories);

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => CategoryModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<CategoryWithBreadcrumb?> getCategoryById(String id) async {
    developer.log('Fetching category: $id', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.categories}/$id');
      final data = response.data['data'] ?? response.data;

      // Response includes category and breadcrumb
      final categoryJson = data['category'] ?? data;
      final category = CategoryModel.fromJson(categoryJson).toEntity();

      final breadcrumbList = data['breadcrumb'] as List<dynamic>? ?? [];
      final breadcrumb = breadcrumbList
          .map((b) => BreadcrumbItemModel.fromJson(b).toEntity())
          .toList();

      return CategoryWithBreadcrumb(category: category, breadcrumb: breadcrumb);
    } catch (e) {
      developer.log('Category not found: $id', name: 'CatalogDataSource');
      return null;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategoryChildren(String parentId) async {
    developer.log(
      'Fetching category children: $parentId',
      name: 'CatalogDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.categories}/$parentId/children',
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => CategoryModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesTree() async {
    developer.log('Fetching categories tree', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.categoriesTree);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => CategoryModel.fromJson(json).toEntity()).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BRANDS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<BrandEntity>> getBrands({bool? featured}) async {
    developer.log('Fetching brands', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.brands,
      queryParameters: {if (featured != null) 'featured': featured},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => BrandModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<BrandEntity?> getBrandBySlug(String slug) async {
    developer.log('Fetching brand: $slug', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.brands}/$slug');
      final data = response.data['data'] ?? response.data;
      return BrandModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Brand not found: $slug', name: 'CatalogDataSource');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<DeviceEntity>> getDevices({int? limit}) async {
    developer.log('Fetching devices', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.devices,
      queryParameters: {if (limit != null) 'limit': limit},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => DeviceModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<DeviceEntity>> getDevicesByBrand(String brandId) async {
    developer.log(
      'Fetching devices for brand: $brandId',
      name: 'CatalogDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.devices}/brand/$brandId',
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => DeviceModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<DeviceEntity?> getDeviceBySlug(String slug) async {
    developer.log('Fetching device: $slug', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.devices}/$slug');
      final data = response.data['data'] ?? response.data;
      return DeviceModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Device not found: $slug', name: 'CatalogDataSource');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUALITY TYPES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<QualityTypeEntity>> getQualityTypes() async {
    developer.log('Fetching quality types', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.qualityTypes);

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map((json) => QualityTypeModel.fromJson(json).toEntity())
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

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
  }) async {
    developer.log('Fetching products (page: $page)', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (brandId != null) 'brandId': brandId,
        if (deviceId != null) 'deviceId': deviceId,
        if (featured != null) 'featured': featured,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    developer.log('Fetching product: $id', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.products}/$id');
      final data = response.data['data'] ?? response.data;
      return ProductModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Product not found: $id', name: 'CatalogDataSource');
      return null;
    }
  }

  @override
  Future<ProductEntity?> getProductBySku(String sku) async {
    developer.log('Fetching product by SKU: $sku', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'sku': sku},
      );
      final data = response.data['data'] ?? response.data;
      if (data is List && data.isNotEmpty) {
        return ProductModel.fromJson(data.first).toEntity();
      }
      return null;
    } catch (e) {
      developer.log(
        'Product not found by SKU: $sku',
        name: 'CatalogDataSource',
      );
      return null;
    }
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    developer.log('Fetching featured products', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.productsFeatured);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getNewArrivals() async {
    developer.log('Fetching new arrivals', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.productsNewArrivals);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getBestSellers() async {
    developer.log('Fetching best sellers', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.productsBestSellers);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsOnOffer() async {
    developer.log('Fetching products on offer', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'hasDiscount': true},
    );
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Searching products: $query', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.productsSearch,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    developer.log(
      'Getting search suggestions: $query',
      name: 'CatalogDataSource',
    );

    if (query.isEmpty) return [];

    final response = await _apiClient.get(
      ApiEndpoints.searchSuggestions,
      queryParameters: {'q': query},
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<String>> getPopularSearches() async {
    developer.log('Getting popular searches', name: 'CatalogDataSource');

    final response = await _apiClient.get(ApiEndpoints.searchPopular);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BANNERS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<BannerEntity>> getBanners({String? placement}) async {
    developer.log('Fetching banners', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.banners,
      queryParameters: {if (placement != null) 'placement': placement},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => BannerModel.fromJson(json).toEntity()).toList();
  }
}
