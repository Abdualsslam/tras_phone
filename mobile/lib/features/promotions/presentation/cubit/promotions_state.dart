import 'package:equatable/equatable.dart';
import '../../data/models/promotion_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/models/coupon_validation_model.dart';

abstract class PromotionsState extends Equatable {
  const PromotionsState();

  @override
  List<Object?> get props => [];
}

class PromotionsInitial extends PromotionsState {}

class PromotionsLoading extends PromotionsState {}

class PromotionsLoaded extends PromotionsState {
  final List<Promotion> promotions;
  final List<Coupon> coupons;

  const PromotionsLoaded({
    this.promotions = const [],
    this.coupons = const [],
  });

  @override
  List<Object?> get props => [promotions, coupons];

  PromotionsLoaded copyWith({
    List<Promotion>? promotions,
    List<Coupon>? coupons,
  }) {
    return PromotionsLoaded(
      promotions: promotions ?? this.promotions,
      coupons: coupons ?? this.coupons,
    );
  }
}

class CouponValidating extends PromotionsState {}

class CouponValidated extends PromotionsState {
  final CouponValidation validation;

  const CouponValidated(this.validation);

  @override
  List<Object?> get props => [validation];
}

class PromotionsError extends PromotionsState {
  final String message;

  const PromotionsError(this.message);

  @override
  List<Object?> get props => [message];
}
