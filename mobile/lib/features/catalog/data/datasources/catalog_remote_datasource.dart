/// Catalog Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
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
import '../models/product_filter_query.dart';
import '../models/product_review_model.dart';
import '../models/quality_type_model.dart';

/// Abstract interface for catalog data source
abstract class CatalogRemoteDataSource {
  // Categories
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

  // Brands
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

  // Devices
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

  // Search
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page,
    int limit,
  });
  Future<List<String>> getSearchSuggestions(String query);
  Future<List<String>> getPopularSearches();
  
  // Advanced Search
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
  Future<Map<String, dynamic>> getAdvancedSearchSuggestions(String query, {int? limit});
  Future<List<String>> getAutocompleteSuggestions(String query, {int? limit});
  Future<List<String>> getAllTags();
  Future<List<Map<String, dynamic>>> getPopularTags({int? limit});

  // Reviews
  Future<List<ProductReviewModel>> getProductReviews(String productId);
  Future<ProductReviewModel> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  });

  // Banners
  Future<List<BannerEntity>> getBanners({String? placement});
}

/// Implementation of CatalogRemoteDataSource using API client
class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient _apiClient;

  CatalogRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Helper method to log API URL
  void _printApiUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final finalUri = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
        : uri;

    developer.log(
      'API URL: ${finalUri.toString()}',
      name: 'CatalogDataSource',
    );
  }

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

      // Use CategoryWithBreadcrumbModel for JSON deserialization
      final categoryWithBreadcrumbModel =
          CategoryWithBreadcrumbModel.fromJson(data);
      return categoryWithBreadcrumbModel.toEntity();
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
  }) async {
    developer.log(
      'Fetching products for category: $categoryIdentifier (page: $page)',
      name: 'CatalogDataSource',
    );

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (brandId != null) queryParams['brandId'] = brandId;
    if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;

    final endpoint = ApiEndpoints.categoryProducts(categoryIdentifier);
    _printApiUrl(endpoint, queryParams: queryParams);

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    developer.log(
      'Response: ${response.data}',
      name: 'CatalogDataSource',
    );

    final data = response.data['data'] ?? [];
    final meta = response.data['meta'] ?? {};
    final dataList = data is List ? data : [];

    return {
      'products': List<ProductEntity>.from(
        dataList.map((p) => ProductModel.fromJson(p).toEntity()),
      ),
      'pagination': meta,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BRANDS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<BrandEntity>> getBrands({bool? featured}) async {
    developer.log('Fetching brands', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{
      if (featured != null) 'featured': featured,
    };
    
    _printApiUrl(ApiEndpoints.brands, queryParams: queryParams.isNotEmpty ? queryParams : null);

    final response = await _apiClient.get(
      ApiEndpoints.brands,
      queryParameters: queryParams,
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => BrandModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<BrandEntity?> getBrandBySlug(String slug) async {
    developer.log('Fetching brand: $slug', name: 'CatalogDataSource');

    try {
      final endpoint = '${ApiEndpoints.brands}/$slug';
      _printApiUrl(endpoint);
      
      final response = await _apiClient.get(endpoint);
      final data = response.data['data'] ?? response.data;
      return BrandModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Brand not found: $slug', name: 'CatalogDataSource');
      return null;
    }
  }

  @override
  Future<BrandEntity?> getBrandById(String id) async {
    developer.log('Fetching brand by ID: $id', name: 'CatalogDataSource');

    try {
      // First, try to use ID as slug (in case backend supports it)
      final endpoint = '${ApiEndpoints.brands}/$id';
      _printApiUrl(endpoint);
      
      try {
        final response = await _apiClient.get(endpoint);
        final data = response.data['data'] ?? response.data;
        return BrandModel.fromJson(data).toEntity();
      } catch (e) {
        // If that fails, search in all brands list
        developer.log(
          'Brand not found by ID as slug, searching in brands list',
          name: 'CatalogDataSource',
        );
        
        final brands = await getBrands();
        final brand = brands.firstWhere(
          (b) => b.id == id,
          orElse: () => throw Exception('Brand not found'),
        );
        return brand;
      }
    } catch (e) {
      developer.log('Brand not found by ID: $id', name: 'CatalogDataSource');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    developer.log(
      'Fetching products for brand ID: $brandId (page: $page)',
      name: 'CatalogDataSource',
    );

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final endpoint = ApiEndpoints.brandProducts(brandId);
    _printApiUrl(endpoint, queryParams: queryParams);

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    developer.log(
      'Response: ${response.data}',
      name: 'CatalogDataSource',
    );

    final data = response.data['data'] ?? [];
    final meta = response.data['meta'] ?? {};

    return {
      'products': (data as List)
          .map((p) => ProductModel.fromJson(p).toEntity())
          .toList(),
      'pagination': meta,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<DeviceEntity>> getDevices({int? limit, bool? popular}) async {
    developer.log('Fetching devices', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (popular != null) queryParams['popular'] = popular;

    _printApiUrl(
      ApiEndpoints.devices,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await _apiClient.get(
      ApiEndpoints.devices,
      queryParameters: queryParams,
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
      final endpoint = '${ApiEndpoints.devices}/$slug';
      _printApiUrl(endpoint);

      final response = await _apiClient.get(endpoint);
      final data = response.data['data'] ?? response.data;
      return DeviceModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Device not found: $slug', name: 'CatalogDataSource');
      return null;
    }
  }

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
  }) async {
    developer.log(
      'Fetching products for device: $deviceIdentifier (page: $page)',
      name: 'CatalogDataSource',
    );

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (brandId != null) queryParams['brandId'] = brandId;
    if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;

    final endpoint = ApiEndpoints.deviceProducts(deviceIdentifier);
    _printApiUrl(endpoint, queryParams: queryParams);

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    developer.log(
      'Response: ${response.data}',
      name: 'CatalogDataSource',
    );

    final data = response.data['data'] ?? [];
    final meta = response.data['meta'] ?? {};

    return {
      'products': List<ProductEntity>.from(
        (data as List).map((p) => ProductModel.fromJson(p).toEntity()),
      ),
      'pagination': meta,
    };
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
        if (featured != null) 'isFeatured': featured,
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
  Future<ProductsResponse> getProductsWithFilter(ProductFilterQuery filter) async {
    developer.log('Fetching products with filter (page: ${filter.page})', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: filter.toQueryParameters(),
    );

    if (response.data['success'] == true) {
      return ProductsResponse.fromJson(response.data);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to fetch products');
  }

  @override
  Future<ProductEntity?> getProduct(String identifier) async {
    developer.log('Fetching product: $identifier', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.products}/$identifier');
      final data = response.data['data'] ?? response.data;
      return ProductModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Product not found: $identifier', name: 'CatalogDataSource');
      return null;
    }
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
  Future<List<ProductEntity>> getFeaturedProducts({int? limit}) async {
    developer.log('Fetching featured products', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiClient.get(
      ApiEndpoints.productsFeatured,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getNewArrivals({int? limit}) async {
    developer.log('Fetching new arrivals', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiClient.get(
      ApiEndpoints.productsNewArrivals,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getBestSellers({int? limit}) async {
    developer.log('Fetching best sellers', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiClient.get(
      ApiEndpoints.productsBestSellers,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

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
  }) async {
    developer.log('Fetching products on offer (page: $page)', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
    if (maxDiscount != null) queryParams['maxDiscount'] = maxDiscount;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (brandId != null) queryParams['brandId'] = brandId;

    final response = await _apiClient.get(
      ApiEndpoints.productsOnOffer,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return ProductsResponse.fromJson(response.data);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to fetch products on offer');
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
  // ADVANCED SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

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
  }) async {
    developer.log('Advanced search: $query', name: 'CatalogDataSource');

    final queryParams = <String, dynamic>{
      'query': query,
      'page': page,
      'limit': limit,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
      if (tagMode != null) 'tagMode': tagMode,
      if (fuzzy != null) 'fuzzy': fuzzy,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (brandId != null) 'brandId': brandId,
      if (categoryId != null) 'categoryId': categoryId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    };

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/search/advanced',
      queryParameters: queryParams,
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getAdvancedSearchSuggestions(
    String query, {
    int? limit,
  }) async {
    developer.log(
      'Getting advanced search suggestions: $query',
      name: 'CatalogDataSource',
    );

    if (query.isEmpty) return {'suggestions': [], 'tags': [], 'products': []};

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/search/suggestions',
      queryParameters: {
        'query': query,
        if (limit != null) 'limit': limit,
      },
    );

    final data = response.data['data'] ?? response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'suggestions': [], 'tags': [], 'products': []};
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(
    String query, {
    int? limit,
  }) async {
    developer.log(
      'Getting autocomplete suggestions: $query',
      name: 'CatalogDataSource',
    );

    if (query.isEmpty) return [];

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/search/autocomplete',
      queryParameters: {
        'query': query,
        if (limit != null) 'limit': limit,
      },
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<String>> getAllTags() async {
    developer.log('Getting all tags', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/search/tags',
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularTags({int? limit}) async {
    developer.log('Getting popular tags', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/search/popular-tags',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    developer.log('Fetching reviews for product: $productId', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.productReviews(productId),
    );

    final status = response.data['status'] as String?;
    final success = response.data['success'] == true;
    final statusOk = status == 'success' || response.data['statusCode'] == 200;
    if (success || statusOk) {
      final data = response.data['data'] ?? [];
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => ProductReviewModel.fromJson(json)).toList();
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to fetch reviews');
  }

  @override
  Future<ProductReviewModel> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    developer.log('Adding review for product: $productId', name: 'CatalogDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.productReviews(productId),
      data: {
        'rating': rating,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );

    if (response.data['success'] == true) {
      return ProductReviewModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to add review');
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
