/// Customer Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer_entity.dart';
import 'user_model.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final int id;
  final UserModel user;
  @JsonKey(name: 'customer_code')
  final String customerCode;
  @JsonKey(name: 'responsible_person_name')
  final String responsiblePersonName;
  @JsonKey(name: 'shop_name')
  final String shopName;
  @JsonKey(name: 'shop_name_ar')
  final String? shopNameAr;
  @JsonKey(name: 'business_type')
  final String businessType;
  @JsonKey(name: 'city_id')
  final int cityId;
  @JsonKey(name: 'market_id')
  final int? marketId;
  final String? address;
  @JsonKey(name: 'price_level_id')
  final int priceLevelId;
  @JsonKey(name: 'credit_limit')
  final double creditLimit;
  @JsonKey(name: 'credit_used')
  final double creditUsed;
  @JsonKey(name: 'wallet_balance')
  final double walletBalance;
  @JsonKey(name: 'loyalty_points')
  final int loyaltyPoints;
  @JsonKey(name: 'loyalty_tier')
  final String loyaltyTier;
  @JsonKey(name: 'total_orders')
  final int totalOrders;
  @JsonKey(name: 'total_spent')
  final double totalSpent;
  @JsonKey(name: 'approved_at')
  final String? approvedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const CustomerModel({
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

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      user: user.toEntity(),
      customerCode: customerCode,
      responsiblePersonName: responsiblePersonName,
      shopName: shopName,
      shopNameAr: shopNameAr,
      businessType: businessType,
      cityId: cityId,
      marketId: marketId,
      address: address,
      priceLevelId: priceLevelId,
      creditLimit: creditLimit,
      creditUsed: creditUsed,
      walletBalance: walletBalance,
      loyaltyPoints: loyaltyPoints,
      loyaltyTier: loyaltyTier,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      approvedAt: approvedAt != null ? DateTime.tryParse(approvedAt!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}
