/// Market Model - الأسواق/الأحياء
library;

import '../../domain/entities/market_entity.dart';

class MarketModel {
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

  MarketModel({
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

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      cityId: json['cityId'] is String
          ? json['cityId']
          : json['cityId']?['_id'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      landmarks: json['landmarks'] != null
          ? List<String>.from(json['landmarks'])
          : null,
      isActive: json['isActive'] ?? true,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'cityId': cityId,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'descriptionAr': descriptionAr,
      'landmarks': landmarks,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  MarketEntity toEntity() => MarketEntity(
        id: id,
        name: name,
        nameAr: nameAr,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
        description: description,
        descriptionAr: descriptionAr,
        landmarks: landmarks,
        isActive: isActive,
        displayOrder: displayOrder,
      );
}
