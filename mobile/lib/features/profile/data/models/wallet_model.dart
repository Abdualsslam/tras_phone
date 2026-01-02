/// Wallet Model - Data layer model for customer wallet
library;

import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final double balance;
  @JsonKey(name: 'available_balance')
  final double availableBalance;
  @JsonKey(name: 'pending_amount')
  final double pendingAmount;
  final String currency;
  @JsonKey(name: 'can_withdraw')
  final bool canWithdraw;
  @JsonKey(name: 'min_withdrawal')
  final double minWithdrawal;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const WalletModel({
    required this.balance,
    this.availableBalance = 0,
    this.pendingAmount = 0,
    this.currency = 'SAR',
    this.canWithdraw = false,
    this.minWithdrawal = 100,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}

/// Wallet Transaction Model
@JsonSerializable()
class WalletTransactionModel {
  final int id;
  final String type; // 'credit', 'debit'
  final double amount;
  final String description;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  @JsonKey(name: 'reference_id')
  final int? referenceId;
  @JsonKey(name: 'balance_after')
  final double balanceAfter;
  final String status; // 'pending', 'completed', 'failed'
  @JsonKey(name: 'created_at')
  final String createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.descriptionAr,
    this.referenceType,
    this.referenceId,
    required this.balanceAfter,
    this.status = 'completed',
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTransactionModelToJson(this);

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
}

/// Loyalty Points Model
@JsonSerializable()
class LoyaltyModel {
  final int points;
  @JsonKey(name: 'total_earned')
  final int totalEarned;
  @JsonKey(name: 'total_redeemed')
  final int totalRedeemed;
  @JsonKey(name: 'points_value')
  final double pointsValue;
  @JsonKey(name: 'points_per_sar')
  final int pointsPerSar;
  @JsonKey(name: 'sar_per_point')
  final double sarPerPoint;
  @JsonKey(name: 'tier_name')
  final String? tierName;
  @JsonKey(name: 'next_tier_name')
  final String? nextTierName;
  @JsonKey(name: 'points_to_next_tier')
  final int? pointsToNextTier;

  const LoyaltyModel({
    required this.points,
    this.totalEarned = 0,
    this.totalRedeemed = 0,
    this.pointsValue = 0,
    this.pointsPerSar = 10,
    this.sarPerPoint = 0.1,
    this.tierName,
    this.nextTierName,
    this.pointsToNextTier,
  });

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyModelToJson(this);
}

/// Referral Model
@JsonSerializable()
class ReferralModel {
  @JsonKey(name: 'referral_code')
  final String referralCode;
  @JsonKey(name: 'referral_link')
  final String referralLink;
  @JsonKey(name: 'total_referrals')
  final int totalReferrals;
  @JsonKey(name: 'successful_referrals')
  final int successfulReferrals;
  @JsonKey(name: 'earnings')
  final double earnings;
  @JsonKey(name: 'reward_per_referral')
  final double rewardPerReferral;

  const ReferralModel({
    required this.referralCode,
    required this.referralLink,
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.earnings = 0,
    this.rewardPerReferral = 50,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReferralModelToJson(this);
}
