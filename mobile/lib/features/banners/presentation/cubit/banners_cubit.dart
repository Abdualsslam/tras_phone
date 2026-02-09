/// Banners Cubit - Manages banners state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/banners_service.dart';
import '../../domain/enums/banner_position.dart';
import 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannersService _service;

  BannersCubit({required BannersService service})
      : _service = service,
        super(const BannersInitial());

  /// جلب البانرات
  /// [refresh] when true, keeps current banners visible while loading (no loading state)
  /// [forceRefresh] when true, bypasses cache and fetches from API
  Future<void> loadBanners({
    BannerPosition? placement,
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    final hadBanners = state is BannersLoaded && (state as BannersLoaded).banners.isNotEmpty;
    if (!refresh || !hadBanners) {
      emit(const BannersLoading());
    }
    try {
      final banners = await _service.getBanners(
        placement: placement,
        forceRefresh: forceRefresh,
      );
      emit(BannersLoaded(banners));
    } catch (e) {
      if (!refresh || !hadBanners) emit(BannersError(e.toString()));
    }
  }

  /// تسجيل مشاهدة
  Future<void> trackImpression(String bannerId) async {
    await _service.recordImpression(bannerId);
  }

  /// تسجيل نقر
  Future<void> trackClick(String bannerId) async {
    await _service.recordClick(bannerId);
  }
}
