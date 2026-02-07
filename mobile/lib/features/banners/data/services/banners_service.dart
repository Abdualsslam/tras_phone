/// Banners Service
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../repositories/banners_repository.dart';

/// Service class for banners operations
class BannersService {
  final BannersRepository _repository;

  BannersService({required BannersRepository repository})
      : _repository = repository;

  /// جلب البانرات حسب الموضع
  Future<List<BannerEntity>> getBanners({BannerPosition? placement}) async {
    try {
      return await _repository.getBanners(placement: placement);
    } catch (e) {
      throw Exception('Failed to fetch banners: ${e.toString()}');
    }
  }

  /// تسجيل مشاهدة البانر
  Future<void> recordImpression(String bannerId) async {
    try {
      await _repository.recordImpression(bannerId);
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      debugPrint('Failed to record impression: $e');
    }
  }

  /// تسجيل نقر على البانر
  Future<void> recordClick(String bannerId) async {
    try {
      await _repository.recordClick(bannerId);
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      debugPrint('Failed to record click: $e');
    }
  }
}
