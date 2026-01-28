// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: CustomerModel._readId(json, 'id') as String,
      userId: CustomerModel._readUserId(json, 'userId') as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      responsiblePersonName: json['responsiblePersonName'] as String,
      shopName: json['shopName'] as String,
      shopNameAr: json['shopNameAr'] as String?,
      businessType: json['businessType'] as String? ?? 'shop',
      cityId: CustomerModel._readNestedId(json, 'cityId') as String?,
      marketId:
          CustomerModel._readOptionalNestedId(json, 'marketId') as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priceLevelId:
          CustomerModel._readOptionalNestedId(json, 'priceLevelId') as String?,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      creditUsed: (json['creditUsed'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      loyaltyTier: json['loyaltyTier'] as String? ?? 'bronze',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      lastOrderAt: json['lastOrderAt'] == null
          ? null
          : DateTime.parse(json['lastOrderAt'] as String),
      preferredPaymentMethod: json['preferredPaymentMethod'] as String?,
      preferredShippingTime: json['preferredShippingTime'] as String?,
      preferredContactMethod:
          json['preferredContactMethod'] as String? ?? 'whatsapp',
      instagramHandle: json['instagramHandle'] as String?,
      twitterHandle: json['twitterHandle'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'user': instance.user,
      'responsiblePersonName': instance.responsiblePersonName,
      'shopName': instance.shopName,
      'shopNameAr': instance.shopNameAr,
      'businessType': instance.businessType,
      'cityId': instance.cityId,
      'marketId': instance.marketId,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'priceLevelId': instance.priceLevelId,
      'creditLimit': instance.creditLimit,
      'creditUsed': instance.creditUsed,
      'walletBalance': instance.walletBalance,
      'loyaltyPoints': instance.loyaltyPoints,
      'loyaltyTier': instance.loyaltyTier,
      'totalOrders': instance.totalOrders,
      'totalSpent': instance.totalSpent,
      'averageOrderValue': instance.averageOrderValue,
      'lastOrderAt': instance.lastOrderAt?.toIso8601String(),
      'preferredPaymentMethod': instance.preferredPaymentMethod,
      'preferredShippingTime': instance.preferredShippingTime,
      'preferredContactMethod': instance.preferredContactMethod,
      'instagramHandle': instance.instagramHandle,
      'twitterHandle': instance.twitterHandle,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
