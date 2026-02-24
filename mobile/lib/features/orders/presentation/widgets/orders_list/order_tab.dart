import '../../../domain/entities/order_entity.dart';

class OrderTab {
  final String label;
  final OrderStatus? status;
  final bool isPendingPayment;

  const OrderTab({
    required this.label,
    this.status,
    this.isPendingPayment = false,
  });
}
