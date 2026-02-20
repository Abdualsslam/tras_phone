/// Country Model - الدول
library;

import '../../domain/entities/country_entity.dart';

class CountryModel {
  final String id;
  final String name;
  final String nameAr;
  final String code;
  final String code3;
  final String phoneCode;
  final String currency;
  final String? flag;
  final bool isActive;
  final bool isDefault;

  CountryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    required this.code3,
    required this.phoneCode,
    required this.currency,
    this.flag,
    required this.isActive,
    required this.isDefault,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      code: json['code'] ?? '',
      code3: json['code3'] ?? '',
      phoneCode: json['phoneCode'] ?? '',
      currency: json['currency'] ?? 'SAR',
      flag: json['flag'],
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'code': code,
      'code3': code3,
      'phoneCode': phoneCode,
      'currency': currency,
      'flag': flag,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// تنسيق رقم الهاتف
  String formatPhone(String phone) => '$phoneCode$phone';

  CountryEntity toEntity() => CountryEntity(
        id: id,
        name: name,
        nameAr: nameAr,
        code: code,
        code3: code3,
        phoneCode: phoneCode,
        currency: currency,
        flag: flag,
        isActive: isActive,
        isDefault: isDefault,
      );
}
