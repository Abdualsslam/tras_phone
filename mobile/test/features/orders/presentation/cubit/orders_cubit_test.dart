import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:tras_phone/features/orders/domain/entities/order_entity.dart';
import 'package:tras_phone/features/orders/domain/entities/order_stats_entity.dart';
import 'package:tras_phone/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:tras_phone/features/orders/presentation/cubit/orders_state.dart';

class MockOrdersRemoteDataSource extends Mock
    implements OrdersRemoteDataSource {}

void main() {
  late MockOrdersRemoteDataSource mockDataSource;

  final now = DateTime(2024, 1, 1);

  final testOrder = OrderEntity(
    id: 'order-1',
    orderNumber: 'ORD-001',
    customerId: 'cust-1',
    status: OrderStatus.pending,
    subtotal: 100.0,
    total: 100.0,
    createdAt: now,
    updatedAt: now,
  );

  final testStats = const OrderStatsEntity(
    total: 10,
    byStatus: {'pending': 3, 'completed': 7},
    byPaymentStatus: {'paid': 8, 'unpaid': 2},
    totalRevenue: 5000.0,
    totalPaid: 4000.0,
    totalUnpaid: 1000.0,
    todayOrders: 2,
    todayRevenue: 500.0,
    thisMonthOrders: 10,
    thisMonthRevenue: 5000.0,
  );

  final testOrdersResponse = OrdersResponseData(
    orders: [testOrder],
    total: 1,
  );

  setUp(() {
    mockDataSource = MockOrdersRemoteDataSource();
  });

  OrdersCubit createCubit() =>
      OrdersCubit(dataSource: mockDataSource);

  group('initial state', () {
    test('should be OrdersInitial', () {
      final cubit = createCubit();
      expect(cubit.state, const OrdersInitial());
      cubit.close();
    });
  });

  group('loadOrders', () {
    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] on success',
      build: () {
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        const OrdersLoading(),
        OrdersLoaded(
          [testOrder],
          total: 1,
          stats: testStats,
        ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersLoading, OrdersError] on failure',
      build: () {
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('Network error'));
        when(() => mockDataSource.getMyOrderStats())
            .thenThrow(Exception('Network error'));
        return createCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        const OrdersLoading(),
        isA<OrdersError>(),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'passes status filter to datasource',
      build: () {
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.loadOrders(status: OrderStatus.pending),
      expect: () => [
        const OrdersLoading(),
        OrdersLoaded(
          [testOrder],
          total: 1,
          filterStatus: OrderStatus.pending,
          stats: testStats,
        ),
      ],
      verify: (_) {
        verify(() => mockDataSource.getMyOrders(
              status: OrderStatus.pending,
              paymentStatus: null,
              orderNumber: null,
              sortBy: null,
              sortOrder: null,
              page: 1,
              limit: 20,
            )).called(1);
      },
    );
  });

  group('cancelOrder', () {
    blocTest<OrdersCubit, OrdersState>(
      'calls cancelOrder then reloads orders on success',
      build: () {
        when(() => mockDataSource.cancelOrder(
              any(),
              reason: any(named: 'reason'),
            )).thenAnswer((_) async => testOrder);
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) =>
          cubit.cancelOrder('order-1', reason: 'Changed my mind'),
      expect: () => [
        const OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
      verify: (_) {
        verify(() => mockDataSource.cancelOrder(
              'order-1',
              reason: 'Changed my mind',
            )).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersError] on failure',
      build: () {
        when(() => mockDataSource.cancelOrder(
              any(),
              reason: any(named: 'reason'),
            )).thenThrow(Exception('Cannot cancel'));
        return createCubit();
      },
      act: (cubit) =>
          cubit.cancelOrder('order-1', reason: 'Changed my mind'),
      expect: () => [
        isA<OrdersError>(),
      ],
    );
  });

  group('createOrder', () {
    test('returns OrderEntity on success', () async {
      when(() => mockDataSource.createOrder(
            shippingAddressId: any(named: 'shippingAddressId'),
            shippingAddress: any(named: 'shippingAddress'),
            paymentMethod: any(named: 'paymentMethod'),
            customerNotes: any(named: 'customerNotes'),
            couponCode: any(named: 'couponCode'),
            walletAmountUsed: any(named: 'walletAmountUsed'),
          )).thenAnswer((_) async => testOrder);

      final cubit = createCubit();
      final result = await cubit.createOrder(
        shippingAddressId: 'addr-1',
        paymentMethod: OrderPaymentMethod.cashOnDelivery,
      );

      expect(result, testOrder);
      cubit.close();
    });

    test('returns null and emits OrdersError on failure', () async {
      when(() => mockDataSource.createOrder(
            shippingAddressId: any(named: 'shippingAddressId'),
            shippingAddress: any(named: 'shippingAddress'),
            paymentMethod: any(named: 'paymentMethod'),
            customerNotes: any(named: 'customerNotes'),
            couponCode: any(named: 'couponCode'),
            walletAmountUsed: any(named: 'walletAmountUsed'),
          )).thenThrow(Exception('Order creation failed'));

      final cubit = createCubit();
      final result = await cubit.createOrder(
        shippingAddressId: 'addr-1',
      );

      expect(result, isNull);
      expect(cubit.state, isA<OrdersError>());
      cubit.close();
    });
  });

  group('filterByStatus', () {
    blocTest<OrdersCubit, OrdersState>(
      'calls loadOrders with the given status',
      build: () {
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.filterByStatus(OrderStatus.completed),
      expect: () => [
        const OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
    );
  });

  group('loadOrderStats', () {
    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersStatsLoaded] on success',
      build: () {
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.loadOrderStats(),
      expect: () => [
        OrdersStatsLoaded(testStats),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersError] on failure',
      build: () {
        when(() => mockDataSource.getMyOrderStats())
            .thenThrow(Exception('Failed'));
        return createCubit();
      },
      act: (cubit) => cubit.loadOrderStats(),
      expect: () => [
        isA<OrdersError>(),
      ],
    );
  });

  group('getOrderById', () {
    test('returns order on success', () async {
      when(() => mockDataSource.getOrderById(any()))
          .thenAnswer((_) async => testOrder);

      final cubit = createCubit();
      final result = await cubit.getOrderById('order-1');
      expect(result, testOrder);
      cubit.close();
    });

    test('returns null on failure', () async {
      when(() => mockDataSource.getOrderById(any()))
          .thenThrow(Exception('Not found'));

      final cubit = createCubit();
      final result = await cubit.getOrderById('bad-id');
      expect(result, isNull);
      cubit.close();
    });
  });

  group('reorder', () {
    blocTest<OrdersCubit, OrdersState>(
      'calls reorder then reloads orders on success',
      build: () {
        when(() => mockDataSource.reorder(any()))
            .thenAnswer((_) async => testOrder);
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.reorder('order-1'),
      expect: () => [
        const OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
      verify: (_) {
        verify(() => mockDataSource.reorder('order-1')).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersError] on failure',
      build: () {
        when(() => mockDataSource.reorder(any()))
            .thenThrow(Exception('Cannot reorder'));
        return createCubit();
      },
      act: (cubit) => cubit.reorder('order-1'),
      expect: () => [isA<OrdersError>()],
    );
  });

  group('rateOrder', () {
    test('returns OrderEntity on success', () async {
      when(() => mockDataSource.rateOrder(
            orderId: any(named: 'orderId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
          )).thenAnswer((_) async => testOrder);

      final cubit = createCubit();
      final result = await cubit.rateOrder(orderId: 'order-1', rating: 5);
      expect(result, testOrder);
      cubit.close();
    });

    test('returns null and emits OrdersError on failure', () async {
      when(() => mockDataSource.rateOrder(
            orderId: any(named: 'orderId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
          )).thenThrow(Exception('Rating failed'));

      final cubit = createCubit();
      final result = await cubit.rateOrder(orderId: 'order-1', rating: 5);
      expect(result, isNull);
      expect(cubit.state, isA<OrdersError>());
      cubit.close();
    });
  });

  group('loadPendingPaymentOrders', () {
    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersPendingPaymentLoaded] on success',
      build: () {
        when(() => mockDataSource.getPendingPaymentOrders())
            .thenAnswer((_) async => [testOrder]);
        return createCubit();
      },
      act: (cubit) => cubit.loadPendingPaymentOrders(),
      expect: () => [OrdersPendingPaymentLoaded([testOrder])],
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersError] on failure',
      build: () {
        when(() => mockDataSource.getPendingPaymentOrders())
            .thenThrow(Exception('Failed'));
        return createCubit();
      },
      act: (cubit) => cubit.loadPendingPaymentOrders(),
      expect: () => [isA<OrdersError>()],
    );
  });

  group('loadBankAccounts', () {
    blocTest<OrdersCubit, OrdersState>(
      'emits [BankAccountsLoaded] on success',
      build: () {
        when(() => mockDataSource.getBankAccounts())
            .thenAnswer((_) async => []);
        return createCubit();
      },
      act: (cubit) => cubit.loadBankAccounts(),
      expect: () => [const BankAccountsLoaded([])],
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrdersError] on failure',
      build: () {
        when(() => mockDataSource.getBankAccounts())
            .thenThrow(Exception('Failed'));
        return createCubit();
      },
      act: (cubit) => cubit.loadBankAccounts(),
      expect: () => [isA<OrdersError>()],
    );
  });

  group('uploadReceipt', () {
    blocTest<OrdersCubit, OrdersState>(
      'emits [OrderReceiptUploading, OrdersLoading, OrdersLoaded] on success',
      build: () {
        when(() => mockDataSource.uploadReceipt(
              orderId: any(named: 'orderId'),
              receiptImage: any(named: 'receiptImage'),
              transferReference: any(named: 'transferReference'),
              transferDate: any(named: 'transferDate'),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => testOrder);
        when(() => mockDataSource.getMyOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              orderNumber: any(named: 'orderNumber'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => testOrdersResponse);
        when(() => mockDataSource.getMyOrderStats())
            .thenAnswer((_) async => testStats);
        return createCubit();
      },
      act: (cubit) => cubit.uploadReceipt(
        orderId: 'order-1',
        receiptImage: 'base64image',
      ),
      expect: () => [
        const OrderReceiptUploading('order-1'),
        const OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'emits [OrderReceiptUploading, OrdersError] on failure',
      build: () {
        when(() => mockDataSource.uploadReceipt(
              orderId: any(named: 'orderId'),
              receiptImage: any(named: 'receiptImage'),
              transferReference: any(named: 'transferReference'),
              transferDate: any(named: 'transferDate'),
              notes: any(named: 'notes'),
            )).thenThrow(Exception('Upload failed'));
        return createCubit();
      },
      act: (cubit) => cubit.uploadReceipt(
        orderId: 'order-1',
        receiptImage: 'base64image',
      ),
      expect: () => [
        const OrderReceiptUploading('order-1'),
        isA<OrdersError>(),
      ],
    );
  });
}
