/// Customer Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../../profile/domain/enums/customer_enums.dart';
import '../../domain/entities/customer_entity.dart';
import 'user_model.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'userId', readValue: _readUserId)
  final String? userId;

  final UserModel? user;

  final String responsiblePersonName;
  final String shopName;
  final String? shopNameAr;
  @JsonKey(defaultValue: 'shop')
  final String businessType;

  // Location
  @JsonKey(name: 'cityId', readValue: _readNestedId)
  final String? cityId;
  @JsonKey(name: 'marketId', readValue: _readOptionalNestedId)
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;

  // Pricing & Credit
  @JsonKey(name: 'priceLevelId', readValue: _readOptionalNestedId)
  final String? priceLevelId;
  @JsonKey(defaultValue: 0.0)
  final double creditLimit;
  @JsonKey(defaultValue: 0.0)
  final double creditUsed;

  // Wallet
  @JsonKey(defaultValue: 0.0)
  final double walletBalance;

  // Loyalty
  @JsonKey(defaultValue: 0)
  final int loyaltyPoints;
  @JsonKey(defaultValue: 'bronze')
  final String loyaltyTier;

  // Statistics
  @JsonKey(defaultValue: 0)
  final int totalOrders;
  @JsonKey(defaultValue: 0.0)
  final double totalSpent;
  @JsonKey(defaultValue: 0.0)
  final double averageOrderValue;
  final DateTime? lastOrderAt;

  // Preferences
  final String? preferredPaymentMethod;
  final String? preferredShippingTime;
  @JsonKey(defaultValue: 'whatsapp')
  final String preferredContactMethod;

  // Social
  final String? instagramHandle;
  final String? twitterHandle;

  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.id,
    this.userId,
    this.user,
    required this.responsiblePersonName,
    required this.shopName,
    this.shopNameAr,
    this.businessType = 'shop',
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
    this.loyaltyTier = 'bronze',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.averageOrderValue = 0.0,
    this.lastOrderAt,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    this.preferredContactMethod = 'whatsapp',
    this.instagramHandle,
    this.twitterHandle,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle userId which can be String or populated User object
  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    final value = json['userId'];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  /// Handle nested ID fields that may be populated objects
  static Object? _readNestedId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  /// Handle optional nested ID fields
  static Object? _readOptionalNestedId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      userId: userId,
      user: user?.toEntity(),
      responsiblePersonName: responsiblePersonName,
      shopName: shopName,
      shopNameAr: shopNameAr,
      businessType: BusinessType.fromString(businessType),
      cityId: cityId,
      marketId: marketId,
      address: address,
      latitude: latitude,
      longitude: longitude,
      priceLevelId: priceLevelId,
      creditLimit: creditLimit,
      creditUsed: creditUsed,
      walletBalance: walletBalance,
      loyaltyPoints: loyaltyPoints,
      loyaltyTier: LoyaltyTier.fromString(loyaltyTier),
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      averageOrderValue: averageOrderValue,
      lastOrderAt: lastOrderAt,
      preferredPaymentMethod: preferredPaymentMethod != null
          ? PaymentMethod.fromString(preferredPaymentMethod!)
          : null,
      preferredShippingTime: preferredShippingTime,
      preferredContactMethod: ContactMethod.fromString(preferredContactMethod),
      instagramHandle: instagramHandle,
      twitterHandle: twitterHandle,
      approvedAt: approvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
