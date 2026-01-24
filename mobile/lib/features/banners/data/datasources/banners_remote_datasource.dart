/// Banners Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../models/banner_model.dart';

/// Abstract interface for banners data source
abstract class BannersRemoteDataSource {
  Future<List<BannerEntity>> getBanners({BannerPosition? placement});
  Future<void> recordImpression(String bannerId);
  Future<void> recordClick(String bannerId);
}

/// Implementation of BannersRemoteDataSource using API client
class BannersRemoteDataSourceImpl implements BannersRemoteDataSource {
  final ApiClient _apiClient;

  BannersRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<BannerEntity>> getBanners({BannerPosition? placement}) async {
    developer.log('Fetching banners', name: 'BannersDataSource');

    final queryParams = <String, dynamic>{};
    if (placement != null) {
      queryParams['placement'] = placement.value;
    }

    final response = await _apiClient.get(
      ApiEndpoints.banners,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    // Handle nested response structure: response.data.data.data
    // The API returns: { data: { success: true, data: [...] } }
    final responseData = response.data['data'];
    List<dynamic> list = [];
    
    if (responseData is Map) {
      // If responseData is a Map, check if it has a 'data' key with a List
      final innerData = responseData['data'];
      if (innerData is List) {
        list = innerData;
      }
    } else if (responseData is List) {
      list = responseData;
    } else if (response.data is List) {
      list = response.data as List<dynamic>;
    }

    developer.log(
      'Banners fetched: ${list.length} items',
      name: 'BannersDataSource',
    );

    return list
        .map((json) => BannerModel.fromJson(json as Map<String, dynamic>).toEntity())
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
