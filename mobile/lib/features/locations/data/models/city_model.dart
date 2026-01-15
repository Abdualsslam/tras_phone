/// City Model - المدن
class CityModel {
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

  CityModel({
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

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      countryId: json['countryId'] is String
          ? json['countryId']
          : json['countryId']?['_id'] ?? '',
      shippingZoneId: json['shippingZoneId'] is String
          ? json['shippingZoneId']
          : json['shippingZoneId']?['_id'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      region: json['region'],
      regionAr: json['regionAr'],
      isActive: json['isActive'] ?? true,
      isCapital: json['isCapital'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'countryId': countryId,
      'shippingZoneId': shippingZoneId,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'region': region,
      'regionAr': regionAr,
      'isActive': isActive,
      'isCapital': isCapital,
      'displayOrder': displayOrder,
    };
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// الحصول على المنطقة حسب اللغة
  String? getRegion(String locale) => locale == 'ar' ? regionAr : region;
}
