import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/promotions_remote_datasource.dart';
import '../../data/models/coupon_validation_model.dart';
import 'promotions_state.dart';

class PromotionsCubit extends Cubit<PromotionsState> {
  final PromotionsRemoteDataSource _dataSource;

  PromotionsCubit(this._dataSource) : super(PromotionsInitial());

  /// جلب العروض النشطة
  Future<void> loadActivePromotions() async {
    emit(PromotionsLoading());
    try {
      final promotions = await _dataSource.getActivePromotions();
      emit(PromotionsLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  /// جلب الكوبونات العامة
  Future<void> loadPublicCoupons() async {
    emit(PromotionsLoading());
    try {
      final coupons = await _dataSource.getPublicCoupons();
      final currentState = state;
      if (currentState is PromotionsLoaded) {
        emit(currentState.copyWith(coupons: coupons));
      } else {
        emit(PromotionsLoaded(coupons: coupons));
      }
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  /// جلب العروض والكوبونات معاً
  Future<void> loadAll() async {
    emit(PromotionsLoading());
    try {
      final promotions = await _dataSource.getActivePromotions();
      final coupons = await _dataSource.getPublicCoupons();
      emit(PromotionsLoaded(promotions: promotions, coupons: coupons));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  /// التحقق من صلاحية كوبون
  Future<CouponValidation?> validateCoupon({
    required String code,
    required double orderTotal,
    List<CartItemForValidation>? items,
  }) async {
    emit(CouponValidating());
    try {
      final validation = await _dataSource.validateCoupon(
        code: code,
        orderTotal: orderTotal,
        items: items,
      );
      emit(CouponValidated(validation));
      return validation;
    } catch (e) {
      emit(PromotionsError(e.toString()));
      return null;
    }
  }
}
