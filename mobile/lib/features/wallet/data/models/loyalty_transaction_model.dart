/// Loyalty Transaction Model
library;

import '../../domain/enums/wallet_enums.dart';

class LoyaltyTransaction {
  final String id;
  final String transactionNumber;
  final String customerId;
  final LoyaltyTransactionType transactionType;
  final int points;
  final PointsDirection direction;
  final int pointsBefore;
  final int pointsAfter;
  final String? referenceType;
  final String? referenceId;
  final String? referenceNumber;
  final double? orderAmount;
  final double? multiplier;
  final double? redeemedValue;
  final String? description;
  final String? descriptionAr;
  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.transactionNumber,
    required this.customerId,
    required this.transactionType,
    required this.points,
    required this.direction,
    required this.pointsBefore,
    required this.pointsAfter,
    this.referenceType,
    this.referenceId,
    this.referenceNumber,
    this.orderAmount,
    this.multiplier,
    this.redeemedValue,
    this.description,
    this.descriptionAr,
    this.expiresAt,
    required this.isExpired,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      transactionNumber: json['transactionNumber'] ?? '',
      customerId: json['customerId'] is String
          ? json['customerId']
          : json['customerId']?['_id']?.toString() ?? '',
      transactionType:
          LoyaltyTransactionType.fromString(json['transactionType'] ?? ''),
      points: json['points'] ?? 0,
      direction: PointsDirection.fromString(json['direction'] ?? ''),
      pointsBefore: json['pointsBefore'] ?? 0,
      pointsAfter: json['pointsAfter'] ?? 0,
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
      referenceNumber: json['referenceNumber'],
      orderAmount: json['orderAmount']?.toDouble(),
      multiplier: json['multiplier']?.toDouble(),
      redeemedValue: json['redeemedValue']?.toDouble(),
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isExpired: json['isExpired'] ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'transactionNumber': transactionNumber,
        'customerId': customerId,
        'transactionType': transactionType.name,
        'points': points,
        'direction': direction.name,
        'pointsBefore': pointsBefore,
        'pointsAfter': pointsAfter,
        'referenceType': referenceType,
        'referenceId': referenceId,
        'referenceNumber': referenceNumber,
        'orderAmount': orderAmount,
        'multiplier': multiplier,
        'redeemedValue': redeemedValue,
        'description': description,
        'descriptionAr': descriptionAr,
        'expiresAt': expiresAt?.toIso8601String(),
        'isExpired': isExpired,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isEarned => direction == PointsDirection.earn;

  String getDescription(String locale) =>
      locale == 'ar' ? (descriptionAr ?? description ?? '') : (description ?? '');
}
