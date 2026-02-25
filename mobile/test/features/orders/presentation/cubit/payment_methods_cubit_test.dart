import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:tras_phone/features/orders/presentation/cubit/payment_methods_cubit.dart';
import 'package:tras_phone/features/orders/presentation/cubit/payment_methods_state.dart';

class MockOrdersRemoteDataSource extends Mock
    implements OrdersRemoteDataSource {}

void main() {
  late MockOrdersRemoteDataSource mockDataSource;

  // Raw API response maps (as returned by getPaymentMethods)
  final activeMethodJson = {
    '_id': 'pm-1',
    'nameAr': 'الدفع عند الاستلام',
    'nameEn': 'Cash on Delivery',
    'type': 'cash_on_delivery',
    'isActive': true,
    'sortOrder': 1,
  };

  final inactiveMethodJson = {
    '_id': 'pm-2',
    'nameAr': 'بطاقة ائتمان',
    'nameEn': 'Credit Card',
    'type': 'credit_card',
    'isActive': false,
    'sortOrder': 2,
  };

  final anotherActiveMethodJson = {
    '_id': 'pm-3',
    'nameAr': 'تحويل بنكي',
    'nameEn': 'Bank Transfer',
    'type': 'bank_transfer',
    'isActive': true,
    'sortOrder': 3,
  };

  setUp(() {
    mockDataSource = MockOrdersRemoteDataSource();
  });

  PaymentMethodsCubit createCubit() =>
      PaymentMethodsCubit(dataSource: mockDataSource);

  group('initial state', () {
    test('should be PaymentMethodsInitial', () {
      final cubit = createCubit();
      expect(cubit.state, const PaymentMethodsInitial());
      cubit.close();
    });
  });

  group('loadPaymentMethods', () {
    blocTest<PaymentMethodsCubit, PaymentMethodsState>(
      'emits [PaymentMethodsLoading, PaymentMethodsLoaded] on success',
      build: () {
        when(
          () => mockDataSource.getPaymentMethods(),
        ).thenAnswer((_) async => [activeMethodJson]);
        return createCubit();
      },
      act: (cubit) => cubit.loadPaymentMethods(),
      expect: () => [
        const PaymentMethodsLoading(),
        isA<PaymentMethodsLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as PaymentMethodsLoaded;
        expect(loaded.paymentMethods.length, 1);
        expect(loaded.paymentMethods.first.nameEn, 'Cash on Delivery');
      },
    );

    blocTest<PaymentMethodsCubit, PaymentMethodsState>(
      'filters out inactive payment methods',
      build: () {
        when(
          () => mockDataSource.getPaymentMethods(),
        ).thenAnswer((_) async => [activeMethodJson, inactiveMethodJson]);
        return createCubit();
      },
      act: (cubit) => cubit.loadPaymentMethods(),
      expect: () => [
        const PaymentMethodsLoading(),
        isA<PaymentMethodsLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as PaymentMethodsLoaded;
        expect(loaded.paymentMethods.length, 1);
        expect(loaded.paymentMethods.every((m) => m.isActive), isTrue);
      },
    );

    blocTest<PaymentMethodsCubit, PaymentMethodsState>(
      'sorts active methods by sortOrder',
      build: () {
        when(
          () => mockDataSource.getPaymentMethods(),
        ).thenAnswer((_) async => [anotherActiveMethodJson, activeMethodJson]);
        return createCubit();
      },
      act: (cubit) => cubit.loadPaymentMethods(),
      expect: () => [
        const PaymentMethodsLoading(),
        isA<PaymentMethodsLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as PaymentMethodsLoaded;
        expect(loaded.paymentMethods.length, 2);
        expect(loaded.paymentMethods[0].sortOrder, 1);
        expect(loaded.paymentMethods[1].sortOrder, 3);
      },
    );

    blocTest<PaymentMethodsCubit, PaymentMethodsState>(
      'emits [PaymentMethodsLoading, PaymentMethodsError] on failure',
      build: () {
        when(
          () => mockDataSource.getPaymentMethods(),
        ).thenThrow(Exception('Network error'));
        return createCubit();
      },
      act: (cubit) => cubit.loadPaymentMethods(),
      expect: () => [const PaymentMethodsLoading(), isA<PaymentMethodsError>()],
    );

    blocTest<PaymentMethodsCubit, PaymentMethodsState>(
      'emits empty list when all methods are inactive',
      build: () {
        when(
          () => mockDataSource.getPaymentMethods(),
        ).thenAnswer((_) async => [inactiveMethodJson]);
        return createCubit();
      },
      act: (cubit) => cubit.loadPaymentMethods(),
      expect: () => [
        const PaymentMethodsLoading(),
        isA<PaymentMethodsLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as PaymentMethodsLoaded;
        expect(loaded.paymentMethods, isEmpty);
      },
    );
  });
}
