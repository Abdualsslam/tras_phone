/// City Entity - Domain layer
library;

import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String countryId;
  final String shippingZoneId;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final String? region;
  final String? regionAr;
  final bool isActive;
  final bool isCapital;
  final int displayOrder;

  const CityEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.countryId,
    required this.shippingZoneId,
    this.latitude,
    this.longitude,
    this.timezone,
    this.region,
    this.regionAr,
    required this.isActive,
    required this.isCapital,
    required this.displayOrder,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : name;
  String? getRegion(String locale) => locale == 'ar' ? regionAr : region;

  @override
  List<Object?> get props => [id];
}
