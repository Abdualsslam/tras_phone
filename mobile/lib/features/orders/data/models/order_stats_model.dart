/// Order Stats Model - Data layer model with JSON serialization
library;

import '../../domain/entities/order_stats_entity.dart';

/// Order statistics model
class OrderStatsModel {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byPaymentStatus;
  final double totalRevenue;
  final double totalPaid;
  final double totalUnpaid;
  final int todayOrders;
  final double todayRevenue;
  final int thisMonthOrders;
  final double thisMonthRevenue;

  const OrderStatsModel({
    required this.total,
    required this.byStatus,
    required this.byPaymentStatus,
    required this.totalRevenue,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.todayOrders,
    required this.todayRevenue,
    required this.thisMonthOrders,
    required this.thisMonthRevenue,
  });

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsModel(
      total: json['total'] ?? 0,
      byStatus: Map<String, int>.from(json['byStatus'] ?? {}),
      byPaymentStatus: Map<String, int>.from(json['byPaymentStatus'] ?? {}),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalUnpaid: (json['totalUnpaid'] ?? 0).toDouble(),
      todayOrders: json['todayOrders'] ?? 0,
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      thisMonthOrders: json['thisMonthOrders'] ?? 0,
      thisMonthRevenue: (json['thisMonthRevenue'] ?? 0).toDouble(),
    );
  }

  OrderStatsEntity toEntity() {
    return OrderStatsEntity(
      total: total,
      byStatus: byStatus,
      byPaymentStatus: byPaymentStatus,
      totalRevenue: totalRevenue,
      totalPaid: totalPaid,
      totalUnpaid: totalUnpaid,
      todayOrders: todayOrders,
      todayRevenue: todayRevenue,
      thisMonthOrders: thisMonthOrders,
      thisMonthRevenue: thisMonthRevenue,
    );
  }
}
