import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:tras_phone/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:tras_phone/features/cart/domain/entities/cart_entity.dart';
import 'package:tras_phone/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tras_phone/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:tras_phone/features/cart/presentation/cubit/cart_state.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

void main() {
  late MockCartRemoteDataSource mockRemote;
  late MockCartLocalDataSource mockLocal;

  final now = DateTime(2024, 1, 1);

  final emptyCart = CartEntity(
    id: 'cart-1',
    customerId: 'cust-1',
    items: const [],
    itemsCount: 0,
    subtotal: 0,
    total: 0,
    createdAt: now,
    updatedAt: now,
  );

  final cartWithItem = CartEntity(
    id: 'cart-1',
    customerId: 'cust-1',
    items: [
      CartItemEntity(
        productId: 'prod-1',
        quantity: 2,
        unitPrice: 50.0,
        totalPrice: 100.0,
        addedAt: now,
      ),
    ],
    itemsCount: 2,
    subtotal: 100.0,
    total: 100.0,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRemote = MockCartRemoteDataSource();
    mockLocal = MockCartLocalDataSource();
  });

  void stubEmptyLocalCart() {
    when(() => mockLocal.getLocalCart()).thenAnswer((_) async => []);
  }

  /// Creates cubit and waits for constructor's async _loadLocalCart to settle
  Future<CartCubit> createCubit() async {
    stubEmptyLocalCart();
    final cubit = CartCubit(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
    // Let the constructor's _loadLocalCart() microtask complete
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return cubit;
  }

  /// Collects states emitted during an action
  Future<List<CartState>> collectStates(
    CartCubit cubit,
    Future<void> Function() action,
  ) async {
    final states = <CartState>[];
    final sub = cubit.stream.listen(states.add);
    await action();
    // Allow async microtasks to complete
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    return states;
  }

  group('initial state', () {
    test('should be CartInitial', () {
      stubEmptyLocalCart();
      final cubit = CartCubit(
        remoteDataSource: mockRemote,
        localDataSource: mockLocal,
      );
      expect(cubit.state, const CartInitial());
      cubit.close();
    });
  });

  group('loadCart', () {
    test('emits CartLoading then CartLoaded on success', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => emptyCart);
      final cubit = await createCubit();

      final states = await collectStates(cubit, () => cubit.loadCart());

      expect(states.first, const CartLoading());
      expect(states.last, CartLoaded(emptyCart));
      cubit.close();
    });

    test('emits CartLoading then CartError on failure', () async {
      when(() => mockRemote.getCart()).thenThrow(Exception('Network error'));
      final cubit = await createCubit();

      final states = await collectStates(cubit, () => cubit.loadCart());

      expect(states.first, const CartLoading());
      expect(states.last, isA<CartError>());
      cubit.close();
    });
  });

  group('addToCart', () {
    test('emits CartLoaded on success when no existing cart', () async {
      when(() => mockRemote.addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
            unitPrice: any(named: 'unitPrice'),
          )).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();

      final states = await collectStates(
        cubit,
        () => cubit.addToCart(
            productId: 'prod-1', quantity: 2, unitPrice: 50.0),
      );

      expect(states.last, CartLoaded(cartWithItem));
      cubit.close();
    });

    test('emits CartUpdating then CartLoaded when cart already loaded',
        () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => emptyCart);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
            unitPrice: any(named: 'unitPrice'),
          )).thenAnswer((_) async => cartWithItem);

      final states = await collectStates(
        cubit,
        () => cubit.addToCart(
            productId: 'prod-1', quantity: 2, unitPrice: 50.0),
      );

      expect(states[0], CartUpdating(emptyCart));
      expect(states[1], CartLoaded(cartWithItem));
      cubit.close();
    });

    test('emits CartError with previousCart on failure', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => emptyCart);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
            unitPrice: any(named: 'unitPrice'),
          )).thenThrow(Exception('Failed'));

      final states = await collectStates(
        cubit,
        () => cubit.addToCart(productId: 'prod-1', quantity: 1),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], isA<CartError>());
      expect((states[1] as CartError).previousCart, emptyCart);
      cubit.close();
    });
  });

  group('updateQuantity', () {
    test('emits CartUpdating then CartLoaded on success', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.updateQuantity(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          )).thenAnswer((_) async => cartWithItem);

      final states = await collectStates(
        cubit,
        () => cubit.updateQuantity('prod-1', 5),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], isA<CartLoaded>());
      cubit.close();
    });

    test('emits CartUpdating then CartError on failure', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.updateQuantity(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          )).thenThrow(Exception('Failed'));

      final states = await collectStates(
        cubit,
        () => cubit.updateQuantity('prod-1', 5),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], isA<CartError>());
      cubit.close();
    });
  });

  group('removeFromCart', () {
    test('emits CartUpdating then CartLoaded on success', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.removeFromCart(
            productId: any(named: 'productId'),
          )).thenAnswer((_) async => emptyCart);

      final states = await collectStates(
        cubit,
        () => cubit.removeFromCart('prod-1'),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], CartLoaded(emptyCart));
      cubit.close();
    });

    test('emits CartUpdating then CartError on failure', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.removeFromCart(
            productId: any(named: 'productId'),
          )).thenThrow(Exception('Failed'));

      final states = await collectStates(
        cubit,
        () => cubit.removeFromCart('prod-1'),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], isA<CartError>());
      cubit.close();
    });
  });

  group('clearCart', () {
    test('emits CartLoading then CartLoaded on success', () async {
      when(() => mockRemote.clearCart()).thenAnswer((_) async => emptyCart);
      final cubit = await createCubit();

      final states = await collectStates(cubit, () => cubit.clearCart());

      expect(states.first, const CartLoading());
      expect(states.last, CartLoaded(emptyCart));
      cubit.close();
    });

    test('emits CartLoading then CartError on failure', () async {
      when(() => mockRemote.clearCart()).thenThrow(Exception('Failed'));
      final cubit = await createCubit();

      final states = await collectStates(cubit, () => cubit.clearCart());

      expect(states.first, const CartLoading());
      expect(states.last, isA<CartError>());
      cubit.close();
    });
  });

  group('applyCoupon', () {
    test('emits CartUpdating then CartLoaded on success', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => emptyCart);
      final cubit = await createCubit();
      await cubit.loadCart();

      final cartWithCoupon = emptyCart.copyWith(
        couponCode: 'SAVE10',
        couponDiscount: 10.0,
      );
      when(() => mockRemote.applyCoupon(
            couponId: any(named: 'couponId'),
            couponCode: any(named: 'couponCode'),
            discountAmount: any(named: 'discountAmount'),
          )).thenAnswer((_) async => cartWithCoupon);

      final states = await collectStates(
        cubit,
        () => cubit.applyCoupon('SAVE10'),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], isA<CartLoaded>());
      cubit.close();
    });
  });

  group('removeCoupon', () {
    test('emits CartUpdating then CartLoaded on success', () async {
      when(() => mockRemote.getCart()).thenAnswer((_) async => cartWithItem);
      final cubit = await createCubit();
      await cubit.loadCart();

      when(() => mockRemote.removeCoupon())
          .thenAnswer((_) async => emptyCart);

      final states = await collectStates(
        cubit,
        () => cubit.removeCoupon(),
      );

      expect(states[0], isA<CartUpdating>());
      expect(states[1], CartLoaded(emptyCart));
      cubit.close();
    });
  });

  group('getCartCount', () {
    test('returns count from remote on success', () async {
      when(() => mockRemote.getCartCount()).thenAnswer((_) async => 5);
      final cubit = await createCubit();

      final count = await cubit.getCartCount();
      expect(count, 5);
      cubit.close();
    });

    test('falls back to local count on remote failure', () async {
      when(() => mockRemote.getCartCount()).thenThrow(Exception('Failed'));
      when(() => mockLocal.getLocalCartCount()).thenAnswer((_) async => 3);
      final cubit = await createCubit();

      final count = await cubit.getCartCount();
      expect(count, 3);
      cubit.close();
    });
  });
}
