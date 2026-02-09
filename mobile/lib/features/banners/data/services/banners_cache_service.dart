/// Banners Cache Service - Manages caching for banners data
library;

import 'dart:convert';
import '../../../../core/cache/hive_cache_service.dart';
import '../models/banners_cache_data.dart';

class BannersCacheService {
  final HiveCacheService _cacheService;
  static const String _cacheKeyPrefix = 'banners_';

  // TTL: 15 minutes (same as home data)
  static const Duration _defaultTtl = Duration(minutes: 15);

  BannersCacheService(this._cacheService);

  String _cacheKey(String placement) => '$_cacheKeyPrefix$placement';

  /// Get cached banners for placement
  Future<BannersCacheData?> getBanners(String placement) async {
    try {
      final key = _cacheKey(placement);
      final cachedJson = await _cacheService.get<String>(key);
      if (cachedJson == null) return null;

      if (_cacheService.isExpired(key)) {
        await clearBanners(placement);
        return null;
      }

      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      return BannersCacheData.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Save banners to cache
  Future<void> saveBanners({
    required List<Map<String, dynamic>> rawBanners,
    required String placement,
  }) async {
    try {
      final cacheData = BannersCacheData(
        banners: rawBanners,
        placement: placement,
        cachedAt: DateTime.now().toIso8601String(),
      );
      final jsonString = jsonEncode(cacheData.toJson());
      await _cacheService.set<String>(
        _cacheKey(placement),
        jsonString,
        ttl: _defaultTtl,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Clear cached banners for placement
  Future<void> clearBanners(String placement) async {
    try {
      await _cacheService.delete(_cacheKey(placement));
    } catch (e) {
      // Ignore
    }
  }

  /// Check if cache is valid
  Future<bool> isCacheValid(String placement) async {
    final key = _cacheKey(placement);
    if (!_cacheService.containsKey(key)) return false;
    return !_cacheService.isExpired(key);
  }
}
