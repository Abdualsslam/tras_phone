import 'package:equatable/equatable.dart';
import 'checkout_cart_item_entity.dart';

/// Cart with populated product details
class CheckoutCartEntity extends Equatable {
  final String id;
  final String customerId;
  final String status;
  final List<CheckoutCartItemEntity> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponCode;
  final double couponDiscount;

  const CheckoutCartEntity({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.shippingCost,
    required this.total,
    this.couponCode,
    required this.couponDiscount,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// Check if any item has stock issues
  bool get hasStockIssues => items.any((item) => item.hasStockIssue);

  /// Check if any item is inactive
  bool get hasInactiveProducts => items.any((item) => item.isProductInactive);

  /// Get items with stock issues
  List<CheckoutCartItemEntity> get itemsWithStockIssues =>
      items.where((item) => item.hasStockIssue).toList();

  /// Get inactive product items
  List<CheckoutCartItemEntity> get inactiveProductItems =>
      items.where((item) => item.isProductInactive).toList();

  @override
  List<Object?> get props => [
    id,
    items,
    itemsCount,
    subtotal,
    total,
    couponCode,
    couponDiscount,
  ];
}
