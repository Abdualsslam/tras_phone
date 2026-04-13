/// Checkout Session Cubit - State management for checkout session
library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../domain/entities/checkout_session_entity.dart';
import 'checkout_session_state.dart';

class CheckoutSessionCubit extends Cubit<CheckoutSessionState> {
  final CartRemoteDataSource _remoteDataSource;
  final AppFailureMapper _failureMapper = const AppFailureMapper();

  CheckoutSessionCubit({required CartRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource,
      super(const CheckoutSessionInitial());

  String? _resolveAppliedCouponCode(CheckoutSessionEntity? session) {
    if (session == null) return null;
    final codeFromCoupon = session.coupon?.code?.trim();
    if (codeFromCoupon != null && codeFromCoupon.isNotEmpty) {
      return codeFromCoupon;
    }
    final codeFromCart = session.cart.couponCode?.trim();
    if (codeFromCart != null && codeFromCart.isNotEmpty) {
      return codeFromCart;
    }
    return null;
  }

  Future<void> loadSession({String? couponCode}) async {
    emit(const CheckoutSessionLoading());

    try {
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
        CheckoutSessionLoaded(
          session: session,
          appliedCouponCode: (couponCode?.trim().isNotEmpty ?? false)
              ? couponCode!.trim()
              : _resolveAppliedCouponCode(session),
        ),
      );

      developer.log(
        'Checkout session loaded: ${session.cart.itemsCount} items, '
        '${session.addresses.length} addresses, '
        '${session.paymentMethods.length} payment methods',
        name: 'CheckoutSessionCubit',
      );
    } catch (error) {
      developer.log(
        'Error loading checkout session: $error',
        name: 'CheckoutSessionCubit',
        error: error,
      );
      emit(CheckoutSessionError(failure: _failureMapper.map(error)));
    }
  }

  Future<void> refresh() async {
    final currentCoupon = state is CheckoutSessionLoaded
        ? (state as CheckoutSessionLoaded).appliedCouponCode
        : null;
    await loadSession(couponCode: currentCoupon);
  }

  Future<Failure?> applyCoupon(String code) async {
    final currentSession = _getCurrentSession();
    if (currentSession == null) {
      return const ServerFailure(message: 'تعذر تحميل بيانات الدفع');
    }
    final previousCouponCode = _resolveAppliedCouponCode(currentSession);

    try {
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

      if (session.coupon != null && session.coupon!.isValid) {
        emit(
          CheckoutSessionLoaded(
            session: session,
            appliedCouponCode:
                _resolveAppliedCouponCode(session) ?? code.toUpperCase(),
          ),
        );
        developer.log(
          'Coupon applied: $code, discount: ${session.coupon!.discountAmount}',
          name: 'CheckoutSessionCubit',
        );
        return null;
      }

      final failure = ValidationFailure(
        message: session.coupon?.message ?? 'الكوبون غير صالح',
      );
      emit(
        CheckoutSessionCouponError(
          failure: failure,
          currentSession: currentSession,
        ),
      );
      emit(
        CheckoutSessionLoaded(
          session: currentSession,
          appliedCouponCode: previousCouponCode,
        ),
      );
      return failure;
    } catch (error) {
      developer.log(
        'Error applying coupon: $error',
        name: 'CheckoutSessionCubit',
        error: error,
      );
      final failure = _failureMapper.map(error);
      emit(
        CheckoutSessionCouponError(
          failure: failure,
          currentSession: currentSession,
        ),
      );
      emit(
        CheckoutSessionLoaded(
          session: currentSession,
          appliedCouponCode: previousCouponCode,
        ),
      );
      return failure;
    }
  }

  Future<Failure?> removeCoupon() async {
    final currentSession = _getCurrentSession();
    if (currentSession == null) {
      return const ServerFailure(message: 'تعذر تحميل بيانات الدفع');
    }
    final previousCouponCode = _resolveAppliedCouponCode(currentSession);

    emit(const CheckoutSessionLoading());

    try {
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
      return null;
    } catch (error) {
      developer.log(
        'Error removing coupon: $error',
        name: 'CheckoutSessionCubit',
        error: error,
      );

      emit(
        CheckoutSessionLoaded(
          session: currentSession,
          appliedCouponCode: previousCouponCode,
        ),
      );
      return _failureMapper.map(error);
    }
  }

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

  bool get isLoaded => state is CheckoutSessionLoaded;

  CheckoutSessionEntity? get currentSession => _getCurrentSession();

  bool get isApplyingCoupon => state is CheckoutSessionApplyingCoupon;

  bool get canCheckout {
    final session = _getCurrentSession();
    return session != null && session.canCheckout;
  }
}
