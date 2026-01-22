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
  Future<void> loadBanners({BannerPosition? placement}) async {
    emit(const BannersLoading());
    try {
      final banners = await _service.getBanners(placement: placement);
      emit(BannersLoaded(banners));
    } catch (e) {
      emit(BannersError(e.toString()));
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
