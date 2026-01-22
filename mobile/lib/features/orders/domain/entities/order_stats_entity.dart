/// Order Stats Entity - Domain layer representation of order statistics
library;

import 'package:equatable/equatable.dart';

/// Order statistics entity
class OrderStatsEntity extends Equatable {
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

  const OrderStatsEntity({
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

  /// Get count for a specific order status
  int getStatusCount(String status) => byStatus[status] ?? 0;

  /// Get count for a specific payment status
  int getPaymentStatusCount(String status) => byPaymentStatus[status] ?? 0;

  @override
  List<Object?> get props => [
        total,
        byStatus,
        byPaymentStatus,
        totalRevenue,
        totalPaid,
        totalUnpaid,
        todayOrders,
        todayRevenue,
        thisMonthOrders,
        thisMonthRevenue,
      ];
}
