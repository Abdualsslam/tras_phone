part of 'order_model.dart';

class CreateOrderRequest {
  final String? shippingAddressId;
  final ShippingAddressModel? shippingAddress;
  final String? paymentMethod;
  final String? customerNotes;
  final String? couponCode;

  const CreateOrderRequest({
    this.shippingAddressId,
    this.shippingAddress,
    this.paymentMethod,
    this.customerNotes,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
    if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
    if (shippingAddress != null) 'shippingAddress': shippingAddress!.toJson(),
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (couponCode != null) 'couponCode': couponCode,
  };
}

class OrdersResponse {
  final List<OrderModel> orders;
  final int total;

  OrdersResponse({required this.orders, required this.total});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['data'] as List? ?? [])
          .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
          .toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }

  List<OrderEntity> toEntities() =>
      orders.map((order) => order.toEntity()).toList();
}
