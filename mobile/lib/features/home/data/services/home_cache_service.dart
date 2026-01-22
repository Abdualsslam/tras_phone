/// Home Cache Service - Manages caching for home screen data
library;

import 'dart:convert';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../models/home_cache_data.dart';

class HomeCacheService {
  final HiveCacheService _cacheService;
  static const String _cacheKey = 'home_data';
  
  // TTL duration for home data cache
  // Using 15 minutes as products change more frequently
  static const Duration _defaultTtl = Duration(minutes: 15);

  HomeCacheService(this._cacheService);

  /// Get cached home data
  Future<HomeCacheData?> getHomeData() async {
    try {
      final cachedJson = await _cacheService.get<String>(_cacheKey);
      if (cachedJson == null) return null;

      // Check if expired
      if (_cacheService.isExpired(_cacheKey)) {
        await clearHomeData();
        return null;
      }

      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      return HomeCacheData.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Save home data to cache
  Future<void> saveHomeData({
    required List<CategoryEntity> categories,
    required List<BrandEntity> brands,
    required List<ProductEntity> featuredProducts,
    required List<ProductEntity> newArrivals,
    required List<ProductEntity> bestSellers,
  }) async {
    try {
      final cacheData = HomeCacheData.fromEntities(
        categories: categories,
        brands: brands,
        featuredProducts: featuredProducts,
        newArrivals: newArrivals,
        bestSellers: bestSellers,
      );

      final jsonString = jsonEncode(cacheData.toJson());
      await _cacheService.set<String>(
        _cacheKey,
        jsonString,
        ttl: _defaultTtl,
      );
    } catch (e) {
      // Ignore cache errors - don't break the app
    }
  }

  /// Clear cached home data
  Future<void> clearHomeData() async {
    try {
      await _cacheService.delete(_cacheKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if cache is valid (exists and not expired)
  Future<bool> isCacheValid() async {
    if (!_cacheService.containsKey(_cacheKey)) return false;
    return !_cacheService.isExpired(_cacheKey);
  }
}
