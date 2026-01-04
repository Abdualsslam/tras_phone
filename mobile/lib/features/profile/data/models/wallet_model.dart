/// Wallet Model - Data layer model for customer wallet
library;

import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final double balance;
  @JsonKey(defaultValue: 0.0)
  final double availableBalance;
  @JsonKey(defaultValue: 0.0)
  final double pendingAmount;
  @JsonKey(defaultValue: 'SAR')
  final String currency;
  @JsonKey(defaultValue: false)
  final bool canWithdraw;
  @JsonKey(defaultValue: 100.0)
  final double minWithdrawal;
  final DateTime? updatedAt;

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
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  final String type; // 'credit', 'debit'
  final double amount;
  final String description;
  final String? descriptionAr;
  final String? referenceType;
  final String? referenceId;
  @JsonKey(defaultValue: 0.0)
  final double balanceAfter;
  @JsonKey(defaultValue: 'completed')
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;

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

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTransactionModelToJson(this);

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  String getDescription(String locale) =>
      locale == 'ar' && descriptionAr != null ? descriptionAr! : description;
}
