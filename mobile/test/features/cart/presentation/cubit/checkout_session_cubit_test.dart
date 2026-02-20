import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:tras_phone/features/cart/domain/entities/checkout_session_entity.dart';
import 'package:tras_phone/features/cart/presentation/cubit/checkout_session_cubit.dart';
import 'package:tras_phone/features/cart/presentation/cubit/checkout_session_state.dart';
import 'package:tras_phone/features/orders/domain/entities/payment_method_entity.dart';
import 'package:tras_phone/features/profile/domain/entities/address_entity.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late MockCartRemoteDataSource mockRemote;

  final now = DateTime(2024, 1, 1);

  final testCart = CheckoutCartEntity(
    id: 'cart-1',
    customerId: 'cust-1',
    status: 'active',
    items: const [],
    itemsCount: 0,
    subtotal: 0,
    discount: 0,
    taxAmount: 0,
    shippingCost: 0,
    total: 0,
    couponDiscount: 0,
  );

  final testAddress = AddressEntity(
    id: 'addr-1',
    customerId: 'cust-1',
    label: 'Home',
    addressLine: '123 Main St',
    latitude: 24.7,
    longitude: 46.7,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final testPaymentMethod = PaymentMethodEntity(
    id: 'pm-1',
    nameAr: 'الدفع عند الاستلام',
    nameEn: 'Cash on Delivery',
    type: 'cash_on_delivery',
    isActive: true,
    sortOrder: 1,
  );

  final testCustomer = const CheckoutCustomerEntity(
    id: 'cust-1',
    name: 'Test Customer',
    walletBalance: 0,
  );

  final testSession = CheckoutSessionEntity(
    cart: testCart,
    addresses: [testAddress],
    paymentMethods: [testPaymentMethod],
    customer: testCustomer,
  );

  final sessionWithValidCoupon = CheckoutSessionEntity(
    cart: testCart,
    addresses: [testAddress],
    paymentMethods: [testPaymentMethod],
    customer: testCustomer,
    coupon: const CheckoutCouponEntity(
      isValid: true,
      code: 'SAVE10',
      discountAmount: 10.0,
      discountType: 'fixed',
    ),
  );

  final sessionWithInvalidCoupon = CheckoutSessionEntity(
    cart: testCart,
    addresses: [testAddress],
    paymentMethods: [testPaymentMethod],
    customer: testCustomer,
    coupon: const CheckoutCouponEntity(
      isValid: false,
      message: 'الكوبون منتهي الصلاحية',
    ),
  );

  setUp(() {
    mockRemote = MockCartRemoteDataSource();
  });

  CheckoutSessionCubit createCubit() =>
      CheckoutSessionCubit(remoteDataSource: mockRemote);

  group('initial state', () {
    test('should be CheckoutSessionInitial', () {
      final cubit = createCubit();
      expect(cubit.state, const CheckoutSessionInitial());
      cubit.close();
    });
  });

  group('loadSession', () {
    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [CheckoutSessionLoading, CheckoutSessionLoaded] on success',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => testSession);
        return createCubit();
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        const CheckoutSessionLoading(),
        CheckoutSessionLoaded(session: testSession),
      ],
    );

    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [CheckoutSessionLoading, CheckoutSessionError] on failure',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenThrow(Exception('Network error'));
        return createCubit();
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        const CheckoutSessionLoading(),
        isA<CheckoutSessionError>(),
      ],
    );

    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'passes couponCode to datasource',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => sessionWithValidCoupon);
        return createCubit();
      },
      act: (cubit) => cubit.loadSession(couponCode: 'SAVE10'),
      expect: () => [
        const CheckoutSessionLoading(),
        CheckoutSessionLoaded(
          session: sessionWithValidCoupon,
          appliedCouponCode: 'SAVE10',
        ),
      ],
      verify: (_) {
        verify(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: 'SAVE10',
            )).called(1);
      },
    );
  });

  group('refresh', () {
    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'reloads session preserving applied coupon',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => sessionWithValidCoupon);
        return createCubit();
      },
      seed: () => CheckoutSessionLoaded(
        session: sessionWithValidCoupon,
        appliedCouponCode: 'SAVE10',
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const CheckoutSessionLoading(),
        isA<CheckoutSessionLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: 'SAVE10',
            )).called(1);
      },
    );
  });

  group('applyCoupon', () {
    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [CheckoutSessionApplyingCoupon, CheckoutSessionLoaded] on valid coupon',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => sessionWithValidCoupon);
        return createCubit();
      },
      seed: () => CheckoutSessionLoaded(session: testSession),
      act: (cubit) => cubit.applyCoupon('SAVE10'),
      expect: () => [
        CheckoutSessionApplyingCoupon(
          currentSession: testSession,
          couponCode: 'SAVE10',
        ),
        CheckoutSessionLoaded(
          session: sessionWithValidCoupon,
          appliedCouponCode: 'SAVE10',
        ),
      ],
    );

    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [Applying, CouponError, Loaded] on invalid coupon',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => sessionWithInvalidCoupon);
        return createCubit();
      },
      seed: () => CheckoutSessionLoaded(session: testSession),
      act: (cubit) => cubit.applyCoupon('EXPIRED'),
      expect: () => [
        isA<CheckoutSessionApplyingCoupon>(),
        isA<CheckoutSessionCouponError>(),
        isA<CheckoutSessionLoaded>(),
      ],
    );

    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [Applying, CouponError, Loaded] on network failure',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenThrow(Exception('Network error'));
        return createCubit();
      },
      seed: () => CheckoutSessionLoaded(session: testSession),
      act: (cubit) => cubit.applyCoupon('SAVE10'),
      expect: () => [
        isA<CheckoutSessionApplyingCoupon>(),
        isA<CheckoutSessionCouponError>(),
        isA<CheckoutSessionLoaded>(),
      ],
    );

    test('does nothing when no session is loaded', () async {
      final cubit = createCubit();
      await cubit.applyCoupon('SAVE10');
      expect(cubit.state, const CheckoutSessionInitial());
      verifyNever(() => mockRemote.getCheckoutSession(
            platform: any(named: 'platform'),
            couponCode: any(named: 'couponCode'),
          ));
      cubit.close();
    });
  });

  group('removeCoupon', () {
    blocTest<CheckoutSessionCubit, CheckoutSessionState>(
      'emits [CheckoutSessionLoading, CheckoutSessionLoaded] with no coupon',
      build: () {
        when(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: any(named: 'couponCode'),
            )).thenAnswer((_) async => testSession);
        return createCubit();
      },
      seed: () => CheckoutSessionLoaded(
        session: sessionWithValidCoupon,
        appliedCouponCode: 'SAVE10',
      ),
      act: (cubit) => cubit.removeCoupon(),
      expect: () => [
        const CheckoutSessionLoading(),
        CheckoutSessionLoaded(session: testSession, appliedCouponCode: null),
      ],
      verify: (_) {
        verify(() => mockRemote.getCheckoutSession(
              platform: any(named: 'platform'),
              couponCode: null,
            )).called(1);
      },
    );
  });

  group('computed properties', () {
    test('isLoaded returns true when state is CheckoutSessionLoaded', () {
      final cubit = createCubit();
      // ignore: invalid_use_of_protected_member
      cubit.emit(CheckoutSessionLoaded(session: testSession));
      expect(cubit.isLoaded, isTrue);
      cubit.close();
    });

    test('canCheckout returns false when cart is empty', () {
      final cubit = createCubit();
      // ignore: invalid_use_of_protected_member
      cubit.emit(CheckoutSessionLoaded(session: testSession));
      // testCart has no items → canCheckout is false
      expect(cubit.canCheckout, isFalse);
      cubit.close();
    });

    test('currentSession returns null when not loaded', () {
      final cubit = createCubit();
      expect(cubit.currentSession, isNull);
      cubit.close();
    });
  });
}
