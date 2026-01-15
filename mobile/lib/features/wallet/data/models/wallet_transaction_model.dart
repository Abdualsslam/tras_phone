/// Wallet Transaction Model (Extended)
library;

import '../../domain/enums/wallet_enums.dart';

class WalletTransaction {
  final String id;
  final String transactionNumber;
  final String customerId;
  final WalletTransactionType transactionType;
  final double amount;
  final TransactionDirection direction;
  final double balanceBefore;
  final double balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String? referenceNumber;
  final String? paymentMethod;
  final WalletTransactionStatus status;
  final String? description;
  final String? descriptionAr;
  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.transactionNumber,
    required this.customerId,
    required this.transactionType,
    required this.amount,
    required this.direction,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.referenceNumber,
    this.paymentMethod,
    required this.status,
    this.description,
    this.descriptionAr,
    this.expiresAt,
    required this.isExpired,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      transactionNumber: json['transactionNumber'] ?? '',
      customerId: json['customerId'] is String
          ? json['customerId']
          : json['customerId']?['_id']?.toString() ?? '',
      transactionType:
          WalletTransactionType.fromString(json['transactionType'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      direction: TransactionDirection.fromString(json['direction'] ?? ''),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
      referenceNumber: json['referenceNumber'],
      paymentMethod: json['paymentMethod'],
      status: WalletTransactionStatus.fromString(json['status'] ?? ''),
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
        'transactionType': transactionType.apiValue,
        'amount': amount,
        'direction': direction.name,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'referenceType': referenceType,
        'referenceId': referenceId,
        'referenceNumber': referenceNumber,
        'paymentMethod': paymentMethod,
        'status': status.name,
        'description': description,
        'descriptionAr': descriptionAr,
        'expiresAt': expiresAt?.toIso8601String(),
        'isExpired': isExpired,
        'createdAt': createdAt.toIso8601String(),
      };

  String getDescription(String locale) =>
      locale == 'ar' ? (descriptionAr ?? description ?? '') : (description ?? '');

  bool get isCredit => direction == TransactionDirection.credit;
}

class WalletBalance {
  final double balance;

  const WalletBalance({required this.balance});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'balance': balance};
}
