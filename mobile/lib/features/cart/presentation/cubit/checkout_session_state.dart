/// Checkout Session States
library;

import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/checkout_session_entity.dart';

sealed class CheckoutSessionState extends Equatable {
  const CheckoutSessionState();

  @override
  List<Object?> get props => [];
}

class CheckoutSessionInitial extends CheckoutSessionState {
  const CheckoutSessionInitial();
}

class CheckoutSessionLoading extends CheckoutSessionState {
  const CheckoutSessionLoading();
}

class CheckoutSessionLoaded extends CheckoutSessionState {
  final CheckoutSessionEntity session;
  final String? appliedCouponCode;

  const CheckoutSessionLoaded({
    required this.session,
    this.appliedCouponCode,
  });

  @override
  List<Object?> get props => [session, appliedCouponCode];

  CheckoutSessionLoaded copyWith({
    CheckoutSessionEntity? session,
    String? appliedCouponCode,
    bool clearCoupon = false,
  }) {
    return CheckoutSessionLoaded(
      session: session ?? this.session,
      appliedCouponCode: clearCoupon
          ? null
          : (appliedCouponCode ?? this.appliedCouponCode),
    );
  }
}

class CheckoutSessionApplyingCoupon extends CheckoutSessionState {
  final CheckoutSessionEntity currentSession;
  final String couponCode;

  const CheckoutSessionApplyingCoupon({
    required this.currentSession,
    required this.couponCode,
  });

  @override
  List<Object?> get props => [currentSession, couponCode];
}

class CheckoutSessionError extends CheckoutSessionState {
  final Failure failure;
  final CheckoutSessionEntity? previousSession;

  const CheckoutSessionError({
    required this.failure,
    this.previousSession,
  });

  @override
  List<Object?> get props => [failure, previousSession];
}

class CheckoutSessionCouponError extends CheckoutSessionState {
  final Failure failure;
  final CheckoutSessionEntity currentSession;

  const CheckoutSessionCouponError({
    required this.failure,
    required this.currentSession,
  });

  @override
  List<Object?> get props => [failure, currentSession];
}
