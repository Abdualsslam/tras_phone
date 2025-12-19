// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual implementation for customer_model.g.dart

part of 'customer_model.dart';

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      customerCode: json['customer_code'] as String,
      responsiblePersonName: json['responsible_person_name'] as String,
      shopName: json['shop_name'] as String,
      shopNameAr: json['shop_name_ar'] as String?,
      businessType: json['business_type'] as String? ?? 'shop',
      cityId: json['city_id'] as int,
      marketId: json['market_id'] as int?,
      address: json['address'] as String?,
      priceLevelId: json['price_level_id'] as int,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      creditUsed: (json['credit_used'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      loyaltyTier: json['loyalty_tier'] as String? ?? 'bronze',
      totalOrders: json['total_orders'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      approvedAt: json['approved_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user.toJson(),
      'customer_code': instance.customerCode,
      'responsible_person_name': instance.responsiblePersonName,
      'shop_name': instance.shopName,
      'shop_name_ar': instance.shopNameAr,
      'business_type': instance.businessType,
      'city_id': instance.cityId,
      'market_id': instance.marketId,
      'address': instance.address,
      'price_level_id': instance.priceLevelId,
      'credit_limit': instance.creditLimit,
      'credit_used': instance.creditUsed,
      'wallet_balance': instance.walletBalance,
      'loyalty_points': instance.loyaltyPoints,
      'loyalty_tier': instance.loyaltyTier,
      'total_orders': instance.totalOrders,
      'total_spent': instance.totalSpent,
      'approved_at': instance.approvedAt,
      'created_at': instance.createdAt,
    };
