/// Returns Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/return_model.dart';

/// Abstract interface for returns data source
abstract class ReturnsRemoteDataSource {
  /// Get all returns with optional filtering
  Future<List<ReturnModel>> getReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get return by ID
  Future<ReturnModel> getReturnById(int id);

  /// Create new return request
  Future<ReturnModel> createReturn(CreateReturnRequest request);

  /// Cancel return request
  Future<bool> cancelReturn(int id);

  /// Get return reasons
  Future<List<ReturnReasonModel>> getReturnReasons();

  /// Upload return images
  Future<List<String>> uploadReturnImages(List<String> imagePaths);

  /// Get return policy
  Future<Map<String, dynamic>> getReturnPolicy();

  /// Check if order is eligible for return
  Future<Map<String, dynamic>> checkReturnEligibility(int orderId);
}

/// Implementation of ReturnsRemoteDataSource using API client
class ReturnsRemoteDataSourceImpl implements ReturnsRemoteDataSource {
  final ApiClient _apiClient;

  ReturnsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ReturnModel>> getReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching returns (page: $page)', name: 'ReturnsDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.returns,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ReturnModel.fromJson(json)).toList();
  }

  @override
  Future<ReturnModel> getReturnById(int id) async {
    developer.log('Fetching return: $id', name: 'ReturnsDataSource');

    final response = await _apiClient.get('${ApiEndpoints.returns}/$id');
    final data = response.data['data'] ?? response.data;

    return ReturnModel.fromJson(data);
  }

  @override
  Future<ReturnModel> createReturn(CreateReturnRequest request) async {
    developer.log('Creating return request', name: 'ReturnsDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.returns,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return ReturnModel.fromJson(data);
  }

  @override
  Future<bool> cancelReturn(int id) async {
    developer.log('Cancelling return: $id', name: 'ReturnsDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.returns}/$id/cancel',
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<ReturnReasonModel>> getReturnReasons() async {
    developer.log('Fetching return reasons', name: 'ReturnsDataSource');

    final response = await _apiClient.get(ApiEndpoints.returnReasons);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ReturnReasonModel.fromJson(json)).toList();
  }

  @override
  Future<List<String>> uploadReturnImages(List<String> imagePaths) async {
    developer.log('Uploading return images', name: 'ReturnsDataSource');

    final uploadedUrls = <String>[];
    for (final path in imagePaths) {
      final response = await _apiClient.uploadFile(
        '${ApiEndpoints.returns}/upload-image',
        filePath: path,
        fieldName: 'image',
      );

      final url = response.data['data']?['url'] ?? response.data['url'];
      if (url != null) uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  @override
  Future<Map<String, dynamic>> getReturnPolicy() async {
    developer.log('Fetching return policy', name: 'ReturnsDataSource');

    final response = await _apiClient.get('${ApiEndpoints.returns}/policy');
    return response.data['data'] ?? response.data;
  }

  @override
  Future<Map<String, dynamic>> checkReturnEligibility(int orderId) async {
    developer.log(
      'Checking return eligibility: $orderId',
      name: 'ReturnsDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.returns}/eligibility/$orderId',
    );

    return response.data['data'] ?? response.data;
  }
}
