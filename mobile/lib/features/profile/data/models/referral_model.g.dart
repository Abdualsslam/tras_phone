// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralModel _$ReferralModelFromJson(Map<String, dynamic> json) =>
    ReferralModel(
      id: ReferralModel._readId(json, 'id') as String,
      referrerId: ReferralModel._readNestedId(json, 'referrerId') as String,
      referredId: ReferralModel._readNestedId(json, 'referredId') as String,
      referralCode: json['referralCode'] as String,
      status: json['status'] as String? ?? 'pending',
      referrerRewardAmount: (json['referrerRewardAmount'] as num?)?.toDouble(),
      referredRewardAmount: (json['referredRewardAmount'] as num?)?.toDouble(),
      referrerRewardedAt: json['referrerRewardedAt'] == null
          ? null
          : DateTime.parse(json['referrerRewardedAt'] as String),
      referredRewardedAt: json['referredRewardedAt'] == null
          ? null
          : DateTime.parse(json['referredRewardedAt'] as String),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      qualifyingOrderId: json['qualifyingOrderId'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReferralModelToJson(ReferralModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'referrerId': instance.referrerId,
      'referredId': instance.referredId,
      'referralCode': instance.referralCode,
      'status': instance.status,
      'referrerRewardAmount': instance.referrerRewardAmount,
      'referredRewardAmount': instance.referredRewardAmount,
      'referrerRewardedAt': instance.referrerRewardedAt?.toIso8601String(),
      'referredRewardedAt': instance.referredRewardedAt?.toIso8601String(),
      'minOrderAmount': instance.minOrderAmount,
      'qualifyingOrderId': instance.qualifyingOrderId,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ReferralInfoModel _$ReferralInfoModelFromJson(Map<String, dynamic> json) =>
    ReferralInfoModel(
      referralCode: json['referralCode'] as String,
      referralLink: json['referralLink'] as String,
      totalReferrals: (json['totalReferrals'] as num?)?.toInt() ?? 0,
      completedReferrals: (json['completedReferrals'] as num?)?.toInt() ?? 0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      referrerRewardAmount:
          (json['referrerRewardAmount'] as num?)?.toDouble() ?? 0.0,
      referredRewardAmount:
          (json['referredRewardAmount'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      recentReferrals:
          (json['recentReferrals'] as List<dynamic>?)
              ?.map((e) => ReferralModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ReferralInfoModelToJson(ReferralInfoModel instance) =>
    <String, dynamic>{
      'referralCode': instance.referralCode,
      'referralLink': instance.referralLink,
      'totalReferrals': instance.totalReferrals,
      'completedReferrals': instance.completedReferrals,
      'totalEarned': instance.totalEarned,
      'referrerRewardAmount': instance.referrerRewardAmount,
      'referredRewardAmount': instance.referredRewardAmount,
      'minOrderAmount': instance.minOrderAmount,
      'recentReferrals': instance.recentReferrals,
    };

LoyaltyModel _$LoyaltyModelFromJson(Map<String, dynamic> json) => LoyaltyModel(
  points: (json['points'] as num?)?.toInt() ?? 0,
  tier: json['tier'] as String? ?? 'bronze',
  pointsToNextTier: (json['pointsToNextTier'] as num?)?.toInt() ?? 0,
  nextTier: json['nextTier'] as String?,
  pointsValue: (json['pointsValue'] as num?)?.toDouble() ?? 0.0,
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => LoyaltyHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LoyaltyModelToJson(LoyaltyModel instance) =>
    <String, dynamic>{
      'points': instance.points,
      'tier': instance.tier,
      'pointsToNextTier': instance.pointsToNextTier,
      'nextTier': instance.nextTier,
      'pointsValue': instance.pointsValue,
      'history': instance.history,
    };

LoyaltyHistoryItem _$LoyaltyHistoryItemFromJson(Map<String, dynamic> json) =>
    LoyaltyHistoryItem(
      points: (json['points'] as num).toInt(),
      type: json['type'] as String,
      description: json['description'] as String?,
      orderId: json['orderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LoyaltyHistoryItemToJson(LoyaltyHistoryItem instance) =>
    <String, dynamic>{
      'points': instance.points,
      'type': instance.type,
      'description': instance.description,
      'orderId': instance.orderId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
