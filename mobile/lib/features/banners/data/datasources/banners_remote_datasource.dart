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

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
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
