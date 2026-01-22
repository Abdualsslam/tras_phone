/// Bank Account Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bank_account_entity.dart';

part 'bank_account_model.g.dart';

/// Bank account model
@JsonSerializable()
class BankAccountModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  final String bankName;
  final String? bankNameAr;
  final String? bankCode;
  final String accountName;
  final String? accountNameAr;
  final String accountNumber;
  final String? iban;
  final String displayName;
  final String? displayNameAr;
  final String? logo;
  final String? instructions;
  final String? instructionsAr;
  @JsonKey(defaultValue: 'SAR')
  final String currencyCode;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isDefault;
  @JsonKey(defaultValue: 0)
  final int sortOrder;
  @JsonKey(defaultValue: 0.0)
  final double totalReceived;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccountModel({
    required this.id,
    required this.bankName,
    this.bankNameAr,
    this.bankCode,
    required this.accountName,
    this.accountNameAr,
    required this.accountNumber,
    this.iban,
    required this.displayName,
    this.displayNameAr,
    this.logo,
    this.instructions,
    this.instructionsAr,
    this.currencyCode = 'SAR',
    this.isActive = true,
    this.isDefault = false,
    this.sortOrder = 0,
    this.totalReceived = 0,
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

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      _$BankAccountModelFromJson(json);
  Map<String, dynamic> toJson() => _$BankAccountModelToJson(this);

  BankAccountEntity toEntity() {
    return BankAccountEntity(
      id: id,
      bankName: bankName,
      bankNameAr: bankNameAr,
      bankCode: bankCode,
      accountName: accountName,
      accountNameAr: accountNameAr,
      accountNumber: accountNumber,
      iban: iban,
      displayName: displayName,
      displayNameAr: displayNameAr,
      logo: logo,
      instructions: instructions,
      instructionsAr: instructionsAr,
      currencyCode: currencyCode,
      isActive: isActive,
      isDefault: isDefault,
      sortOrder: sortOrder,
      totalReceived: totalReceived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
