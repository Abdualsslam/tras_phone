/// Promotions Remote DataSource - Real API implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/coupon_model.dart';
import '../models/coupon_validation_model.dart';
import '../models/promotion_model.dart';

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

    throw ServerException(
      message: data['messageAr']?.toString() ?? 'فشل في جلب العروض',
    );
  }

  @override
  Future<List<Coupon>> getPublicCoupons() async {
    final response = await _apiClient.get('/promotions/coupons/public');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List).map((c) => Coupon.fromJson(c)).toList();
    }

    throw ServerException(
      message: data['messageAr']?.toString() ?? 'فشل في جلب الكوبونات',
    );
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

      if (data['data'] != null) {
        return CouponValidation.fromJson(data['data']);
      }

      throw ValidationException(
        message:
            data['messageAr']?.toString() ??
            data['message']?.toString() ??
            'فشل في التحقق من الكوبون',
      );
    } on ServerException catch (e) {
      if (e.originalError case final DioException dioError?) {
        final errorData = dioError.response?.data;
        if (errorData is Map && errorData['data'] != null) {
          try {
            return CouponValidation.fromJson(errorData['data']);
          } catch (_) {
            // Preserve the original server exception if parsing fails.
          }
        }
        if (errorData is Map) {
          final message =
              errorData['messageAr']?.toString() ??
              errorData['message']?.toString() ??
              e.message;
          throw ValidationException(message: message);
        }
      }
      rethrow;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw UnknownException(message: e.toString(), originalError: e);
    }
  }
}
