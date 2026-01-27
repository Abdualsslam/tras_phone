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
    // Ensure id is always a String (MongoDB ObjectId)
    final idValue = json['_id'] ?? json['id'];
    final id = idValue != null ? idValue.toString() : '';
    
    // Extract countryId - can be from 'countryId' field or 'country._id'
    final countryId = json['countryId'] is String
        ? json['countryId']
        : json['country'] is Map
            ? (json['country']?['_id'] ?? json['country']?['id'] ?? '')
            : json['countryId']?['_id'] ?? '';
    
    // Extract name - can be 'name' or 'nameEn'
    final name = json['name'] ?? json['nameEn'] ?? '';
    
    // Extract shippingZoneId - can be missing, use empty string as default
    final shippingZoneIdValue = json['shippingZoneId'];
    final shippingZoneId = shippingZoneIdValue is String
        ? shippingZoneIdValue
        : shippingZoneIdValue is Map
            ? (shippingZoneIdValue['_id'] ?? shippingZoneIdValue['id'] ?? '')
            : '';
    
    // Extract displayOrder - can be 'displayOrder' or 'sortOrder'
    final displayOrder = json['displayOrder'] ?? json['sortOrder'] ?? 0;
    
    // Determine if capital - only use the value from API, don't assume
    final isCapitalValue = json['isCapital'];
    final isCapital = isCapitalValue is bool && isCapitalValue == true;
    
    return CityModel(
      id: id,
      name: name,
      nameAr: json['nameAr'] ?? '',
      countryId: countryId,
      shippingZoneId: shippingZoneId,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      region: json['region'],
      regionAr: json['regionAr'],
      isActive: json['isActive'] ?? true,
      isCapital: isCapital,
      displayOrder: displayOrder is int ? displayOrder : (displayOrder as num?)?.toInt() ?? 0,
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
