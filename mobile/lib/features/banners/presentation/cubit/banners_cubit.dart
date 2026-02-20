/// Banners Cubit - Manages banners state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/banners_repository.dart';
import '../../domain/enums/banner_position.dart';
import 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannersRepository _repository;

  BannersCubit({required BannersRepository repository})
      : _repository = repository,
        super(const BannersInitial());

  /// جلب البانرات
  /// [refresh] when true, keeps current banners visible while loading
  /// [forceRefresh] when true, bypasses cache and fetches from API
  Future<void> loadBanners({
    BannerPosition? placement,
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    final hadBanners =
        state is BannersLoaded && (state as BannersLoaded).banners.isNotEmpty;

    if (!refresh || !hadBanners) {
      emit(const BannersLoading());
    }

    final result = await _repository.getBanners(
      placement: placement,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) {
        if (!refresh || !hadBanners) emit(BannersError(failure.message));
      },
      (banners) => emit(BannersLoaded(banners)),
    );
  }

  /// تسجيل مشاهدة
  Future<void> trackImpression(String bannerId) =>
      _repository.recordImpression(bannerId);

  /// تسجيل نقر
  Future<void> trackClick(String bannerId) =>
      _repository.recordClick(bannerId);
}
