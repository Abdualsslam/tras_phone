// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankAccountModel _$BankAccountModelFromJson(Map<String, dynamic> json) =>
    BankAccountModel(
      id: BankAccountModel._readId(json, 'id') as String,
      bankName: json['bankName'] as String,
      bankNameAr: json['bankNameAr'] as String?,
      bankCode: json['bankCode'] as String?,
      accountName: json['accountName'] as String,
      accountNameAr: json['accountNameAr'] as String?,
      accountNumber: json['accountNumber'] as String,
      iban: json['iban'] as String?,
      displayName: json['displayName'] as String,
      displayNameAr: json['displayNameAr'] as String?,
      logo: json['logo'] as String?,
      instructions: json['instructions'] as String?,
      instructionsAr: json['instructionsAr'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'SAR',
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      totalReceived: (json['totalReceived'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BankAccountModelToJson(BankAccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bankName': instance.bankName,
      'bankNameAr': instance.bankNameAr,
      'bankCode': instance.bankCode,
      'accountName': instance.accountName,
      'accountNameAr': instance.accountNameAr,
      'accountNumber': instance.accountNumber,
      'iban': instance.iban,
      'displayName': instance.displayName,
      'displayNameAr': instance.displayNameAr,
      'logo': instance.logo,
      'instructions': instance.instructions,
      'instructionsAr': instance.instructionsAr,
      'currencyCode': instance.currencyCode,
      'isActive': instance.isActive,
      'isDefault': instance.isDefault,
      'sortOrder': instance.sortOrder,
      'totalReceived': instance.totalReceived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
