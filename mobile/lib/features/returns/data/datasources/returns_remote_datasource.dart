/// Returns Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/return_model.dart';
import '../../domain/enums/return_enums.dart';

/// Abstract interface for returns data source
abstract class ReturnsRemoteDataSource {
  /// Get my returns with optional filtering
  Future<List<ReturnModel>> getMyReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get return by ID
  Future<ReturnModel> getReturnById(String id);

  /// Create new return request
  Future<ReturnModel> createReturn(CreateReturnRequest request);

  /// Cancel return request
  Future<bool> cancelReturn(String id);

  /// Get return reasons (public endpoint)
  Future<List<ReturnReasonModel>> getReturnReasons();

  /// Upload return images
  Future<List<String>> uploadReturnImages(List<String> imagePaths);

  /// Get return policy
  Future<Map<String, dynamic>> getReturnPolicy();
}

/// Implementation of ReturnsRemoteDataSource using API client
class ReturnsRemoteDataSourceImpl implements ReturnsRemoteDataSource {
  final ApiClient _apiClient;

  ReturnsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ReturnModel>> getMyReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching my returns (page: $page)', name: 'ReturnsDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.returns}/my',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.toApiString(),
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ReturnModel.fromJson(json)).toList();
  }

  @override
  Future<ReturnModel> getReturnById(String id) async {
    developer.log('Fetching return: $id', name: 'ReturnsDataSource');

    final response = await _apiClient.get('${ApiEndpoints.returns}/$id');
    final data = response.data['data'] ?? response.data;

    // Handle response structure: { returnRequest: {...}, items: [...] }
    if (data is Map<String, dynamic>) {
      final returnRequestData = data['returnRequest'] ?? data;
      final itemsData = data['items'] as List<dynamic>?;
      
      // Parse return request
      final returnModel = ReturnModel.fromJson(returnRequestData);
      
      // If items are provided separately, merge them
      if (itemsData != null && itemsData.isNotEmpty) {
        final items = itemsData
            .map((json) => ReturnItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
        // Return a new model with items merged
        return ReturnModel(
          id: returnModel.id,
          returnNumber: returnModel.returnNumber,
          orderIds: returnModel.orderIds,
          customerId: returnModel.customerId,
          status: returnModel.status,
          returnType: returnModel.returnType,
          reasonId: returnModel.reasonId,
          reason: returnModel.reason,
          customerNotes: returnModel.customerNotes,
          customerImages: returnModel.customerImages,
          totalItemsValue: returnModel.totalItemsValue,
          restockingFee: returnModel.restockingFee,
          shippingDeduction: returnModel.shippingDeduction,
          refundAmount: returnModel.refundAmount,
          scheduledPickupDate: returnModel.scheduledPickupDate,
          pickupTrackingNumber: returnModel.pickupTrackingNumber,
          exchangeOrderId: returnModel.exchangeOrderId,
          approvedAt: returnModel.approvedAt,
          rejectedAt: returnModel.rejectedAt,
          rejectionReason: returnModel.rejectionReason,
          completedAt: returnModel.completedAt,
          items: items,
          createdAt: returnModel.createdAt,
          updatedAt: returnModel.updatedAt,
        );
      }
      
      return returnModel;
    }

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
  Future<bool> cancelReturn(String id) async {
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
}
