/// Return Entity - Domain layer representation of a return request
library;

import 'package:equatable/equatable.dart';
import '../enums/return_enums.dart';

export '../enums/return_enums.dart';

/// Pickup Address Entity
class PickupAddressEntity extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? notes;

  const PickupAddressEntity({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.notes,
  });

  @override
  List<Object?> get props => [fullName, phone, address, city, notes];
}

/// Return Item Entity
class ReturnItemEntity extends Equatable {
  final String id;
  final String returnRequestId;
  final String orderItemId;
  final String productId;
  final String productSku;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final InspectionStatus inspectionStatus;
  final ItemCondition? condition;
  final int approvedQuantity;
  final int rejectedQuantity;
  final String? inspectionNotes;

  const ReturnItemEntity({
    required this.id,
    required this.returnRequestId,
    required this.orderItemId,
    required this.productId,
    required this.productSku,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.inspectionStatus,
    this.condition,
    required this.approvedQuantity,
    required this.rejectedQuantity,
    this.inspectionNotes,
  });

  @override
  List<Object?> get props => [
        id,
        returnRequestId,
        orderItemId,
        productId,
        quantity,
        unitPrice,
        totalValue,
        inspectionStatus,
      ];
}

/// Return Reason Entity
class ReturnReasonEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final ReasonCategory category;
  final bool requiresPhoto;
  final bool eligibleForRefund;
  final bool eligibleForExchange;
  final int displayOrder;
  final bool isActive;

  const ReturnReasonEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    required this.category,
    required this.requiresPhoto,
    required this.eligibleForRefund,
    required this.eligibleForExchange,
    required this.displayOrder,
    required this.isActive,
  });

  /// Get name based on locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        category,
        requiresPhoto,
        eligibleForRefund,
        eligibleForExchange,
      ];
}

/// Return Request Entity
class ReturnEntity extends Equatable {
  final String id;
  final String returnNumber;
  final List<String> orderIds;
  final String customerId;
  final ReturnStatus status;
  final ReturnType returnType;
  final String reasonId;
  final ReturnReasonEntity? reason;
  final String? customerNotes;
  final List<String>? customerImages;
  final double totalItemsValue;
  final double restockingFee;
  final double shippingDeduction;
  final double refundAmount;
  final PickupAddressEntity? pickupAddress;
  final DateTime? scheduledPickupDate;
  final String? pickupTrackingNumber;
  final String? exchangeOrderId;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime? completedAt;
  final List<ReturnItemEntity>? items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReturnEntity({
    required this.id,
    required this.returnNumber,
    required this.orderIds,
    required this.customerId,
    required this.status,
    required this.returnType,
    required this.reasonId,
    this.reason,
    this.customerNotes,
    this.customerImages,
    required this.totalItemsValue,
    required this.restockingFee,
    required this.shippingDeduction,
    required this.refundAmount,
    this.pickupAddress,
    this.scheduledPickupDate,
    this.pickupTrackingNumber,
    this.exchangeOrderId,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.completedAt,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get primary order ID (first in list)
  String get primaryOrderId => orderIds.isNotEmpty ? orderIds.first : '';

  /// Can cancel the return request?
  bool get canCancel => status == ReturnStatus.pending;

  /// Is the return request active?
  bool get isActive => ![
        ReturnStatus.completed,
        ReturnStatus.cancelled,
        ReturnStatus.rejected,
      ].contains(status);

  /// Net refund amount
  double get netRefund => totalItemsValue - restockingFee - shippingDeduction;

  @override
  List<Object?> get props => [
        id,
        returnNumber,
        orderIds,
        customerId,
        status,
        returnType,
        reasonId,
        totalItemsValue,
        refundAmount,
        createdAt,
      ];
}
