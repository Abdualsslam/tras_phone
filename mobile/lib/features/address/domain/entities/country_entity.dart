/// Country Entity - Domain layer
library;

import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
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

  const CountryEntity({
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

  String getName(String locale) => locale == 'ar' ? nameAr : name;
  String formatPhone(String phone) => '$phoneCode$phone';

  @override
  List<Object?> get props => [id, code];
}
