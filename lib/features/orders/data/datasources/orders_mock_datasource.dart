/// Orders Mock DataSource - Provides mock data for orders
library;

import '../../domain/entities/order_entity.dart';

class OrdersMockDataSource {
  // Simulated delay for network calls
  static const _delay = Duration(milliseconds: 800);

  // Mock orders database
  final List<OrderEntity> _mockOrders = [
    OrderEntity(
      id: 1,
      orderNumber: 'ORD-2024-001',
      status: OrderStatus.delivered,
      items: const [
        OrderItemEntity(
          id: 1,
          productId: 1,
          productName: 'شاشة آيفون 14 برو ماكس',
          quantity: 2,
          unitPrice: 450,
          totalPrice: 900,
        ),
        OrderItemEntity(
          id: 2,
          productId: 2,
          productName: 'بطارية آيفون 13',
          quantity: 5,
          unitPrice: 85,
          totalPrice: 425,
        ),
      ],
      subtotal: 1325,
      shippingCost: 50,
      discount: 132.5,
      total: 1242.5,
      couponCode: 'TRAS10',
      shippingAddress: 'الرياض - حي الملز - شارع الأمير سلطان',
      paymentMethod: 'الدفع عند الاستلام',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    OrderEntity(
      id: 2,
      orderNumber: 'ORD-2024-002',
      status: OrderStatus.shipped,
      items: const [
        OrderItemEntity(
          id: 3,
          productId: 3,
          productName: 'كابل شحن Type-C',
          quantity: 10,
          unitPrice: 25,
          totalPrice: 250,
        ),
      ],
      subtotal: 250,
      shippingCost: 50,
      discount: 0,
      total: 300,
      shippingAddress: 'جدة - حي الصفا',
      paymentMethod: 'المحفظة',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderEntity(
      id: 3,
      orderNumber: 'ORD-2024-003',
      status: OrderStatus.processing,
      items: const [
        OrderItemEntity(
          id: 4,
          productId: 4,
          productName: 'شاشة سامسونج S23 Ultra',
          quantity: 1,
          unitPrice: 520,
          totalPrice: 520,
        ),
      ],
      subtotal: 520,
      shippingCost: 0,
      discount: 0,
      total: 520,
      shippingAddress: 'الدمام - حي الفيصلية',
      paymentMethod: 'تحويل بنكي',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    OrderEntity(
      id: 4,
      orderNumber: 'ORD-2024-004',
      status: OrderStatus.pending,
      items: const [
        OrderItemEntity(
          id: 5,
          productId: 5,
          productName: 'بطارية سامسونج A54',
          quantity: 3,
          unitPrice: 75,
          totalPrice: 225,
        ),
      ],
      subtotal: 225,
      shippingCost: 50,
      discount: 0,
      total: 275,
      shippingAddress: 'مكة المكرمة - العزيزية',
      paymentMethod: 'الدفع عند الاستلام',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  /// Get all orders
  Future<List<OrderEntity>> getOrders({OrderStatus? status}) async {
    await Future.delayed(_delay);

    if (status != null) {
      return _mockOrders.where((order) => order.status == status).toList();
    }
    return List.from(_mockOrders);
  }

  /// Get order by ID
  Future<OrderEntity> getOrderById(int id) async {
    await Future.delayed(_delay);

    final order = _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw Exception('الطلب غير موجود'),
    );
    return order;
  }

  /// Cancel order
  Future<OrderEntity> cancelOrder(int id) async {
    await Future.delayed(_delay);

    final index = _mockOrders.indexWhere((o) => o.id == id);
    if (index < 0) {
      throw Exception('الطلب غير موجود');
    }

    final order = _mockOrders[index];
    if (order.status != OrderStatus.pending &&
        order.status != OrderStatus.confirmed) {
      throw Exception('لا يمكن إلغاء هذا الطلب');
    }

    final cancelledOrder = OrderEntity(
      id: order.id,
      orderNumber: order.orderNumber,
      status: OrderStatus.cancelled,
      items: order.items,
      subtotal: order.subtotal,
      shippingCost: order.shippingCost,
      discount: order.discount,
      total: order.total,
      couponCode: order.couponCode,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
      notes: order.notes,
      createdAt: order.createdAt,
    );

    _mockOrders[index] = cancelledOrder;
    return cancelledOrder;
  }

  /// Reorder (create new order from existing)
  Future<OrderEntity> reorder(int orderId) async {
    await Future.delayed(_delay);

    final originalOrder = _mockOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('الطلب غير موجود'),
    );

    final newOrder = OrderEntity(
      id: _mockOrders.length + 1,
      orderNumber:
          'ORD-2024-${(_mockOrders.length + 1).toString().padLeft(3, '0')}',
      status: OrderStatus.pending,
      items: originalOrder.items,
      subtotal: originalOrder.subtotal,
      shippingCost: originalOrder.shippingCost,
      discount: 0,
      total: originalOrder.subtotal + originalOrder.shippingCost,
      shippingAddress: originalOrder.shippingAddress,
      paymentMethod: originalOrder.paymentMethod,
      createdAt: DateTime.now(),
    );

    _mockOrders.insert(0, newOrder);
    return newOrder;
  }
}
