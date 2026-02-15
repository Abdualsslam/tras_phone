/// Payment Method Model - Data layer model for payment methods
library;

import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String type;
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

  const PaymentMethodModel({
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

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    // Handle nested _id in MongoDB format
    String? extractId(dynamic value) {
      if (value is String) return value;
      if (value is Map) {
        return value['_id']?.toString() ?? value['\$oid']?.toString();
      }
      return value?.toString();
    }

    return PaymentMethodModel(
      id: extractId(json['_id'] ?? json['id']) ?? '',
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      nameEn: json['nameEn'] ?? json['name'] ?? json['name_en'] ?? '',
      type: json['type'] ?? '',
      descriptionAr: json['descriptionAr'] ?? json['description_ar'],
      descriptionEn:
          json['descriptionEn'] ??
          json['description'] ??
          json['description_en'],
      icon: json['icon'],
      logo: json['logo'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      sortOrder: json['sortOrder'] ?? json['sort_order'] ?? 0,
      bankDetails: json['bankDetails'] ?? json['bank_details'],
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      creditUsed: (json['creditUsed'] as num?)?.toDouble(),
      availableCredit: (json['availableCredit'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'type': type,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'icon': icon,
    'logo': logo,
    'isActive': isActive,
    'sortOrder': sortOrder,
    'bankDetails': bankDetails,
    'creditLimit': creditLimit,
    'creditUsed': creditUsed,
    'availableCredit': availableCredit,
  };

  /// Convert to domain entity
  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      type: type,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      icon: icon,
      logo: logo,
      isActive: isActive,
      sortOrder: sortOrder,
      bankDetails: bankDetails,
      creditLimit: creditLimit,
      creditUsed: creditUsed,
      availableCredit: availableCredit,
    );
  }
}
