/// Bank Account Entity - Domain layer representation of a bank account
library;

import 'package:equatable/equatable.dart';

/// Bank account entity
class BankAccountEntity extends Equatable {
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
  final String currencyCode;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final double totalReceived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccountEntity({
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

  /// Get bank name in specified locale
  String getBankName(String locale) =>
      locale == 'ar' && bankNameAr != null ? bankNameAr! : bankName;

  /// Get account name in specified locale
  String getAccountName(String locale) =>
      locale == 'ar' && accountNameAr != null ? accountNameAr! : accountName;

  /// Get display name in specified locale
  String getDisplayName(String locale) =>
      locale == 'ar' && displayNameAr != null ? displayNameAr! : displayName;

  /// Get instructions in specified locale
  String? getInstructions(String locale) =>
      locale == 'ar' && instructionsAr != null ? instructionsAr : instructions;

  @override
  List<Object?> get props => [
        id,
        bankName,
        accountNumber,
        displayName,
        isActive,
        isDefault,
      ];
}
