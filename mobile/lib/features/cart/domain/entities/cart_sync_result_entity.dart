/// Cart Sync Result Entity - Results from syncing local cart with server
library;

import 'package:equatable/equatable.dart';
import 'cart_entity.dart';
import '../../data/models/cart_model.dart';

/// Entity representing a removed item during sync
class RemovedCartItem extends Equatable {
  final String productId;
  final String reason; // 'out_of_stock', 'deleted', 'inactive'
  final String? productName;
  final String? productNameAr;

  const RemovedCartItem({
    required this.productId,
    required this.reason,
    this.productName,
    this.productNameAr,
  });

  factory RemovedCartItem.fromJson(Map<String, dynamic> json) {
    return RemovedCartItem(
      productId: json['productId'] as String,
      reason: json['reason'] as String? ?? 'unknown',
      productName: json['productName'] as String?,
      productNameAr: json['productNameAr'] as String?,
    );
  }

  @override
  List<Object?> get props => [productId, reason];
}

/// Entity representing a price-changed item during sync
class PriceChangedCartItem extends Equatable {
  final String productId;
  final double oldPrice;
  final double newPrice;
  final String? productName;
  final String? productNameAr;

  const PriceChangedCartItem({
    required this.productId,
    required this.oldPrice,
    required this.newPrice,
    this.productName,
    this.productNameAr,
  });

  factory PriceChangedCartItem.fromJson(Map<String, dynamic> json) {
    return PriceChangedCartItem(
      productId: json['productId'] as String,
      oldPrice: (json['oldPrice'] as num).toDouble(),
      newPrice: (json['newPrice'] as num).toDouble(),
      productName: json['productName'] as String?,
      productNameAr: json['productNameAr'] as String?,
    );
  }

  double get priceDifference => newPrice - oldPrice;
  double get priceChangePercentage =>
      oldPrice > 0 ? (priceDifference / oldPrice) * 100 : 0;

  @override
  List<Object?> get props => [productId, oldPrice, newPrice];
}

/// Entity representing a quantity-adjusted item during sync
class QuantityAdjustedCartItem extends Equatable {
  final String productId;
  final int requestedQuantity;
  final int availableQuantity;
  final int finalQuantity;
  final String? productName;
  final String? productNameAr;

  const QuantityAdjustedCartItem({
    required this.productId,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.finalQuantity,
    this.productName,
    this.productNameAr,
  });

  factory QuantityAdjustedCartItem.fromJson(Map<String, dynamic> json) {
    return QuantityAdjustedCartItem(
      productId: json['productId'] as String,
      requestedQuantity: json['requestedQuantity'] as int,
      availableQuantity: json['availableQuantity'] as int,
      finalQuantity: json['finalQuantity'] as int,
      productName: json['productName'] as String?,
      productNameAr: json['productNameAr'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    requestedQuantity,
    availableQuantity,
    finalQuantity,
  ];
}

/// Entity representing the complete sync result
class CartSyncResultEntity extends Equatable {
  final CartEntity syncedCart;
  final List<RemovedCartItem> removedItems;
  final List<PriceChangedCartItem> priceChangedItems;
  final List<QuantityAdjustedCartItem> quantityAdjustedItems;

  const CartSyncResultEntity({
    required this.syncedCart,
    this.removedItems = const [],
    this.priceChangedItems = const [],
    this.quantityAdjustedItems = const [],
  });

  /// Check if sync resulted in any changes
  bool get hasChanges =>
      removedItems.isNotEmpty ||
      priceChangedItems.isNotEmpty ||
      quantityAdjustedItems.isNotEmpty;

  /// Check if sync has issues that need user attention
  bool get hasIssues => hasChanges;

  factory CartSyncResultEntity.fromJson(Map<String, dynamic> json) {
    // Parse cart using CartModel
    final cartData = json['cart'] as Map<String, dynamic>? ?? json;
    final cartModel = CartModel.fromJson(cartData);
    final cart = cartModel.toEntity();

    // Parse removed items
    final removedItemsData = json['removedItems'] as List? ?? [];
    final removedItems = removedItemsData
        .map((item) => RemovedCartItem.fromJson(item as Map<String, dynamic>))
        .toList();

    // Parse price changed items
    final priceChangedItemsData = json['priceChangedItems'] as List? ?? [];
    final priceChangedItems = priceChangedItemsData
        .map(
          (item) => PriceChangedCartItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    // Parse quantity adjusted items
    final quantityAdjustedItemsData =
        json['quantityAdjustedItems'] as List? ?? [];
    final quantityAdjustedItems = quantityAdjustedItemsData
        .map(
          (item) =>
              QuantityAdjustedCartItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return CartSyncResultEntity(
      syncedCart: cart,
      removedItems: removedItems,
      priceChangedItems: priceChangedItems,
      quantityAdjustedItems: quantityAdjustedItems,
    );
  }

  @override
  List<Object?> get props => [
    syncedCart,
    removedItems,
    priceChangedItems,
    quantityAdjustedItems,
  ];
}
