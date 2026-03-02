/// Order Entity - Domain layer representation of an order
library;

import 'package:equatable/equatable.dart';
import '../enums/order_enums.dart';

export '../enums/order_enums.dart';

/// Order item entity
class OrderItemEntity extends Equatable {
  /// MongoDB ObjectId for order item - used for returns API (orderItemId)
  final String? id;
  final String productId;
  final String? variantId;
  final String? sku;
  final String name;
  final String? nameAr;
  final String? image;
  final int quantity;
  final int returnedQuantity;
  final int returnableQuantity;
  final int reservedQuantity;
  final bool isEffectivelyFullyReturned;
  final double unitPrice;
  final double discount;
  final double total;
  final Map<String, dynamic>? attributes;

  const OrderItemEntity({
    this.id,
    required this.productId,
    this.variantId,
    this.sku,
    required this.name,
    this.nameAr,
    this.image,
    required this.quantity,
    this.returnedQuantity = 0,
    this.returnableQuantity = 0,
    this.reservedQuantity = 0,
    this.isEffectivelyFullyReturned = false,
    required this.unitPrice,
    this.discount = 0,
    required this.total,
    this.attributes,
  });

  int get effectiveQuantity =>
      returnableQuantity > 0
          ? returnableQuantity
          : (quantity - returnedQuantity - reservedQuantity).clamp(0, quantity);
  /// Crossed out when: fully returned OR in active return (pending/approved/etc - not cancelled)
  bool get isFullyReturned =>
      isEffectivelyFullyReturned ||
      (returnedQuantity >= quantity && quantity > 0);
  bool get isPartiallyReturned =>
      (returnedQuantity + reservedQuantity) > 0 &&
      (returnedQuantity + reservedQuantity) < quantity;

  String getName(String locale) =>
      locale == 'ar' && nameAr != null ? nameAr! : name;

  @override
  List<Object?> get props => [id, productId, variantId, quantity];
}

/// Shipping address entity
class ShippingAddressEntity extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? district;
  final String? postalCode;
  final String? notes;

  const ShippingAddressEntity({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.district,
    this.postalCode,
    this.notes,
  });

  String get formattedAddress {
    final parts = <String>[address];
    if (district != null) parts.add(district!);
    parts.add(city);
    return parts.join('، ');
  }

  @override
  List<Object?> get props => [fullName, phone, address, city];
}

/// Order entity
class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  /// Price level ID used when order was created (from pricing rules)
  final String? priceLevelId;
  final OrderStatus status;

  // Amounts
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discount;
  final double couponDiscount;
  final double walletBalanceBefore;
  final double walletAmountUsed;
  final double walletBalanceAfter;
  final double remainingAfterWallet;
  final int loyaltyPointsUsed;
  final double loyaltyPointsValue;
  final double total;
  final double paidAmount;

  // Payment
  final PaymentStatus paymentStatus;
  final OrderPaymentMethod? paymentMethod;
  final String? transferStatus;
  final String? transferReceiptImage;
  final String? transferReference;
  final DateTime? transferDate;
  final DateTime? transferVerifiedAt;
  final String? paymentRejectionReason;

  // Shipping
  final String? shippingAddressId;
  final ShippingAddressEntity? shippingAddress;
  final DateTime? estimatedDeliveryDate;

  // Coupon
  final String? couponId;
  final String? couponCode;

  // Source
  final OrderSource source;

  // Notes
  final String? customerNotes;

  // Timestamps
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Shipping Label
  final String? shippingLabelUrl;

  // Rating
  final int? customerRating; // 1-5
  final String? customerRatingComment;
  final DateTime? ratedAt;

  // Items
  final List<OrderItemEntity> items;

  final bool cancellable;

  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.priceLevelId,
    required this.status,
    required this.subtotal,
    this.taxAmount = 0,
    this.shippingCost = 0,
    this.discount = 0,
    this.couponDiscount = 0,
    this.walletBalanceBefore = 0,
    this.walletAmountUsed = 0,
    this.walletBalanceAfter = 0,
    this.remainingAfterWallet = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsValue = 0,
    required this.total,
    this.paidAmount = 0,
    this.paymentStatus = PaymentStatus.unpaid,
    this.paymentMethod,
    this.transferStatus,
    this.transferReceiptImage,
    this.transferReference,
    this.transferDate,
    this.transferVerifiedAt,
    this.paymentRejectionReason,
    this.shippingAddressId,
    this.shippingAddress,
    this.estimatedDeliveryDate,
    this.couponId,
    this.couponCode,
    this.source = OrderSource.mobile,
    this.customerNotes,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.shippingLabelUrl,
    this.customerRating,
    this.customerRatingComment,
    this.ratedAt,
    this.items = const [],
    this.cancellable = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get itemsCount => items.length;
  double get remainingAmount => total - paidAmount;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canCancel => cancellable;
  bool get canUploadTransferReceipt {
    if (paymentMethod != OrderPaymentMethod.bankTransfer) return false;
    if (remainingAmount <= 0) return false;

    final status = (transferStatus ?? '').toLowerCase();
    return status.isEmpty ||
        status == 'awaiting_receipt' ||
        status == 'rejected' ||
        status == 'not_required';
  }

  /// Status text in Arabic for backward compatibility
  String get statusText => status.displayNameAr;

  /// Check if order is rated
  bool get isRated => customerRating != null && customerRating! > 0;

  /// Check if order can be rated
  bool get canRate =>
      (status == OrderStatus.delivered || status == OrderStatus.completed) &&
      !isRated;

  @override
  List<Object?> get props => [id, orderNumber, status];
}
