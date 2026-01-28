/// Product Cache Service - Manages caching for product data
library;

import 'dart:convert';
import '../../../../core/cache/hive_cache_service.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_cache_data.dart';
import '../models/product_filter_query.dart';

class ProductCacheService {
  final HiveCacheService _cacheService;

  // TTL durations
  static const Duration _productTtl = Duration(minutes: 30); // Single product
  static const Duration _productsListTtl = Duration(
    minutes: 15,
  ); // Products list
  static const Duration _filteredProductsTtl = Duration(
    minutes: 10,
  ); // Filtered products

  ProductCacheService(this._cacheService);

  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLE PRODUCT CACHE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get cached product by identifier
  Future<ProductEntity?> getProduct(String identifier) async {
    try {
      final cacheKey = _getProductCacheKey(identifier);
      final cachedJson = await _cacheService.get<String>(cacheKey);
      if (cachedJson == null) return null;

      // Check if expired
      if (_cacheService.isExpired(cacheKey)) {
        await clearProduct(identifier);
        return null;
      }

      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      final cacheData = ProductCacheData.fromJson(jsonMap);
      return cacheData.toProduct();
    } catch (e) {
      return null;
    }
  }

  /// Save product to cache
  Future<void> saveProduct(String identifier, ProductEntity product) async {
    try {
      final cacheKey = _getProductCacheKey(identifier);
      final cacheData = ProductCacheData.fromProduct(product);
      final jsonString = jsonEncode(cacheData.toJson());
      await _cacheService.set<String>(cacheKey, jsonString, ttl: _productTtl);
    } catch (e) {
      // Ignore cache errors - don't break the app
    }
  }

  /// Clear cached product
  Future<void> clearProduct(String identifier) async {
    try {
      final cacheKey = _getProductCacheKey(identifier);
      await _cacheService.delete(cacheKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if product cache is valid
  Future<bool> isProductCacheValid(String identifier) async {
    final cacheKey = _getProductCacheKey(identifier);
    if (!_cacheService.containsKey(cacheKey)) return false;
    return !_cacheService.isExpired(cacheKey);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS LIST CACHE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get cached products list
  Future<({List<ProductEntity> products, Map<String, dynamic>? pagination})?>
  getProductsList({
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    try {
      final cacheKey = _generateListCacheKey(
        categoryId: categoryId,
        brandId: brandId,
        deviceId: deviceId,
        page: page,
        filter: filter,
      );

      final cachedJson = await _cacheService.get<String>(cacheKey);
      if (cachedJson == null) return null;

      // Check if expired
      if (_cacheService.isExpired(cacheKey)) {
        await clearProductsList(
          categoryId: categoryId,
          brandId: brandId,
          deviceId: deviceId,
          page: page,
          filter: filter,
        );
        return null;
      }

      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      final cacheData = ProductCacheData.fromJson(jsonMap);
      return (
        products: cacheData.toProductsList(),
        pagination: cacheData.pagination,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save products list to cache
  Future<void> saveProductsList({
    required List<ProductEntity> products,
    Map<String, dynamic>? pagination,
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    try {
      final cacheKey = _generateListCacheKey(
        categoryId: categoryId,
        brandId: brandId,
        deviceId: deviceId,
        page: page,
        filter: filter,
      );

      final cacheData = ProductCacheData.fromProductsList(
        products: products,
        pagination: pagination,
        filter: filter,
      );

      final jsonString = jsonEncode(cacheData.toJson());

      // Use filtered TTL if filter exists, otherwise use list TTL
      final ttl = filter != null && filter.hasFilters
          ? _filteredProductsTtl
          : _productsListTtl;

      await _cacheService.set<String>(cacheKey, jsonString, ttl: ttl);
    } catch (e) {
      // Ignore cache errors - don't break the app
    }
  }

  /// Clear cached products list
  Future<void> clearProductsList({
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    try {
      final cacheKey = _generateListCacheKey(
        categoryId: categoryId,
        brandId: brandId,
        deviceId: deviceId,
        page: page,
        filter: filter,
      );
      await _cacheService.delete(cacheKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if products list cache is valid
  Future<bool> isProductsListCacheValid({
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    final cacheKey = _generateListCacheKey(
      categoryId: categoryId,
      brandId: brandId,
      deviceId: deviceId,
      page: page,
      filter: filter,
    );
    if (!_cacheService.containsKey(cacheKey)) return false;
    return !_cacheService.isExpired(cacheKey);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL CACHE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Clear all product cache
  Future<void> clearAll() async {
    try {
      final allKeys = _cacheService.getAllKeys();
      for (final key in allKeys) {
        if (key.startsWith('product_') ||
            key.startsWith('products_list_') ||
            key.startsWith('category_products_') ||
            key.startsWith('brand_products_') ||
            key.startsWith('device_products_')) {
          await _cacheService.delete(key);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all cache for a specific category
  Future<void> clearCategoryCache(String categoryId) async {
    try {
      final allKeys = _cacheService.getAllKeys();
      for (final key in allKeys) {
        if (key.contains('category_$categoryId') ||
            key.contains('category_products_$categoryId')) {
          await _cacheService.delete(key);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all cache for a specific brand
  Future<void> clearBrandCache(String brandId) async {
    try {
      final allKeys = _cacheService.getAllKeys();
      for (final key in allKeys) {
        if (key.contains('brand_$brandId') ||
            key.contains('brand_products_$brandId')) {
          await _cacheService.delete(key);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all cache for a specific device
  Future<void> clearDeviceCache(String deviceId) async {
    try {
      final allKeys = _cacheService.getAllKeys();
      for (final key in allKeys) {
        if (key.contains('device_$deviceId') ||
            key.contains('device_products_$deviceId')) {
          await _cacheService.delete(key);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate cache key for single product
  String _getProductCacheKey(String identifier) {
    return 'product_$identifier';
  }

  /// Generate cache key for products list
  String _generateListCacheKey({
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) {
    final buffer = StringBuffer();

    if (categoryId != null) {
      buffer.write('category_products_$categoryId');
    } else if (brandId != null) {
      buffer.write('brand_products_$brandId');
    } else if (deviceId != null) {
      buffer.write('device_products_$deviceId');
    } else {
      buffer.write('products_list');
    }

    if (page != null) {
      buffer.write('_page_$page');
    }

    if (filter != null && filter.hasFilters) {
      final filterHash = _hashFilter(filter);
      buffer.write('_filter_$filterHash');
    }

    return buffer.toString();
  }

  /// Hash filter query to create unique cache key
  int _hashFilter(ProductFilterQuery filter) {
    return filter.toQueryParameters().toString().hashCode;
  }
}
