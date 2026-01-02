/// Catalog Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Abstract interface for catalog data source
abstract class CatalogRemoteDataSource {
  // Categories
  Future<List<CategoryEntity>> getCategories({int? parentId});
  Future<CategoryEntity?> getCategoryById(int id);
  Future<List<CategoryEntity>> getCategoriesTree();

  // Brands
  Future<List<BrandEntity>> getBrands({bool? featured});
  Future<BrandEntity?> getBrandById(int id);

  // Products
  Future<List<ProductEntity>> getProducts({
    int? categoryId,
    int? brandId,
    int? deviceId,
    bool? featured,
    String? search,
    String? sortBy,
    String? sortOrder,
    int page,
    int limit,
  });
  Future<ProductEntity?> getProductById(int id);
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

  // Devices
  Future<List<Map<String, dynamic>>> getDevices({int? brandId});
  Future<Map<String, dynamic>?> getDeviceById(int id);
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
  Future<List<CategoryEntity>> getCategories({int? parentId}) async {
    developer.log('Fetching categories', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.categories,
      queryParameters: {if (parentId != null) 'parent_id': parentId},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => CategoryModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    developer.log('Fetching category: $id', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.categories}/$id');
      final data = response.data['data'] ?? response.data;
      return CategoryModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Category not found: $id', name: 'CatalogDataSource');
      return null;
    }
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
  Future<BrandEntity?> getBrandById(int id) async {
    developer.log('Fetching brand: $id', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.brands}/$id');
      final data = response.data['data'] ?? response.data;
      return BrandModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Brand not found: $id', name: 'CatalogDataSource');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<ProductEntity>> getProducts({
    int? categoryId,
    int? brandId,
    int? deviceId,
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
        if (categoryId != null) 'category_id': categoryId,
        if (brandId != null) 'brand_id': brandId,
        if (deviceId != null) 'device_id': deviceId,
        if (featured != null) 'featured': featured,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ProductModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
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
      queryParameters: {'has_discount': true},
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

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<Map<String, dynamic>>> getDevices({int? brandId}) async {
    developer.log('Fetching devices', name: 'CatalogDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.devices,
      queryParameters: {if (brandId != null) 'brand_id': brandId},
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getDeviceById(int id) async {
    developer.log('Fetching device: $id', name: 'CatalogDataSource');

    try {
      final response = await _apiClient.get('${ApiEndpoints.devices}/$id');
      final data = response.data['data'] ?? response.data;
      return data as Map<String, dynamic>;
    } catch (e) {
      developer.log('Device not found: $id', name: 'CatalogDataSource');
      return null;
    }
  }
}
