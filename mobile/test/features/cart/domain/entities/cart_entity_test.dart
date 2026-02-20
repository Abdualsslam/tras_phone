import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/features/cart/domain/entities/cart_entity.dart';
import 'package:tras_phone/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  CartEntity createCart({
    String id = 'cart-1',
    String customerId = 'cust-1',
    CartStatus status = CartStatus.active,
    List<CartItemEntity> items = const [],
    int itemsCount = 0,
    double subtotal = 0,
    double total = 0,
    String? couponCode,
    double couponDiscount = 0,
  }) {
    return CartEntity(
      id: id,
      customerId: customerId,
      status: status,
      items: items,
      itemsCount: itemsCount,
      subtotal: subtotal,
      total: total,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
      createdAt: now,
      updatedAt: now,
    );
  }

  CartItemEntity createItem({
    String productId = 'prod-1',
    int quantity = 1,
    double unitPrice = 10.0,
  }) {
    return CartItemEntity(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
      addedAt: now,
    );
  }

  group('isEmpty / isNotEmpty', () {
    test('isEmpty returns true when items list is empty', () {
      final cart = createCart(items: []);
      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true when items list has items', () {
      final cart = createCart(items: [createItem()]);
      expect(cart.isNotEmpty, isTrue);
      expect(cart.isEmpty, isFalse);
    });
  });

  group('hasCoupon', () {
    test('returns false when couponCode is null', () {
      final cart = createCart(couponCode: null);
      expect(cart.hasCoupon, isFalse);
    });

    test('returns false when couponCode is empty', () {
      final cart = createCart(couponCode: '');
      expect(cart.hasCoupon, isFalse);
    });

    test('returns true when couponCode is non-empty', () {
      final cart = createCart(couponCode: 'SAVE10');
      expect(cart.hasCoupon, isTrue);
    });
  });

  group('copyWith', () {
    test('returns new instance with updated fields', () {
      final original = createCart(
        id: 'cart-1',
        subtotal: 100,
        total: 100,
      );
      final copied = original.copyWith(subtotal: 200, total: 200);

      expect(copied.subtotal, 200);
      expect(copied.total, 200);
      expect(copied.id, 'cart-1'); // unchanged
      expect(copied.customerId, 'cust-1'); // unchanged
    });

    test('returns identical values when no args passed', () {
      final original = createCart(
        subtotal: 50,
        couponCode: 'CODE',
      );
      final copied = original.copyWith();

      expect(copied.subtotal, 50);
      expect(copied.couponCode, 'CODE');
      expect(copied.id, original.id);
    });

    test('can update items', () {
      final original = createCart();
      final newItems = [createItem(productId: 'new-prod')];
      final copied = original.copyWith(items: newItems);

      expect(copied.items.length, 1);
      expect(copied.items.first.productId, 'new-prod');
    });

    test('can update status', () {
      final original = createCart(status: CartStatus.active);
      final copied = original.copyWith(status: CartStatus.abandoned);
      expect(copied.status, CartStatus.abandoned);
    });
  });

  group('Equatable', () {
    test('two carts with same props should be equal', () {
      final c1 = createCart();
      final c2 = createCart();
      expect(c1, equals(c2));
    });

    test('two carts with different id should not be equal', () {
      final c1 = createCart(id: 'a');
      final c2 = createCart(id: 'b');
      expect(c1, isNot(equals(c2)));
    });

    test('props includes id, items, subtotal, couponCode', () {
      final cart = createCart(
        id: 'x',
        subtotal: 99,
        couponCode: 'C',
      );
      expect(cart.props, ['x', <CartItemEntity>[], 99.0, 'C']);
    });
  });
}
