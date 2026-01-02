# 📦 Orders Module - دليل ربط الطلبات والسلة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ السلة (Cart) - إضافة، تعديل، حذف العناصر
- ✅ الكوبونات (Coupons)
- ✅ إنشاء الطلبات (Create Orders)
- ✅ طلباتي (My Orders)
- ✅ تفاصيل الطلب (Order Details)

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒

---

## 📁 Flutter Models

### Cart Models

```dart
class Cart {
  final String id;
  final String customerId;
  final CartStatus status;
  final List<CartItem> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponId;
  final String? couponCode;
  final double couponDiscount;
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.shippingCost,
    required this.total,
    this.couponId,
    this.couponCode,
    required this.couponDiscount,
    this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      status: CartStatus.fromString(json['status']),
      items: (json['items'] as List? ?? [])
          .map((i) => CartItem.fromJson(i))
          .toList(),
      itemsCount: json['itemsCount'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      couponId: json['couponId'],
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      lastActivityAt: json['lastActivityAt'] != null 
          ? DateTime.parse(json['lastActivityAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  /// هل السلة فارغة؟
  bool get isEmpty => items.isEmpty;
  
  /// هل يوجد كوبون مطبق؟
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;
}

enum CartStatus {
  active,
  abandoned,
  converted,
  expired;
  
  static CartStatus fromString(String value) {
    return CartStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CartStatus.active,
    );
  }
}

class CartItem {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  
  // يمكن تعبئتها إذا تم populate
  Product? product;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] is String 
          ? json['productId'] 
          : json['productId']['_id'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : DateTime.now(),
      product: json['productId'] is Map 
          ? Product.fromJson(json['productId']) 
          : null,
    );
  }
}
```

### Order Models

```dart
class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final OrderStatus status;
  
  // المبالغ
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discount;
  final double couponDiscount;
  final double walletAmountUsed;
  final int loyaltyPointsUsed;
  final double loyaltyPointsValue;
  final double total;
  final double paidAmount;
  
  // الدفع
  final PaymentStatus paymentStatus;
  final OrderPaymentMethod? paymentMethod;
  
  // الشحن
  final String? shippingAddressId;
  final ShippingAddress? shippingAddress;
  final DateTime? estimatedDeliveryDate;
  
  // الكوبون
  final String? couponId;
  final String? couponCode;
  
  // المصدر
  final OrderSource source;
  
  // الملاحظات
  final String? customerNotes;
  
  // التتبع الزمني
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  // العناصر
  final List<OrderItem> items;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.discount,
    required this.couponDiscount,
    required this.walletAmountUsed,
    required this.loyaltyPointsUsed,
    required this.loyaltyPointsValue,
    required this.total,
    required this.paidAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.shippingAddressId,
    this.shippingAddress,
    this.estimatedDeliveryDate,
    this.couponId,
    this.couponCode,
    required this.source,
    this.customerNotes,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'],
      orderNumber: json['orderNumber'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      status: OrderStatus.fromString(json['status']),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      walletAmountUsed: (json['walletAmountUsed'] ?? 0).toDouble(),
      loyaltyPointsUsed: json['loyaltyPointsUsed'] ?? 0,
      loyaltyPointsValue: (json['loyaltyPointsValue'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus']),
      paymentMethod: json['paymentMethod'] != null 
          ? OrderPaymentMethod.fromString(json['paymentMethod']) 
          : null,
      shippingAddressId: json['shippingAddressId'],
      shippingAddress: json['shippingAddress'] != null 
          ? ShippingAddress.fromJson(json['shippingAddress']) 
          : null,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null 
          ? DateTime.parse(json['estimatedDeliveryDate']) 
          : null,
      couponId: json['couponId'],
      couponCode: json['couponCode'],
      source: OrderSource.fromString(json['source'] ?? 'mobile'),
      customerNotes: json['customerNotes'],
      confirmedAt: json['confirmedAt'] != null 
          ? DateTime.parse(json['confirmedAt']) 
          : null,
      shippedAt: json['shippedAt'] != null 
          ? DateTime.parse(json['shippedAt']) 
          : null,
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
      cancellationReason: json['cancellationReason'],
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItem.fromJson(i))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  /// المبلغ المتبقي
  double get remainingAmount => total - paidAmount;
  
  /// عدد العناصر
  int get itemsCount => items.length;
  
  /// هل الطلب ملغي؟
  bool get isCancelled => status == OrderStatus.cancelled;
  
  /// هل يمكن إلغاء الطلب؟
  bool get canCancel => 
      status == OrderStatus.pending || 
      status == OrderStatus.confirmed;
}
```

### Enums

```dart
/// حالات الطلب (10 حالات)
enum OrderStatus {
  pending,         // في انتظار التأكيد
  confirmed,       // تم التأكيد
  processing,      // قيد المعالجة
  readyForPickup,  // جاهز للاستلام
  shipped,         // تم الشحن
  outForDelivery,  // في الطريق للتوصيل
  delivered,       // تم التوصيل
  completed,       // مكتمل
  cancelled,       // ملغي
  refunded;        // مسترجع
  
  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'ready_for_pickup': return OrderStatus.readyForPickup;
      case 'shipped': return OrderStatus.shipped;
      case 'out_for_delivery': return OrderStatus.outForDelivery;
      case 'delivered': return OrderStatus.delivered;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }
  
  String get displayNameAr {
    switch (this) {
      case OrderStatus.pending: return 'في الانتظار';
      case OrderStatus.confirmed: return 'تم التأكيد';
      case OrderStatus.processing: return 'قيد المعالجة';
      case OrderStatus.readyForPickup: return 'جاهز للاستلام';
      case OrderStatus.shipped: return 'تم الشحن';
      case OrderStatus.outForDelivery: return 'في الطريق';
      case OrderStatus.delivered: return 'تم التوصيل';
      case OrderStatus.completed: return 'مكتمل';
      case OrderStatus.cancelled: return 'ملغي';
      case OrderStatus.refunded: return 'مسترجع';
    }
  }
  
  Color get color {
    switch (this) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.processing: return Colors.indigo;
      case OrderStatus.readyForPickup: return Colors.purple;
      case OrderStatus.shipped: return Colors.cyan;
      case OrderStatus.outForDelivery: return Colors.teal;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.completed: return Colors.green.shade700;
      case OrderStatus.cancelled: return Colors.red;
      case OrderStatus.refunded: return Colors.grey;
    }
  }
  
  /// ترتيب الحالة في الـ Timeline
  int get stepIndex {
    switch (this) {
      case OrderStatus.pending: return 0;
      case OrderStatus.confirmed: return 1;
      case OrderStatus.processing: return 2;
      case OrderStatus.readyForPickup: return 3;
      case OrderStatus.shipped: return 3;
      case OrderStatus.outForDelivery: return 4;
      case OrderStatus.delivered: return 5;
      case OrderStatus.completed: return 6;
      case OrderStatus.cancelled: return -1;
      case OrderStatus.refunded: return -1;
    }
  }
}

enum PaymentStatus {
  unpaid,
  partial,
  paid,
  refunded;
  
  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
  
  String get displayNameAr {
    switch (this) {
      case PaymentStatus.unpaid: return 'غير مدفوع';
      case PaymentStatus.partial: return 'مدفوع جزئياً';
      case PaymentStatus.paid: return 'مدفوع';
      case PaymentStatus.refunded: return 'مسترجع';
    }
  }
}

enum OrderPaymentMethod {
  cash,
  card,
  bankTransfer,
  wallet,
  credit;
  
  static OrderPaymentMethod fromString(String value) {
    switch (value) {
      case 'cash': return OrderPaymentMethod.cash;
      case 'card': return OrderPaymentMethod.card;
      case 'bank_transfer': return OrderPaymentMethod.bankTransfer;
      case 'wallet': return OrderPaymentMethod.wallet;
      case 'credit': return OrderPaymentMethod.credit;
      default: return OrderPaymentMethod.cash;
    }
  }
  
  String get value {
    switch (this) {
      case OrderPaymentMethod.cash: return 'cash';
      case OrderPaymentMethod.card: return 'card';
      case OrderPaymentMethod.bankTransfer: return 'bank_transfer';
      case OrderPaymentMethod.wallet: return 'wallet';
      case OrderPaymentMethod.credit: return 'credit';
    }
  }
  
  String get displayNameAr {
    switch (this) {
      case OrderPaymentMethod.cash: return 'كاش';
      case OrderPaymentMethod.card: return 'بطاقة';
      case OrderPaymentMethod.bankTransfer: return 'تحويل بنكي';
      case OrderPaymentMethod.wallet: return 'المحفظة';
      case OrderPaymentMethod.credit: return 'آجل';
    }
  }
}

enum OrderSource {
  web,
  mobile,
  admin,
  api;
  
  static OrderSource fromString(String value) {
    return OrderSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderSource.mobile,
    );
  }
}
```

### Other Models

```dart
class OrderItem {
  final String productId;
  final String? variantId;
  final String? sku;
  final String name;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;
  final Map<String, dynamic>? attributes;

  OrderItem({
    required this.productId,
    this.variantId,
    this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
    this.attributes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] is String 
          ? json['productId'] 
          : json['productId']['_id'],
      variantId: json['variantId'],
      sku: json['sku'],
      name: json['name'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      attributes: json['attributes'],
    );
  }
}

class ShippingAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? district;
  final String? postalCode;
  final String? notes;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.district,
    this.postalCode,
    this.notes,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      district: json['district'],
      postalCode: json['postalCode'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      if (district != null) 'district': district,
      if (postalCode != null) 'postalCode': postalCode,
      if (notes != null) 'notes': notes,
    };
  }
}
```

---

## 📞 API Endpoints

### 🛒 Cart

#### 1️⃣ جلب السلة

**Endpoint:** `GET /cart`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "customerId": "...",
    "status": "active",
    "items": [
      {
        "productId": "...",
        "quantity": 2,
        "unitPrice": 150,
        "totalPrice": 300,
        "addedAt": "2024-01-15T..."
      }
    ],
    "itemsCount": 2,
    "subtotal": 300,
    "discount": 0,
    "taxAmount": 45,
    "shippingCost": 25,
    "total": 370,
    "couponCode": null,
    "couponDiscount": 0,
    ...
  },
  "message": "Cart retrieved",
  "messageAr": "تم استرجاع السلة"
}
```

**Flutter Code:**
```dart
class CartService {
  final Dio _dio;
  
  CartService(this._dio);
  
  /// جلب السلة
  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');
    
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 2️⃣ إضافة عنصر للسلة

**Endpoint:** `POST /cart/items`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "productId": "507f1f77bcf86cd799439011",  // مطلوب
  "quantity": 2,                             // مطلوب (min: 1)
  "unitPrice": 150.00                        // مطلوب
}
```

**Response:**
```dart
{
  "success": true,
  "data": { /* Cart object محدث */ },
  "message": "Item added",
  "messageAr": "تم إضافة العنصر"
}
```

**Flutter Code:**
```dart
/// إضافة عنصر للسلة
Future<Cart> addItem({
  required String productId,
  required int quantity,
  required double unitPrice,
}) async {
  final response = await _dio.post('/cart/items', data: {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  });
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ تحديث كمية عنصر

**Endpoint:** `PUT /cart/items/:productId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "quantity": 5  // الكمية الجديدة
}
```

**Flutter Code:**
```dart
/// تحديث كمية عنصر
Future<Cart> updateItemQuantity({
  required String productId,
  required int quantity,
}) async {
  final response = await _dio.put('/cart/items/$productId', data: {
    'quantity': quantity,
  });
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 4️⃣ حذف عنصر من السلة

**Endpoint:** `DELETE /cart/items/:productId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// حذف عنصر من السلة
Future<Cart> removeItem(String productId) async {
  final response = await _dio.delete('/cart/items/$productId');
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ تفريغ السلة

**Endpoint:** `DELETE /cart`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// تفريغ السلة
Future<Cart> clearCart() async {
  final response = await _dio.delete('/cart');
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 6️⃣ تطبيق كوبون

**Endpoint:** `POST /cart/coupon`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "couponId": "507f1f77bcf...",     // اختياري
  "couponCode": "SUMMER2024",       // اختياري (أحدهما مطلوب)
  "discountAmount": 50.00           // المبلغ المخصوم
}
```

**Flutter Code:**
```dart
/// تطبيق كوبون
Future<Cart> applyCoupon({
  String? couponId,
  String? couponCode,
  required double discountAmount,
}) async {
  final response = await _dio.post('/cart/coupon', data: {
    if (couponId != null) 'couponId': couponId,
    if (couponCode != null) 'couponCode': couponCode,
    'discountAmount': discountAmount,
  });
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 7️⃣ إزالة الكوبون

**Endpoint:** `DELETE /cart/coupon`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// إزالة الكوبون
Future<Cart> removeCoupon() async {
  final response = await _dio.delete('/cart/coupon');
  
  if (response.data['success']) {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 📦 Orders

#### 8️⃣ جلب طلباتي

**Endpoint:** `GET /orders/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة (default: 1) |
| `limit` | number | ❌ | عدد النتائج (default: 20) |
| `status` | string | ❌ | فلترة بالحالة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "orderNumber": "ORD-2024-001234",
      "status": "delivered",
      "total": 1250,
      "itemsCount": 3,
      "createdAt": "2024-01-15T...",
      ...
    }
  ],
  "message": "Orders retrieved",
  "messageAr": "تم استرجاع الطلبات",
  "meta": {
    "total": 45
  }
}
```

**Flutter Code:**
```dart
class OrdersService {
  final Dio _dio;
  
  OrdersService(this._dio);
  
  /// جلب طلباتي
  Future<OrdersResponse> getMyOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  }) async {
    final response = await _dio.get('/orders/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    });
    
    if (response.data['success']) {
      return OrdersResponse(
        orders: (response.data['data'] as List)
            .map((o) => Order.fromJson(o))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
      );
    }
    throw Exception(response.data['messageAr']);
  }
}

class OrdersResponse {
  final List<Order> orders;
  final int total;
  
  OrdersResponse({required this.orders, required this.total});
}
```

---

#### 9️⃣ إنشاء طلب جديد

**Endpoint:** `POST /orders`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "shippingAddressId": "507f1f77bcf...",  // اختياري - ID عنوان محفوظ
  "shippingAddress": {                     // اختياري - أو عنوان جديد
    "fullName": "أحمد محمد",
    "phone": "+966501234567",
    "address": "شارع الملك فهد",
    "city": "الرياض",
    "district": "العليا",                  // اختياري
    "postalCode": "12345",                 // اختياري
    "notes": "بجانب البنك"                 // اختياري
  },
  "paymentMethod": "credit",               // اختياري
  "customerNotes": "يرجى التوصيل صباحاً",  // اختياري
  "couponCode": "SUMMER2024"               // اختياري
}
```

**Response (201 Created):**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "orderNumber": "ORD-2024-001235",
    "status": "pending",
    "total": 1250,
    "items": [...],
    ...
  },
  "message": "Order created",
  "messageAr": "تم إنشاء الطلب"
}
```

**Flutter Code:**
```dart
/// إنشاء طلب جديد
Future<Order> createOrder({
  String? shippingAddressId,
  ShippingAddress? shippingAddress,
  OrderPaymentMethod? paymentMethod,
  String? customerNotes,
  String? couponCode,
}) async {
  final response = await _dio.post('/orders', data: {
    if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
    if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
    if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (couponCode != null) 'couponCode': couponCode,
  });
  
  if (response.data['success']) {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 🔟 جلب تفاصيل طلب

**Endpoint:** `GET /orders/:orderId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "orderNumber": "ORD-2024-001234",
    "status": "shipped",
    "items": [
      {
        "productId": "...",
        "name": "شاشة iPhone 15 Pro",
        "quantity": 2,
        "unitPrice": 450,
        "total": 900
      }
    ],
    "subtotal": 900,
    "shippingCost": 25,
    "total": 925,
    "shippingAddress": {
      "fullName": "أحمد محمد",
      "phone": "+966501234567",
      "address": "شارع الملك فهد",
      "city": "الرياض"
    },
    "confirmedAt": "2024-01-15T10:30:00Z",
    "shippedAt": "2024-01-16T14:00:00Z",
    ...
  },
  "message": "Order retrieved",
  "messageAr": "تم استرجاع الطلب"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل طلب
Future<Order> getOrderDetails(String orderId) async {
  final response = await _dio.get('/orders/$orderId');
  
  if (response.data['success']) {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

## 🧩 الـ Services الكاملة

### CartService

```dart
import 'package:dio/dio.dart';

class CartService {
  final Dio _dio;
  
  CartService(this._dio);
  
  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> addItem({
    required String productId,
    required int quantity,
    required double unitPrice,
  }) async {
    final response = await _dio.post('/cart/items', data: {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    final response = await _dio.put('/cart/items/$productId', data: {
      'quantity': quantity,
    });
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> removeItem(String productId) async {
    final response = await _dio.delete('/cart/items/$productId');
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> clearCart() async {
    final response = await _dio.delete('/cart');
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> applyCoupon({
    String? couponCode,
    required double discountAmount,
  }) async {
    final response = await _dio.post('/cart/coupon', data: {
      if (couponCode != null) 'couponCode': couponCode,
      'discountAmount': discountAmount,
    });
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Cart> removeCoupon() async {
    final response = await _dio.delete('/cart/coupon');
    if (response.data['success']) {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
}
```

### OrdersService

```dart
import 'package:dio/dio.dart';

class OrdersService {
  final Dio _dio;
  
  OrdersService(this._dio);
  
  Future<OrdersResponse> getMyOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  }) async {
    final response = await _dio.get('/orders/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    });
    
    if (response.data['success']) {
      return OrdersResponse(
        orders: (response.data['data'] as List)
            .map((o) => Order.fromJson(o))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
      );
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Order> createOrder({
    String? shippingAddressId,
    ShippingAddress? shippingAddress,
    OrderPaymentMethod? paymentMethod,
    String? customerNotes,
    String? couponCode,
  }) async {
    final response = await _dio.post('/orders', data: {
      if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
      if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
      if (customerNotes != null) 'customerNotes': customerNotes,
      if (couponCode != null) 'couponCode': couponCode,
    });
    
    if (response.data['success']) {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Order> getOrderDetails(String orderId) async {
    final response = await _dio.get('/orders/$orderId');
    
    if (response.data['success']) {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🎯 أمثلة الاستخدام

### عرض السلة مع الـ Checkout

```dart
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? _cart;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCart();
  }
  
  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      _cart = await cartService.getCart();
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return LoadingIndicator();
    if (_cart == null || _cart!.isEmpty) return EmptyCartView();
    
    return Scaffold(
      appBar: AppBar(title: Text('السلة (${_cart!.itemsCount})')),
      body: Column(
        children: [
          // قائمة العناصر
          Expanded(
            child: ListView.builder(
              itemCount: _cart!.items.length,
              itemBuilder: (context, index) {
                final item = _cart!.items[index];
                return CartItemTile(
                  item: item,
                  onQuantityChanged: (qty) => _updateQuantity(item.productId, qty),
                  onRemove: () => _removeItem(item.productId),
                );
              },
            ),
          ),
          
          // ملخص السلة
          CartSummary(
            subtotal: _cart!.subtotal,
            discount: _cart!.discount + _cart!.couponDiscount,
            shipping: _cart!.shippingCost,
            tax: _cart!.taxAmount,
            total: _cart!.total,
            couponCode: _cart!.couponCode,
            onApplyCoupon: _applyCoupon,
            onRemoveCoupon: _removeCoupon,
          ),
          
          // زر الإتمام
          CheckoutButton(
            total: _cart!.total,
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateQuantity(String productId, int qty) async {
    _cart = await cartService.updateItemQuantity(
      productId: productId,
      quantity: qty,
    );
    setState(() {});
  }
  
  Future<void> _removeItem(String productId) async {
    _cart = await cartService.removeItem(productId);
    setState(() {});
  }
}
```

### عرض تتبع الطلب (Order Timeline)

```dart
class OrderTimelineWidget extends StatelessWidget {
  final Order order;
  
  @override
  Widget build(BuildContext context) {
    final steps = [
      TimelineStep('تم الإنشاء', order.createdAt, true),
      TimelineStep('تم التأكيد', order.confirmedAt, order.confirmedAt != null),
      TimelineStep('تم الشحن', order.shippedAt, order.shippedAt != null),
      TimelineStep('تم التوصيل', order.deliveredAt, order.deliveredAt != null),
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return TimelineTile(
          title: step.title,
          date: step.date,
          isCompleted: step.isCompleted,
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

### 🛒 Cart

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/cart` | جلب السلة |
| POST | `/cart/items` | إضافة عنصر |
| PUT | `/cart/items/:productId` | تحديث الكمية |
| DELETE | `/cart/items/:productId` | حذف عنصر |
| DELETE | `/cart` | تفريغ السلة |
| POST | `/cart/coupon` | تطبيق كوبون |
| DELETE | `/cart/coupon` | إزالة كوبون |

### 📦 Orders

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/orders/my` | طلباتي |
| POST | `/orders` | إنشاء طلب |
| GET | `/orders/:id` | تفاصيل الطلب |

---

> 🔗 **السابق:** [customers.md](./customers.md) - دليل العملاء  
> 🔗 **التالي:** [products.md](./products.md) - دليل المنتجات (قريباً)
