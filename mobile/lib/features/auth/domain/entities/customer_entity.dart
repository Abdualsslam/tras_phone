/// Customer Entity - Domain layer representation of a customer
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../../profile/domain/enums/customer_enums.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String? userId;
  final UserEntity? user;
  final String responsiblePersonName;
  final String shopName;
  final String? shopNameAr;
  final BusinessType businessType;

  // Location
  final String? cityId;
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;

  // Pricing & Credit
  final String? priceLevelId;
  final double creditLimit;
  final double creditUsed;

  // Wallet
  final double walletBalance;

  // Loyalty
  final int loyaltyPoints;
  final LoyaltyTier loyaltyTier;

  // Statistics
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final DateTime? lastOrderAt;

  // Preferences
  final PaymentMethod? preferredPaymentMethod;
  final String? preferredShippingTime;
  final ContactMethod preferredContactMethod;

  // Social
  final String? instagramHandle;
  final String? twitterHandle;

  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerEntity({
    required this.id,
    this.userId,
    this.user,
    required this.responsiblePersonName,
    required this.shopName,
    this.shopNameAr,
    this.businessType = BusinessType.shop,
    this.cityId,
    this.marketId,
    this.address,
    this.latitude,
    this.longitude,
    this.priceLevelId,
    this.creditLimit = 0.0,
    this.creditUsed = 0.0,
    this.walletBalance = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = LoyaltyTier.bronze,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.averageOrderValue = 0.0,
    this.lastOrderAt,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    this.preferredContactMethod = ContactMethod.whatsapp,
    this.instagramHandle,
    this.twitterHandle,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApproved => approvedAt != null;
  double get availableCredit => creditLimit - creditUsed;

  /// Get shop name based on locale
  String getShopName(String locale) =>
      locale == 'ar' && shopNameAr != null ? shopNameAr! : shopName;

  @override
  List<Object?> get props => [id, userId];
}
