/// Referral Model - Data layer model for referral system
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/customer_enums.dart';

part 'referral_model.g.dart';

@JsonSerializable()
class ReferralModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'referrerId', readValue: _readNestedId)
  final String referrerId;

  @JsonKey(name: 'referredId', readValue: _readNestedId)
  final String referredId;

  final String referralCode;

  @JsonKey(defaultValue: 'pending')
  final String status;

  final double? referrerRewardAmount;
  final double? referredRewardAmount;
  final DateTime? referrerRewardedAt;
  final DateTime? referredRewardedAt;
  final double? minOrderAmount;
  final String? qualifyingOrderId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    this.status = 'pending',
    this.referrerRewardAmount,
    this.referredRewardAmount,
    this.referrerRewardedAt,
    this.referredRewardedAt,
    this.minOrderAmount,
    this.qualifyingOrderId,
    this.expiresAt,
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

  /// Handle nested ID fields
  static Object? _readNestedId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReferralModelToJson(this);

  ReferralStatus get statusEnum => ReferralStatus.fromString(status);

  /// Is the referral still active?
  bool get isActive =>
      statusEnum == ReferralStatus.pending &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

/// Referral info response (for customer's own referral)
@JsonSerializable()
class ReferralInfoModel {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int completedReferrals;
  final double totalEarned;
  final double referrerRewardAmount;
  final double referredRewardAmount;
  final double minOrderAmount;
  final List<ReferralModel> recentReferrals;

  const ReferralInfoModel({
    required this.referralCode,
    required this.referralLink,
    this.totalReferrals = 0,
    this.completedReferrals = 0,
    this.totalEarned = 0.0,
    this.referrerRewardAmount = 0.0,
    this.referredRewardAmount = 0.0,
    this.minOrderAmount = 0.0,
    this.recentReferrals = const [],
  });

  factory ReferralInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReferralInfoModelToJson(this);
}

/// Loyalty model for loyalty points and tier
@JsonSerializable()
class LoyaltyModel {
  final int points;
  @JsonKey(defaultValue: 'bronze')
  final String tier;
  final int pointsToNextTier;
  final String? nextTier;
  final double pointsValue;
  final List<LoyaltyHistoryItem> history;

  const LoyaltyModel({
    this.points = 0,
    this.tier = 'bronze',
    this.pointsToNextTier = 0,
    this.nextTier,
    this.pointsValue = 0.0,
    this.history = const [],
  });

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyModelToJson(this);

  LoyaltyTier get tierEnum => LoyaltyTier.fromString(tier);
}

@JsonSerializable()
class LoyaltyHistoryItem {
  final int points;
  final String type; // 'earned', 'redeemed', 'expired'
  final String? description;
  final String? orderId;
  final DateTime createdAt;

  const LoyaltyHistoryItem({
    required this.points,
    required this.type,
    this.description,
    this.orderId,
    required this.createdAt,
  });

  factory LoyaltyHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyHistoryItemToJson(this);
}
