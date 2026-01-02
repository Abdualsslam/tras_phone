// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  balance: (json['balance'] as num).toDouble(),
  availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0,
  pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'SAR',
  canWithdraw: json['can_withdraw'] as bool? ?? false,
  minWithdrawal: (json['min_withdrawal'] as num?)?.toDouble() ?? 100,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'available_balance': instance.availableBalance,
      'pending_amount': instance.pendingAmount,
      'currency': instance.currency,
      'can_withdraw': instance.canWithdraw,
      'min_withdrawal': instance.minWithdrawal,
      'updated_at': instance.updatedAt,
    };

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  descriptionAr: json['description_ar'] as String?,
  referenceType: json['reference_type'] as String?,
  referenceId: (json['reference_id'] as num?)?.toInt(),
  balanceAfter: (json['balance_after'] as num).toDouble(),
  status: json['status'] as String? ?? 'completed',
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'amount': instance.amount,
  'description': instance.description,
  'description_ar': instance.descriptionAr,
  'reference_type': instance.referenceType,
  'reference_id': instance.referenceId,
  'balance_after': instance.balanceAfter,
  'status': instance.status,
  'created_at': instance.createdAt,
};

LoyaltyModel _$LoyaltyModelFromJson(Map<String, dynamic> json) => LoyaltyModel(
  points: (json['points'] as num).toInt(),
  totalEarned: (json['total_earned'] as num?)?.toInt() ?? 0,
  totalRedeemed: (json['total_redeemed'] as num?)?.toInt() ?? 0,
  pointsValue: (json['points_value'] as num?)?.toDouble() ?? 0,
  pointsPerSar: (json['points_per_sar'] as num?)?.toInt() ?? 10,
  sarPerPoint: (json['sar_per_point'] as num?)?.toDouble() ?? 0.1,
  tierName: json['tier_name'] as String?,
  nextTierName: json['next_tier_name'] as String?,
  pointsToNextTier: (json['points_to_next_tier'] as num?)?.toInt(),
);

Map<String, dynamic> _$LoyaltyModelToJson(LoyaltyModel instance) =>
    <String, dynamic>{
      'points': instance.points,
      'total_earned': instance.totalEarned,
      'total_redeemed': instance.totalRedeemed,
      'points_value': instance.pointsValue,
      'points_per_sar': instance.pointsPerSar,
      'sar_per_point': instance.sarPerPoint,
      'tier_name': instance.tierName,
      'next_tier_name': instance.nextTierName,
      'points_to_next_tier': instance.pointsToNextTier,
    };

ReferralModel _$ReferralModelFromJson(Map<String, dynamic> json) =>
    ReferralModel(
      referralCode: json['referral_code'] as String,
      referralLink: json['referral_link'] as String,
      totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
      successfulReferrals: (json['successful_referrals'] as num?)?.toInt() ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
      rewardPerReferral:
          (json['reward_per_referral'] as num?)?.toDouble() ?? 50,
    );

Map<String, dynamic> _$ReferralModelToJson(ReferralModel instance) =>
    <String, dynamic>{
      'referral_code': instance.referralCode,
      'referral_link': instance.referralLink,
      'total_referrals': instance.totalReferrals,
      'successful_referrals': instance.successfulReferrals,
      'earnings': instance.earnings,
      'reward_per_referral': instance.rewardPerReferral,
    };
