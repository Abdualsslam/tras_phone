/// Checkout Session Cubit - State management for checkout session
library;

import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../domain/entities/checkout_session_entity.dart';
import 'checkout_session_state.dart';

class CheckoutSessionCubit extends Cubit<CheckoutSessionState> {
  final CartRemoteDataSource _remoteDataSource;

  CheckoutSessionCubit({required CartRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource,
      super(const CheckoutSessionInitial());

  /// Load checkout session from server
  Future<void> loadSession({String? couponCode}) async {
    emit(const CheckoutSessionLoading());

    try {
      // Determine platform
      String? platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      final session = await _remoteDataSource.getCheckoutSession(
        platform: platform,
        couponCode: couponCode,
      );

      emit(
        CheckoutSessionLoaded(session: session, appliedCouponCode: couponCode),
      );

      print(
        '[CheckoutSessionCubit] Checkout session loaded: '
        '${session.cart.itemsCount} items, '
        '${session.addresses.length} addresses, '
        '${session.paymentMethods.length} payment methods',
      );
      developer.log(
        'Checkout session loaded: ${session.cart.itemsCount} items, '
        '${session.addresses.length} addresses, '
        '${session.paymentMethods.length} payment methods',
        name: 'CheckoutSessionCubit',
      );
    } catch (e) {
      developer.log(
        'Error loading checkout session: $e',
        name: 'CheckoutSessionCubit',
        error: e,
      );
      emit(CheckoutSessionError(message: e.toString()));
    }
  }

  /// Reload session (refresh)
  Future<void> refresh() async {
    final currentCoupon = state is CheckoutSessionLoaded
        ? (state as CheckoutSessionLoaded).appliedCouponCode
        : null;
    await loadSession(couponCode: currentCoupon);
  }

  /// Apply coupon code
  Future<void> applyCoupon(String code) async {
    final currentSession = _getCurrentSession();
    if (currentSession == null) return;

    emit(
      CheckoutSessionApplyingCoupon(
        currentSession: currentSession,
        couponCode: code,
      ),
    );

    try {
      // Determine platform
      String? platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      final session = await _remoteDataSource.getCheckoutSession(
        platform: platform,
        couponCode: code,
      );

      // Check if coupon was valid
      if (session.coupon != null && session.coupon!.isValid) {
        emit(CheckoutSessionLoaded(session: session, appliedCouponCode: code));
        developer.log(
          'Coupon applied: $code, discount: ${session.coupon!.discountAmount}',
          name: 'CheckoutSessionCubit',
        );
      } else {
        // Coupon was invalid
        final errorMessage = session.coupon?.message ?? 'الكوبون غير صالح';
        emit(
          CheckoutSessionCouponError(
            message: errorMessage,
            currentSession: currentSession,
          ),
        );

        // After showing error, revert to loaded state without coupon
        emit(
          CheckoutSessionLoaded(
            session: currentSession,
            appliedCouponCode: null,
          ),
        );
      }
    } catch (e) {
      developer.log(
        'Error applying coupon: $e',
        name: 'CheckoutSessionCubit',
        error: e,
      );
      emit(
        CheckoutSessionCouponError(
          message: e.toString(),
          currentSession: currentSession,
        ),
      );

      // Revert to previous state
      emit(
        CheckoutSessionLoaded(session: currentSession, appliedCouponCode: null),
      );
    }
  }

  /// Remove applied coupon
  Future<void> removeCoupon() async {
    final currentSession = _getCurrentSession();
    if (currentSession == null) return;

    emit(const CheckoutSessionLoading());

    try {
      // Reload session without coupon
      String? platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      final session = await _remoteDataSource.getCheckoutSession(
        platform: platform,
        couponCode: null,
      );

      emit(CheckoutSessionLoaded(session: session, appliedCouponCode: null));

      developer.log('Coupon removed', name: 'CheckoutSessionCubit');
    } catch (e) {
      developer.log(
        'Error removing coupon: $e',
        name: 'CheckoutSessionCubit',
        error: e,
      );

      // Revert to previous state without coupon
      emit(
        CheckoutSessionLoaded(session: currentSession, appliedCouponCode: null),
      );
    }
  }

  /// Get current session from state
  CheckoutSessionEntity? _getCurrentSession() {
    if (state is CheckoutSessionLoaded) {
      return (state as CheckoutSessionLoaded).session;
    } else if (state is CheckoutSessionApplyingCoupon) {
      return (state as CheckoutSessionApplyingCoupon).currentSession;
    } else if (state is CheckoutSessionCouponError) {
      return (state as CheckoutSessionCouponError).currentSession;
    } else if (state is CheckoutSessionError) {
      return (state as CheckoutSessionError).previousSession;
    }
    return null;
  }

  /// Check if session is loaded
  bool get isLoaded => state is CheckoutSessionLoaded;

  /// Get current session (if loaded)
  CheckoutSessionEntity? get currentSession => _getCurrentSession();

  /// Check if coupon is being applied
  bool get isApplyingCoupon => state is CheckoutSessionApplyingCoupon;

  /// Check if cart can proceed to checkout
  bool get canCheckout {
    final session = _getCurrentSession();
    return session != null && session.canCheckout;
  }
}
