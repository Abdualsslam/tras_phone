/// Image Cache Configuration - Improves image caching for network images
library;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Stable cache key from URL - strips query params for consistent caching
/// when API adds cache-busting params (e.g. ?v=123)
String imageCacheKey(String url) {
  if (url.isEmpty) return url;
  final idx = url.indexOf('?');
  return idx > 0 ? url.substring(0, idx) : url;
}

/// Custom cache manager for app images - longer retention (30 days), more objects (500)
final imageCacheManager = CacheManager(
  Config(
    'tras_phone_images',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 500,
  ),
);
