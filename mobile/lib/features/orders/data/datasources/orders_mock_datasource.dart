/// Orders Mock DataSource - Provides mock data for orders
library;

import '../../domain/entities/order_entity.dart';
import '../../domain/enums/order_enums.dart';

class OrdersMockDataSource {
  // Simulated delay for network calls
  static const _delay = Duration(milliseconds: 800);

  // Mock orders database
  final List<OrderEntity> _mockOrders = [
    OrderEntity(
      id: 'order_001',
      orderNumber: 'ORD-2024-001',
      customerId: 'customer_001',
      status: OrderStatus.delivered,
      items: const [
        OrderItemEntity(
          productId: 'prod_001',
          name: 'شاشة آيفون 14 برو ماكس',
          quantity: 2,
          unitPrice: 450,
          total: 900,
        ),
        OrderItemEntity(
          productId: 'prod_002',
          name: 'بطارية آيفون 13',
          quantity: 5,
          unitPrice: 85,
          total: 425,
        ),
      ],
      subtotal: 1325,
      shippingCost: 50,
      discount: 132.5,
      total: 1242.5,
      couponCode: 'TRAS10',
      shippingAddress: const ShippingAddressEntity(
        fullName: 'أحمد محمد',
        phone: '+966501234567',
        address: 'شارع الأمير سلطان',
        city: 'الرياض',
        district: 'حي الملز',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    OrderEntity(
      id: 'order_002',
      orderNumber: 'ORD-2024-002',
      customerId: 'customer_001',
      status: OrderStatus.shipped,
      items: const [
        OrderItemEntity(
          productId: 'prod_003',
          name: 'كابل شحن Type-C',
          quantity: 10,
          unitPrice: 25,
          total: 250,
        ),
      ],
      subtotal: 250,
      shippingCost: 50,
      discount: 0,
      total: 300,
      shippingAddress: const ShippingAddressEntity(
        fullName: 'أحمد محمد',
        phone: '+966501234567',
        address: 'شارع الملك عبدالعزيز',
        city: 'جدة',
        district: 'حي الصفا',
      ),
      paymentMethod: OrderPaymentMethod.wallet,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderEntity(
      id: 'order_003',
      orderNumber: 'ORD-2024-003',
      customerId: 'customer_001',
      status: OrderStatus.processing,
      items: const [
        OrderItemEntity(
          productId: 'prod_004',
          name: 'شاشة سامسونج S23 Ultra',
          quantity: 1,
          unitPrice: 520,
          total: 520,
        ),
      ],
      subtotal: 520,
      shippingCost: 0,
      discount: 0,
      total: 520,
      shippingAddress: const ShippingAddressEntity(
        fullName: 'أحمد محمد',
        phone: '+966501234567',
        address: 'شارع الأمير محمد',
        city: 'الدمام',
        district: 'حي الفيصلية',
      ),
      paymentMethod: OrderPaymentMethod.bankTransfer,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    OrderEntity(
      id: 'order_004',
      orderNumber: 'ORD-2024-004',
      customerId: 'customer_001',
      status: OrderStatus.pending,
      items: const [
        OrderItemEntity(
          productId: 'prod_005',
          name: 'بطارية سامسونج A54',
          quantity: 3,
          unitPrice: 75,
          total: 225,
        ),
      ],
      subtotal: 225,
      shippingCost: 50,
      discount: 0,
      total: 275,
      shippingAddress: const ShippingAddressEntity(
        fullName: 'أحمد محمد',
        phone: '+966501234567',
        address: 'شارع العزيزية',
        city: 'مكة المكرمة',
        district: 'العزيزية',
      ),
      paymentMethod: OrderPaymentMethod.cash,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
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
  Future<OrderEntity> getOrderById(String id) async {
    await Future.delayed(_delay);

    final order = _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw Exception('الطلب غير موجود'),
    );
    return order;
  }

  /// Cancel order
  Future<OrderEntity> cancelOrder(String id) async {
    await Future.delayed(_delay);

    final index = _mockOrders.indexWhere((o) => o.id == id);
    if (index < 0) {
      throw Exception('الطلب غير موجود');
    }

    final order = _mockOrders[index];
    if (!order.canCancel) {
      throw Exception('لا يمكن إلغاء هذا الطلب');
    }

    final cancelledOrder = OrderEntity(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      status: OrderStatus.cancelled,
      items: order.items,
      subtotal: order.subtotal,
      shippingCost: order.shippingCost,
      discount: order.discount,
      total: order.total,
      couponCode: order.couponCode,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
      customerNotes: order.customerNotes,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      cancelledAt: DateTime.now(),
      cancellationReason: 'إلغاء من قبل العميل',
    );

    _mockOrders[index] = cancelledOrder;
    return cancelledOrder;
  }

  /// Reorder (create new order from existing)
  Future<OrderEntity> reorder(String orderId) async {
    await Future.delayed(_delay);

    final originalOrder = _mockOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('الطلب غير موجود'),
    );

    final newOrderNumber = _mockOrders.length + 1;
    final newOrder = OrderEntity(
      id: 'order_${newOrderNumber.toString().padLeft(3, '0')}',
      orderNumber: 'ORD-2024-${newOrderNumber.toString().padLeft(3, '0')}',
      customerId: originalOrder.customerId,
      status: OrderStatus.pending,
      items: originalOrder.items,
      subtotal: originalOrder.subtotal,
      shippingCost: originalOrder.shippingCost,
      discount: 0,
      total: originalOrder.subtotal + originalOrder.shippingCost,
      shippingAddress: originalOrder.shippingAddress,
      paymentMethod: originalOrder.paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockOrders.insert(0, newOrder);
    return newOrder;
  }
}
