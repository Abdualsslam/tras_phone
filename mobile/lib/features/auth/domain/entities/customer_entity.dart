/// Customer Entity - Domain layer representation of a customer
library;

import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class CustomerEntity extends Equatable {
  final int id;
  final UserEntity user;
  final String customerCode;
  final String responsiblePersonName;
  final String shopName;
  final String? shopNameAr;
  final String businessType;
  final int cityId;
  final int? marketId;
  final String? address;
  final int priceLevelId;
  final double creditLimit;
  final double creditUsed;
  final double walletBalance;
  final int loyaltyPoints;
  final String loyaltyTier;
  final int totalOrders;
  final double totalSpent;
  final DateTime? approvedAt;
  final DateTime? createdAt;

  const CustomerEntity({
    required this.id,
    required this.user,
    required this.customerCode,
    required this.responsiblePersonName,
    required this.shopName,
    this.shopNameAr,
    this.businessType = 'shop',
    required this.cityId,
    this.marketId,
    this.address,
    required this.priceLevelId,
    this.creditLimit = 0.0,
    this.creditUsed = 0.0,
    this.walletBalance = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.approvedAt,
    this.createdAt,
  });

  bool get isApproved => approvedAt != null;
  double get availableCredit => creditLimit - creditUsed;

  @override
  List<Object?> get props => [id, customerCode, user];
}
