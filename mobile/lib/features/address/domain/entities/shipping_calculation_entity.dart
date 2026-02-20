/// Shipping Calculation Entity - Domain layer
library;

import 'package:equatable/equatable.dart';

class ShippingCalculationEntity extends Equatable {
  final double baseCost;
  final double weightCost;
  final double totalCost;
  final bool isFreeShipping;
  final double? freeShippingThreshold;
  final int? estimatedDeliveryDays;
  final String zoneName;
  final String zoneNameAr;

  const ShippingCalculationEntity({
    required this.baseCost,
    required this.weightCost,
    required this.totalCost,
    required this.isFreeShipping,
    this.freeShippingThreshold,
    this.estimatedDeliveryDays,
    required this.zoneName,
    required this.zoneNameAr,
  });

  String getZoneName(String locale) => locale == 'ar' ? zoneNameAr : zoneName;

  double remainingForFreeShipping(double orderTotal) {
    if (freeShippingThreshold == null) return 0;
    final remaining = freeShippingThreshold! - orderTotal;
    return remaining > 0 ? remaining : 0;
  }

  @override
  List<Object?> get props => [totalCost, isFreeShipping, zoneName];
}
