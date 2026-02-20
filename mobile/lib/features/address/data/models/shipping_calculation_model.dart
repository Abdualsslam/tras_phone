/// ShippingCalculation Model - نتيجة حساب الشحن
library;

import '../../domain/entities/shipping_calculation_entity.dart';

class ShippingCalculationModel {
  final double baseCost;
  final double weightCost;
  final double totalCost;
  final bool isFreeShipping;
  final double? freeShippingThreshold;
  final int? estimatedDeliveryDays;
  final String zoneName;
  final String zoneNameAr;

  ShippingCalculationModel({
    required this.baseCost,
    required this.weightCost,
    required this.totalCost,
    required this.isFreeShipping,
    this.freeShippingThreshold,
    this.estimatedDeliveryDays,
    required this.zoneName,
    required this.zoneNameAr,
  });

  factory ShippingCalculationModel.fromJson(Map<String, dynamic> json) {
    return ShippingCalculationModel(
      baseCost: (json['baseCost'] ?? 0).toDouble(),
      weightCost: (json['weightCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      isFreeShipping: json['isFreeShipping'] ?? false,
      freeShippingThreshold: json['freeShippingThreshold']?.toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'],
      zoneName: json['zoneName'] ?? '',
      zoneNameAr: json['zoneNameAr'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCost': baseCost,
      'weightCost': weightCost,
      'totalCost': totalCost,
      'isFreeShipping': isFreeShipping,
      'freeShippingThreshold': freeShippingThreshold,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'zoneName': zoneName,
      'zoneNameAr': zoneNameAr,
    };
  }

  /// الحصول على اسم المنطقة حسب اللغة
  String getZoneName(String locale) => locale == 'ar' ? zoneNameAr : zoneName;

  ShippingCalculationEntity toEntity() => ShippingCalculationEntity(
        baseCost: baseCost,
        weightCost: weightCost,
        totalCost: totalCost,
        isFreeShipping: isFreeShipping,
        freeShippingThreshold: freeShippingThreshold,
        estimatedDeliveryDays: estimatedDeliveryDays,
        zoneName: zoneName,
        zoneNameAr: zoneNameAr,
      );
}
