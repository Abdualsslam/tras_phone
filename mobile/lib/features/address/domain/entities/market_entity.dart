/// Market Entity - Domain layer
library;

import 'package:equatable/equatable.dart';

class MarketEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String cityId;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? descriptionAr;
  final List<String>? landmarks;
  final bool isActive;
  final int displayOrder;

  const MarketEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.cityId,
    this.latitude,
    this.longitude,
    this.description,
    this.descriptionAr,
    this.landmarks,
    required this.isActive,
    required this.displayOrder,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : name;
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  @override
  List<Object?> get props => [id];
}
