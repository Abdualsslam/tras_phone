// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  balance: (json['balance'] as num).toDouble(),
  availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
  pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'SAR',
  canWithdraw: json['canWithdraw'] as bool? ?? false,
  minWithdrawal: (json['minWithdrawal'] as num?)?.toDouble() ?? 100.0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'availableBalance': instance.availableBalance,
      'pendingAmount': instance.pendingAmount,
      'currency': instance.currency,
      'canWithdraw': instance.canWithdraw,
      'minWithdrawal': instance.minWithdrawal,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: WalletTransactionModel._readId(json, 'id') as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  descriptionAr: json['descriptionAr'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: json['referenceId'] as String?,
  balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
  status: json['status'] as String? ?? 'completed',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'amount': instance.amount,
  'description': instance.description,
  'descriptionAr': instance.descriptionAr,
  'referenceType': instance.referenceType,
  'referenceId': instance.referenceId,
  'balanceAfter': instance.balanceAfter,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
};
