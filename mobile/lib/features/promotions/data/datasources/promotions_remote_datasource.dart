/// Promotions Remote DataSource - Real API implementation
library;

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/promotion_model.dart';
import '../models/coupon_model.dart';
import '../models/coupon_validation_model.dart';

/// Abstract interface for promotions data source
abstract class PromotionsRemoteDataSource {
  /// Get active promotions
  Future<List<Promotion>> getActivePromotions();

  /// Get public coupons
  Future<List<Coupon>> getPublicCoupons();

  /// Validate a coupon
  Future<CouponValidation> validateCoupon({
    required String code,
    required double orderTotal,
    List<CartItemForValidation>? items,
  });
}

/// Implementation of PromotionsRemoteDataSource
class PromotionsRemoteDataSourceImpl implements PromotionsRemoteDataSource {
  final ApiClient _apiClient;

  PromotionsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<Promotion>> getActivePromotions() async {
    final response = await _apiClient.get('/promotions/active');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List).map((p) => Promotion.fromJson(p)).toList();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب العروض');
  }

  @override
  Future<List<Coupon>> getPublicCoupons() async {
    final response = await _apiClient.get('/promotions/coupons/public');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List).map((c) => Coupon.fromJson(c)).toList();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب الكوبونات');
  }

  @override
  Future<CouponValidation> validateCoupon({
    required String code,
    required double orderTotal,
    List<CartItemForValidation>? items,
  }) async {
    try {
      final response = await _apiClient.post(
        '/promotions/coupons/validate',
        data: {
          'code': code,
          'orderAmount': orderTotal,
          if (items != null) 'items': items.map((i) => i.toJson()).toList(),
        },
      );
      final data = response.data;

      if (data['success'] == true) {
        return CouponValidation.fromJson(data['data']);
      }
      
      // Handle case where API returns success: false but with validation data
      if (data['data'] != null) {
        return CouponValidation.fromJson(data['data']);
      }
      
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في التحقق من الكوبون');
    } on ServerException catch (e) {
      // Try to extract validation data from error response if available
      if (e.originalError != null && e.originalError is DioException) {
        final dioError = e.originalError as DioException;
        if (dioError.response != null) {
          final errorData = dioError.response!.data;
          if (errorData is Map) {
            // Check if we have validation data in the error response
            if (errorData['data'] != null) {
              try {
                return CouponValidation.fromJson(errorData['data']);
              } catch (_) {
                // If parsing fails, continue to throw original exception
              }
            }
            // Extract error message for better error handling
            final message = errorData['messageAr'] ?? errorData['message'] ?? e.message;
            throw Exception(message);
          }
        }
      }
      rethrow;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }
}
