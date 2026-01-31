/// Checkout Session States
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_session_entity.dart';

/// Base class for checkout session states
sealed class CheckoutSessionState extends Equatable {
  const CheckoutSessionState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class CheckoutSessionInitial extends CheckoutSessionState {
  const CheckoutSessionInitial();
}

/// Loading state while fetching session
class CheckoutSessionLoading extends CheckoutSessionState {
  const CheckoutSessionLoading();
}

/// Session loaded successfully
class CheckoutSessionLoaded extends CheckoutSessionState {
  final CheckoutSessionEntity session;
  final String? appliedCouponCode;

  const CheckoutSessionLoaded({
    required this.session,
    this.appliedCouponCode,
  });

  @override
  List<Object?> get props => [session, appliedCouponCode];

  /// Create a copy with updated coupon
  CheckoutSessionLoaded copyWith({
    CheckoutSessionEntity? session,
    String? appliedCouponCode,
    bool clearCoupon = false,
  }) {
    return CheckoutSessionLoaded(
      session: session ?? this.session,
      appliedCouponCode: clearCoupon ? null : (appliedCouponCode ?? this.appliedCouponCode),
    );
  }
}

/// Applying coupon state
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

/// Error loading session
class CheckoutSessionError extends CheckoutSessionState {
  final String message;
  final CheckoutSessionEntity? previousSession;

  const CheckoutSessionError({
    required this.message,
    this.previousSession,
  });

  @override
  List<Object?> get props => [message, previousSession];
}

/// Coupon validation error
class CheckoutSessionCouponError extends CheckoutSessionState {
  final String message;
  final CheckoutSessionEntity currentSession;

  const CheckoutSessionCouponError({
    required this.message,
    required this.currentSession,
  });

  @override
  List<Object?> get props => [message, currentSession];
}
