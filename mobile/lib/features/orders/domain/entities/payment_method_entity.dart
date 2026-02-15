/// Payment Method Entity - Domain layer entity for payment methods
library;

/// Payment method entity
class PaymentMethodEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final String type; // cash_on_delivery, bank_transfer, wallet, credit, etc.
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  final String? logo;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic>? bankDetails;

  // Credit payment method fields
  final double? creditLimit;
  final double? creditUsed;
  final double? availableCredit;

  const PaymentMethodEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.logo,
    required this.isActive,
    required this.sortOrder,
    this.bankDetails,
    this.creditLimit,
    this.creditUsed,
    this.availableCredit,
  });

  /// Get display name based on locale
  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  /// Get description based on locale
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;

  /// Check if this is a credit payment method
  bool get isCreditMethod => type == 'credit';

  /// Convert type to OrderPaymentMethod enum
  String get orderPaymentMethodValue {
    final normalized = type.toLowerCase();

    switch (normalized) {
      case 'cod':
      case 'cash':
        return 'cash_on_delivery';
      case 'card':
        return 'credit_card';
      default:
        return normalized;
    }
  }
}
