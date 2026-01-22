/// Hive Cache Service - General purpose caching service using Hive
library;

import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';

class HiveCacheService {
  static const String _cacheBoxName = 'app_cache';
  Box? _box;
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox(_cacheBoxName);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Hive cache: $e');
    }
  }

  /// Get value from cache
  Future<T?> get<T>(String key) async {
    if (!_isInitialized || _box == null) {
      await init();
    }

    try {
      final value = _box!.get(key);
      if (value == null) return null;

      // Check if expired
      if (isExpired(key)) {
        await delete(key);
        return null;
      }

      // If T is String, return directly
      if (T == String) {
        return value as T;
      }

      // Otherwise, parse as JSON
      if (value is String) {
        final decoded = jsonDecode(value);
        return decoded as T;
      }

      return value as T;
    } catch (e) {
      return null;
    }
  }

  /// Set value in cache with optional TTL
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    if (!_isInitialized || _box == null) {
      await init();
    }

    try {
      String serializedValue;

      // If T is String, store directly
      if (T == String && value is String) {
        serializedValue = value;
      } else {
        // Serialize to JSON
        serializedValue = jsonEncode(value);
      }

      await _box!.put(key, serializedValue);

      // Store expiration time if TTL is provided
      if (ttl != null) {
        final expirationTime = DateTime.now().add(ttl);
        await _box!.put('${key}_expires', expirationTime.toIso8601String());
      }
    } catch (e) {
      throw Exception('Failed to set cache value: $e');
    }
  }

  /// Delete value from cache
  Future<void> delete(String key) async {
    if (!_isInitialized || _box == null) {
      await init();
    }

    try {
      await _box!.delete(key);
      await _box!.delete('${key}_expires');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    if (!_isInitialized || _box == null) {
      await init();
    }

    try {
      await _box!.clear();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Check if a key is expired
  bool isExpired(String key) {
    if (!_isInitialized || _box == null) return true;

    try {
      final expirationStr = _box!.get('${key}_expires');
      if (expirationStr == null) return false; // No expiration set

      final expirationTime = DateTime.parse(expirationStr as String);
      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true; // Consider expired if error
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    if (!_isInitialized || _box == null) return false;
    return _box!.containsKey(key);
  }

  /// Get all keys
  List<String> getAllKeys() {
    if (!_isInitialized || _box == null) return [];
    return _box!.keys
        .where((key) => !key.toString().endsWith('_expires'))
        .map((key) => key.toString())
        .toList();
  }
}
