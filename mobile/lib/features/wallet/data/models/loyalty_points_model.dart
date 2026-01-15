/// Loyalty Points Model
library;

import 'loyalty_tier_model.dart';

class ExpiringPoints {
  final int remainingPoints;
  final DateTime expiresAt;

  const ExpiringPoints({
    required this.remainingPoints,
    required this.expiresAt,
  });

  factory ExpiringPoints.fromJson(Map<String, dynamic> json) {
    return ExpiringPoints(
      remainingPoints: json['remainingPoints'] ?? 0,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'remainingPoints': remainingPoints,
        'expiresAt': expiresAt.toIso8601String(),
      };

  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;
}

class LoyaltyPoints {
  final int points;
  final LoyaltyTier tier;
  final List<ExpiringPoints> expiringPoints;
  final int expiringTotal;

  const LoyaltyPoints({
    required this.points,
    required this.tier,
    required this.expiringPoints,
    required this.expiringTotal,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      points: json['points'] ?? 0,
      tier: LoyaltyTier.fromJson(json['tier'] ?? {}),
      expiringPoints: (json['expiringPoints'] as List? ?? [])
          .map((e) => ExpiringPoints.fromJson(e))
          .toList(),
      expiringTotal: json['expiringTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points,
        'tier': tier.toJson(),
        'expiringPoints': expiringPoints.map((e) => e.toJson()).toList(),
        'expiringTotal': expiringTotal,
      };

  LoyaltyPoints copyWith({
    int? points,
    LoyaltyTier? tier,
    List<ExpiringPoints>? expiringPoints,
    int? expiringTotal,
  }) {
    return LoyaltyPoints(
      points: points ?? this.points,
      tier: tier ?? this.tier,
      expiringPoints: expiringPoints ?? this.expiringPoints,
      expiringTotal: expiringTotal ?? this.expiringTotal,
    );
  }
}
