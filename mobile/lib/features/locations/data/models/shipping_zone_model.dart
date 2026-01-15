/// ShippingZone Model - مناطق الشحن
class ShippingZoneModel {
  final String id;
  final String name;
  final String nameAr;
  final String countryId;
  final double baseCost;
  final double costPerKg;
  final double? freeShippingThreshold;
  final int? estimatedDeliveryDays;
  final int? minDeliveryDays;
  final int? maxDeliveryDays;
  final bool isActive;

  ShippingZoneModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.countryId,
    required this.baseCost,
    required this.costPerKg,
    this.freeShippingThreshold,
    this.estimatedDeliveryDays,
    this.minDeliveryDays,
    this.maxDeliveryDays,
    required this.isActive,
  });

  factory ShippingZoneModel.fromJson(Map<String, dynamic> json) {
    return ShippingZoneModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      countryId: json['countryId'] is String
          ? json['countryId']
          : json['countryId']?['_id'] ?? '',
      baseCost: (json['baseCost'] ?? 0).toDouble(),
      costPerKg: (json['costPerKg'] ?? 0).toDouble(),
      freeShippingThreshold: json['freeShippingThreshold']?.toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'],
      minDeliveryDays: json['minDeliveryDays'],
      maxDeliveryDays: json['maxDeliveryDays'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'countryId': countryId,
      'baseCost': baseCost,
      'costPerKg': costPerKg,
      'freeShippingThreshold': freeShippingThreshold,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'minDeliveryDays': minDeliveryDays,
      'maxDeliveryDays': maxDeliveryDays,
      'isActive': isActive,
    };
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// حساب تكلفة الشحن
  double calculateShippingCost(double weight, double orderTotal) {
    if (freeShippingThreshold != null && orderTotal >= freeShippingThreshold!) {
      return 0;
    }
    return baseCost + (weight * costPerKg);
  }

  /// نص وقت التوصيل
  String getDeliveryText(String locale) {
    if (minDeliveryDays != null && maxDeliveryDays != null) {
      return locale == 'ar'
          ? '$minDeliveryDays - $maxDeliveryDays أيام'
          : '$minDeliveryDays - $maxDeliveryDays days';
    }
    if (estimatedDeliveryDays != null) {
      return locale == 'ar'
          ? '$estimatedDeliveryDays أيام'
          : '$estimatedDeliveryDays days';
    }
    return '';
  }
}
