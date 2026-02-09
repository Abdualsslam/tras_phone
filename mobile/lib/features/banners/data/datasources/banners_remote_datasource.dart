/// Banners Remote DataSource - Real API implementation with cache
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../models/banner_model.dart';
import '../services/banners_cache_service.dart';

/// Abstract interface for banners data source
abstract class BannersRemoteDataSource {
  Future<List<BannerEntity>> getBanners({
    BannerPosition? placement,
    bool forceRefresh = false,
  });
  Future<void> recordImpression(String bannerId);
  Future<void> recordClick(String bannerId);
}

/// Implementation of BannersRemoteDataSource using API client
class BannersRemoteDataSourceImpl implements BannersRemoteDataSource {
  final ApiClient _apiClient;
  final BannersCacheService _cacheService;

  BannersRemoteDataSourceImpl({
    required ApiClient apiClient,
    required BannersCacheService cacheService,
  })  : _apiClient = apiClient,
        _cacheService = cacheService;

  @override
  Future<List<BannerEntity>> getBanners({
    BannerPosition? placement,
    bool forceRefresh = false,
  }) async {
    final placementStr = placement?.value ?? 'home_top';

    // Try cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = await _cacheService.getBanners(placementStr);
      if (cached != null && await _cacheService.isCacheValid(placementStr)) {
        developer.log('Banners loaded from cache', name: 'BannersDataSource');
        return cached.toEntities();
      }
    }

    developer.log('Fetching banners from API', name: 'BannersDataSource');

    final queryParams = <String, dynamic>{};
    if (placement != null) {
      queryParams['placement'] = placement.value;
    }

    final response = await _apiClient.get(
      ApiEndpoints.banners,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    // Handle nested response structure: response.data.data.data
    final responseData = response.data['data'];
    List<dynamic> list = [];

    if (responseData is Map) {
      final innerData = responseData['data'];
      if (innerData is List) {
        list = innerData;
      }
    } else if (responseData is List) {
      list = responseData;
    } else if (response.data is List) {
      list = response.data as List<dynamic>;
    }

    final rawList = list.map((e) => e as Map<String, dynamic>).toList();

    // Save to cache
    await _cacheService.saveBanners(
      rawBanners: rawList,
      placement: placementStr,
    );

    developer.log(
      'Banners fetched: ${list.length} items',
      name: 'BannersDataSource',
    );

    return rawList
        .map((json) => BannerModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> recordImpression(String bannerId) async {
    try {
      developer.log('Recording impression for banner: $bannerId',
          name: 'BannersDataSource');
      await _apiClient.post(ApiEndpoints.bannersImpression(bannerId));
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      developer.log('Failed to record impression: $e',
          name: 'BannersDataSource');
    }
  }

  @override
  Future<void> recordClick(String bannerId) async {
    try {
      developer.log('Recording click for banner: $bannerId',
          name: 'BannersDataSource');
      await _apiClient.post(ApiEndpoints.bannersClick(bannerId));
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      developer.log('Failed to record click: $e', name: 'BannersDataSource');
    }
  }
}
