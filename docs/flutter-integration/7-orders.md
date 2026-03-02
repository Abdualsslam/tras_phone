# 📦 Orders Module - دليل ربط الطلبات والسلة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:

- ✅ السلة (Cart) - إضافة، تعديل، حذف العناصر
- ✅ السلة المحلية (Local Cart) - عمليات فورية بدون انتظار السيرفر
- ✅ مزامنة السلة (Cart Sync) - التحقق من المخزون والأسعار قبل الدفع
- ✅ **قواعد التسعير** - السيرفر يحسب السعر حسب مستوى العميل، والطلبات تحتوي `priceLevelId` (انظر [16-pricing-rules.md](./16-pricing-rules.md))
- ✅ الكوبونات (Coupons) - يمكن تطبيقها على السلة (`/cart/coupon`) أو مباشرة عند إنشاء الطلب (`/orders`)
- ✅ إنشاء الطلبات (Create Orders)
- ✅ طلباتي (My Orders)
- ✅ تفاصيل الطلب (Order Details)

> **ملاحظة مهمة**: النظام يستخدم **السلة المحلية** للعمليات اليومية (إضافة، تعديل، حذف) مما يوفر تجربة مستخدم فورية. يتم المزامنة مع السيرفر فقط عند الحاجة (قبل الدفع).

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒 ما عدا `GET /bank-accounts` (Public)

> 📚 **للمزيد من التفاصيل عن السلة المحلية والمزامنة**: راجع [Local Cart Module](./local-cart.md)

### شكل الاستجابة من الباك-إند

كل endpoints في النظام ترجع الهيكل الموحد التالي:

```json
{
  "status": "success",
  "statusCode": 200,
  "message": "...",
  "messageAr": "...",
  "data": {},
  "meta": {}
}
```

> **ملاحظة ضريبية:** `taxAmount` في Cart/Order قيمة راجعة من السيرفر. لا تعِد حسابها في التطبيق.

> **مهم**: لا تعتمد على `success: true` في Flutter. اعتمد على `status == 'success'` أو مباشرة على `response.data['data']` مع معالجة الأخطاء من Dio.

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
  /// مستوى السعر المُستخدم عند إنشاء الطلب (اختياري)
  final String? priceLevelId;
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

  // التحويل البنكي
  final String? transferStatus; // not_required, awaiting_receipt, receipt_uploaded, verified, rejected
  final String? transferReceiptImage;
  final String? transferReference;
  final DateTime? transferDate;
  final String? rejectionReason;

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

  // التقييم
  final int? customerRating; // 1-5
  final String? customerRatingComment;
  final DateTime? ratedAt;

  // العناصر
  final List<OrderItem> items;

  /// هل يمكن إلغاء الطلب؟ (يأتي من الـ API - true فقط عند pending, confirmed, processing)
  final bool cancellable;

  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.priceLevelId,
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
    this.transferStatus,
    this.transferReceiptImage,
    this.transferReference,
    this.transferDate,
    this.rejectionReason,
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
    this.customerRating,
    this.customerRatingComment,
    this.ratedAt,
    required this.items,
    this.cancellable = false,
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
      priceLevelId: json['priceLevelId']?.toString(),
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
      transferStatus: json['transferStatus']?.toString(),
      transferReceiptImage: json['transferReceiptImage'],
      transferReference: json['transferReference'],
      transferDate: json['transferDate'] != null
          ? DateTime.parse(json['transferDate'])
          : null,
      rejectionReason: json['rejectionReason'],
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
      customerRating: json['customerRating'],
      customerRatingComment: json['customerRatingComment'],
      ratedAt: json['ratedAt'] != null
          ? DateTime.parse(json['ratedAt'])
          : null,
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItem.fromJson(i))
          .toList(),
      cancellable: json['cancellable'] as bool? ?? false,
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

  /// هل يمكن إلغاء الطلب؟ (يأتي من الـ API - true فقط عند pending, confirmed, processing)
  bool get canCancel => cancellable;

  /// هل تم تقييم الطلب؟
  bool get isRated => customerRating != null && customerRating! > 0;

  /// هل يمكن تقييم الطلب؟
  bool get canRate =>
      (status == OrderStatus.delivered || status == OrderStatus.completed) &&
      !isRated;
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

  String get value {
    switch (this) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.confirmed: return 'confirmed';
      case OrderStatus.processing: return 'processing';
      case OrderStatus.readyForPickup: return 'ready_for_pickup';
      case OrderStatus.shipped: return 'shipped';
      case OrderStatus.outForDelivery: return 'out_for_delivery';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.completed: return 'completed';
      case OrderStatus.cancelled: return 'cancelled';
      case OrderStatus.refunded: return 'refunded';
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
  cashOnDelivery,
  creditCard,
  mada,
  applePay,
  stcPay,
  bankTransfer,
  wallet,
  credit;

  static OrderPaymentMethod fromString(String value) {
    switch (value) {
      case 'cash_on_delivery':
      case 'cash':
      case 'cod':
        return OrderPaymentMethod.cashOnDelivery;
      case 'credit_card':
      case 'card':
        return OrderPaymentMethod.creditCard;
      case 'mada':
        return OrderPaymentMethod.mada;
      case 'apple_pay':
        return OrderPaymentMethod.applePay;
      case 'stc_pay':
        return OrderPaymentMethod.stcPay;
      case 'bank_transfer': return OrderPaymentMethod.bankTransfer;
      case 'wallet': return OrderPaymentMethod.wallet;
      case 'credit': return OrderPaymentMethod.credit;
      default: return OrderPaymentMethod.bankTransfer;
    }
  }

  String get value {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery: return 'cash_on_delivery';
      case OrderPaymentMethod.creditCard: return 'credit_card';
      case OrderPaymentMethod.mada: return 'mada';
      case OrderPaymentMethod.applePay: return 'apple_pay';
      case OrderPaymentMethod.stcPay: return 'stc_pay';
      case OrderPaymentMethod.bankTransfer: return 'bank_transfer';
      case OrderPaymentMethod.wallet: return 'wallet';
      case OrderPaymentMethod.credit: return 'credit';
    }
  }

  String get displayNameAr {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery: return 'الدفع عند الاستلام';
      case OrderPaymentMethod.creditCard: return 'بطاقة ائتمانية';
      case OrderPaymentMethod.mada: return 'مدى';
      case OrderPaymentMethod.applePay: return 'Apple Pay';
      case OrderPaymentMethod.stcPay: return 'STC Pay';
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

  String get value {
    return name;
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
  "status": "success",
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

> **ملاحظة خصومات:** في سلة الباك-إند الحالية، الحقل `discount` يعكس قيمة الكوبون نفسها (`couponDiscount`) داخل cart totals. في الطلب (`Order`) ستجد `discount` و `couponDiscount` كحقول منفصلة.

**Flutter Code:**

```dart
class CartService {
  final Dio _dio;

  CartService(this._dio);

  /// جلب السلة
  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');

    if (response.data['status'] == 'success') {
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
  "unitPrice": 150.00                        // اختياري - يُتجاهل، السيرفر يحسب السعر من مستوى العميل
}
```

> **ملاحظة**: `unitPrice` أصبح اختيارياً - السيرفر يحسب السعر الصحيح حسب مستوى العميل. انظر [16-pricing-rules.md](./16-pricing-rules.md)

**Response:**

```dart
{
  "status": "success",
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
  double? unitPrice,
}) async {
  final response = await _dio.post('/cart/items', data: {
    'productId': productId,
    'quantity': quantity,
    if (unitPrice != null) 'unitPrice': unitPrice,
  });

  if (response.data['status'] == 'success') {
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

  if (response.data['status'] == 'success') {
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

  if (response.data['status'] == 'success') {
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

  if (response.data['status'] == 'success') {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

---

#### 6️⃣ تطبيق كوبون على السلة

**Endpoint:** `POST /cart/coupon`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**

```dart
{
  "couponCode": "SUMMER2024",        // مطلوب
  "couponId": "507f1f77bcf...",      // اختياري
  "discountAmount": 50.00             // مطلوب - قيمة الخصم
}
```

**Response:**

```dart
{
  "status": "success",
  "data": { /* Cart object محدث */ },
  "message": "Coupon applied",
  "messageAr": "تم تطبيق الكوبون"
}
```

**Flutter Code:**

```dart
/// تطبيق كوبون على السلة
Future<Cart> applyCoupon({
  required String couponCode,
  String? couponId,
  required double discountAmount,
}) async {
  final response = await _dio.post('/cart/coupon', data: {
    'couponCode': couponCode,
    if (couponId != null) 'couponId': couponId,
    'discountAmount': discountAmount,
  });

  if (response.data['status'] == 'success') {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 7️⃣ إزالة كوبون من السلة

**Endpoint:** `DELETE /cart/coupon`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**

```dart
/// إزالة كوبون من السلة
Future<Cart> removeCoupon() async {
  final response = await _dio.delete('/cart/coupon');

  if (response.data['status'] == 'success') {
    return Cart.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

> **⚠️ ملاحظة مهمة:** يمكن تطبيق الكوبونات في السلة باستخدام `/cart/coupon` (يتطلب `couponCode` و `discountAmount`)، أو يمكن إرسال `couponCode` مباشرة عند إنشاء الطلب في `/orders` (سيتم التحقق منه تلقائياً). راجع قسم إنشاء الطلب أدناه.

---

#### 8️⃣ مزامنة السلة المحلية مع السيرفر

**Endpoint:** `POST /cart/sync`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**الوصف:** مزامنة السلة المحلية مع السيرفر للتحقق من المخزون والأسعار قبل الدفع.

**Request Body:**

```dart
{
  "items": [
    {
      "productId": "507f1f77bcf86cd799439011",
      "quantity": 2,
      "unitPrice": 150.00
    },
    {
      "productId": "507f1f77bcf86cd799439012",
      "quantity": 1,
      "unitPrice": 200.00
    }
  ]
}
```

**Response:**

```dart
{
  "status": "success",
  "data": {
    "cart": { /* Cart object محدث */ },
    "removedItems": [
      {
        "productId": "...",
        "reason": "out_of_stock",  // أو "deleted", "inactive", "error"
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ],
    "priceChangedItems": [
      {
        "productId": "...",
        "oldPrice": 200.00,
        "newPrice": 180.00,
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ],
    "quantityAdjustedItems": [
      {
        "productId": "...",
        "requestedQuantity": 5,
        "availableQuantity": 2,
        "finalQuantity": 2,
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ]
  },
  "message": "Cart synced successfully",
  "messageAr": "تمت مزامنة السلة بنجاح"
}
```

**Flutter Code:**

```dart
/// مزامنة السلة المحلية مع السيرفر
Future<CartSyncResult> syncCart(List<CartSyncItem> items) async {
  final response = await _dio.post('/cart/sync', data: {
    'items': items.map((item) => {
      'productId': item.productId,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
    }).toList(),
  });

  if (response.data['status'] == 'success') {
    final data = response.data['data'];
    return CartSyncResult(
      cart: Cart.fromJson(data['cart']),
      removedItems: (data['removedItems'] as List?)
          ?.map((i) => RemovedCartItem.fromJson(i))
          .toList() ?? [],
      priceChangedItems: (data['priceChangedItems'] as List?)
          ?.map((i) => PriceChangedCartItem.fromJson(i))
          .toList() ?? [],
      quantityAdjustedItems: (data['quantityAdjustedItems'] as List?)
          ?.map((i) => QuantityAdjustedCartItem.fromJson(i))
          .toList() ?? [],
    );
  }
  throw Exception(response.data['messageAr']);
}

// Models
class CartSyncItem {
  final String productId;
  final int quantity;
  final double unitPrice;

  CartSyncItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}

class CartSyncResult {
  final Cart cart;
  final List<RemovedCartItem> removedItems;
  final List<PriceChangedCartItem> priceChangedItems;
  final List<QuantityAdjustedCartItem> quantityAdjustedItems;

  CartSyncResult({
    required this.cart,
    required this.removedItems,
    required this.priceChangedItems,
    required this.quantityAdjustedItems,
  });

  bool get hasIssues =>
    removedItems.isNotEmpty ||
    priceChangedItems.isNotEmpty ||
    quantityAdjustedItems.isNotEmpty;
}

class RemovedCartItem {
  final String productId;
  final String reason;
  final String? productName;
  final String? productNameAr;

  RemovedCartItem({
    required this.productId,
    required this.reason,
    this.productName,
    this.productNameAr,
  });

  factory RemovedCartItem.fromJson(Map<String, dynamic> json) {
    return RemovedCartItem(
      productId: json['productId'],
      reason: json['reason'],
      productName: json['productName'],
      productNameAr: json['productNameAr'],
    );
  }
}

class PriceChangedCartItem {
  final String productId;
  final double oldPrice;
  final double newPrice;
  final String? productName;
  final String? productNameAr;

  PriceChangedCartItem({
    required this.productId,
    required this.oldPrice,
    required this.newPrice,
    this.productName,
    this.productNameAr,
  });

  factory PriceChangedCartItem.fromJson(Map<String, dynamic> json) {
    return PriceChangedCartItem(
      productId: json['productId'],
      oldPrice: json['oldPrice'].toDouble(),
      newPrice: json['newPrice'].toDouble(),
      productName: json['productName'],
      productNameAr: json['productNameAr'],
    );
  }
}

class QuantityAdjustedCartItem {
  final String productId;
  final int requestedQuantity;
  final int availableQuantity;
  final int finalQuantity;
  final String? productName;
  final String? productNameAr;

  QuantityAdjustedCartItem({
    required this.productId,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.finalQuantity,
    this.productName,
    this.productNameAr,
  });

  factory QuantityAdjustedCartItem.fromJson(Map<String, dynamic> json) {
    return QuantityAdjustedCartItem(
      productId: json['productId'],
      requestedQuantity: json['requestedQuantity'],
      availableQuantity: json['availableQuantity'],
      finalQuantity: json['finalQuantity'],
      productName: json['productName'],
      productNameAr: json['productNameAr'],
    );
  }
}
```

---

### 📦 Orders

#### 9️⃣ جلب طلباتي

**Endpoint:** `GET /orders/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة (default: 1) |
| `limit` | number | ❌ | عدد النتائج (default: 20) |
| `status` | string | ❌ | فلترة بالحالة (`pending`, `confirmed`, `processing`, `ready_for_pickup`, `shipped`, `out_for_delivery`, `delivered`, `completed`, `cancelled`, `refunded`) |
| `paymentStatus` | string | ❌ | فلترة بحالة الدفع (`unpaid`, `partial`, `paid`, `refunded`) |

> **ملاحظة مهمة:** في الباك-إند الحالي، الفلاتر الفعالة في `GET /orders/my` هي `page`, `limit`, `status`, `paymentStatus`.

**Response:**

```dart
{
  "status": "success",
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
    PaymentStatus? paymentStatus,
  }) async {
    final response = await _dio.get('/orders/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.value,
      if (paymentStatus != null) 'paymentStatus': paymentStatus.name,
    });

    if (response.data['status'] == 'success') {
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

#### 🔟 إنشاء طلب جديد

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
  "paymentMethod": "credit",               // اختياري (`cash_on_delivery`, `credit_card`, `mada`, `apple_pay`, `stc_pay`, `bank_transfer`, `wallet`, `credit`)
  "customerNotes": "يرجى التوصيل صباحاً",  // اختياري
  "couponCode": "SUMMER2024",              // اختياري - يتم التحقق منه وتطبيقه مباشرة على الطلب
  "walletAmountUsed": 100.0,                 // اختياري - خصم من المحفظة
  "source": "mobile"                       // اختياري (`web`, `mobile`, `admin`) - default: `mobile`
}
```

> **📌 ملاحظة:** `couponCode` يتم التحقق منه وتطبيقه مباشرة عند إنشاء الطلب. ويمكن أيضاً تطبيق كوبون على السلة عبر `/cart/coupon` قبل إنشاء الطلب.
>
> **📌 ملاحظة إضافية:** إذا لم ترسل `paymentMethod` فالقيمة الافتراضية في الباك-إند حالياً هي `bank_transfer`.

**Response (201 Created):**

```dart
{
  "status": "success",
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
  double? walletAmountUsed,
  OrderSource? source,
}) async {
  final response = await _dio.post('/orders', data: {
    if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
    if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
    if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (couponCode != null) 'couponCode': couponCode,
    if (walletAmountUsed != null && walletAmountUsed > 0)
      'walletAmountUsed': walletAmountUsed,
    if (source != null) 'source': source.value,
  });

  if (response.data['status'] == 'success') {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

### 🧮 قواعد الحساب (الضرائب والخصومات) في الباك-إند

- المعادلة المستخدمة عند إنشاء الطلب:

```text
total = subtotal - discount - couponDiscount + taxAmount + shippingCost
```

- `taxAmount` و `shippingCost` تأتي من السلة على السيرفر (`cart`) ولا يتم احتسابها من جديد داخل `createOrder`.
- لا تعتمد على حساب الضريبة داخل Flutter؛ اعرض القيم الراجعة من API كما هي.
- إذا احتجت حساب ضريبة مسبقاً (مثلاً شاشة معاينة)، يوجد endpoint مستقل: `POST /settings/calculate-tax`.

---

#### 1️⃣1️⃣ جلب تفاصيل طلب

**Endpoint:** `GET /orders/:id`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**

```dart
{
  "status": "success",
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

> **ملاحظة:** في الباك-إند الحالي، بيانات الطلب ترجع مباشرة داخل `data` وليست داخل `data.order`.

**Flutter Code:**

```dart
/// جلب تفاصيل طلب
Future<Order> getOrderDetails(String orderId) async {
  final response = await _dio.get('/orders/$orderId');

  if (response.data['status'] == 'success') {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 1️⃣2️⃣ إلغاء الطلب (Cancel Order)

**Endpoint:** `POST /orders/:id/cancel`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**الشروط:** الطلب قابل للإلغاء فقط إذا كان في حالة `pending` أو `confirmed` أو `processing` (لم يتجاوز مرحلة قيد التجهيز). بعد الإلغاء، سيعود الطلب مع `cancellable: false`.

**Body (مطلوب):**

```json
{
  "reason": "سبب الإلغاء"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "data": {
    "_id": "...",
    "orderNumber": "ORD-2024-001234",
    "status": "cancelled",
    "cancellable": false,
    "cancellationReason": "سبب الإلغاء",
    "items": [...],
    ...
  },
  "message": "Order cancelled",
  "messageAr": "تم إلغاء الطلب"
}
```

**أخطاء محتملة:**

- `400`: لا يمكن إلغاء الطلب بعد مرحلة التجهيز
- `404`: الطلب غير موجود أو لا ينتمي للمستخدم

**Flutter Code:**

```dart
/// إلغاء طلب (السبب مطلوب)
Future<Order> cancelOrder(String orderId, {required String reason}) async {
  final response = await _dio.post(
    '/orders/$orderId/cancel',
    data: {'reason': reason},
  );

  if (response.data['status'] == 'success') {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

> **ملاحظة:** استخدم حقل `cancellable` من استجابة الطلب لعرض/إخفاء زر الإلغاء. القيمة تأتي من الـ API مع كل طلب.

---

#### 1️⃣3️⃣ جلب إحصائيات طلباتي

**Endpoint:** `GET /orders/my/stats`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**

```dart
{
  "status": "success",
  "data": {
    "total": 45,
    "byStatus": {
      "pending": 2,
      "confirmed": 5,
      "processing": 3,
      "delivered": 30,
      "completed": 5
    },
    "byPaymentStatus": {
      "unpaid": 2,
      "partial": 1,
      "paid": 42
    },
    "totalRevenue": 125000.00,
    "totalPaid": 120000.00,
    "totalUnpaid": 5000.00,
    "todayOrders": 3,
    "todayRevenue": 5000.00,
    "thisMonthOrders": 15,
    "thisMonthRevenue": 45000.00
  },
  "message": "Order statistics retrieved",
  "messageAr": "تم استرجاع إحصائيات الطلبات"
}
```

**Flutter Code:**

```dart
/// جلب إحصائيات طلباتي
Future<OrderStats> getMyStats() async {
  final response = await _dio.get('/orders/my/stats');

  if (response.data['status'] == 'success') {
    return OrderStats.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}

class OrderStats {
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

  OrderStats({
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

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
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
}
```

---

#### 1️⃣4️⃣ رفع إيصال الدفع

**Endpoint:** `POST /orders/:id/upload-receipt`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**الشروط من الباك-إند:**

- مسموح فقط إذا كانت طريقة الدفع `bank_transfer`
- غير مسموح إذا `transferStatus = verified`
- غير مسموح إذا الطلب مدفوع بالكامل

**Request Body:**

```dart
{
  "receiptImage": "base64_encoded_image_or_url",  // مطلوب
  "transferReference": "REF123456",              // اختياري
  "transferDate": "2024-01-15",                 // اختياري (string format: YYYY-MM-DD)
  "notes": "Payment completed via bank transfer" // اختياري
}
```

**Response:**

```dart
{
  "status": "success",
  "data": { /* Order object محدث */ },
  "message": "Receipt uploaded successfully",
  "messageAr": "تم رفع الإيصال بنجاح"
}
```

**Flutter Code:**

```dart
/// رفع إيصال الدفع
Future<Order> uploadReceipt({
  required String orderId,
  required String receiptImage, // base64 أو URL
  String? transferReference,
  String? transferDate, // YYYY-MM-DD format
  String? notes,
}) async {
  final response = await _dio.post('/orders/$orderId/upload-receipt', data: {
    'receiptImage': receiptImage,
    if (transferReference != null) 'transferReference': transferReference,
    if (transferDate != null) 'transferDate': transferDate,
    if (notes != null) 'notes': notes,
  });

  if (response.data['status'] == 'success') {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

> **ملاحظة:** `receiptImage` في هذا endpoint يُرسل كنص (Base64 أو URL) وليس `multipart/form-data`.
>
> بعد الرفع، الحالة تصبح غالباً `transferStatus = receipt_uploaded`، ثم يقوم الأدمن بالتحقق عبر endpoint إداري (`POST /admin/orders/:id/verify-payment`) لتتحول إلى `verified` أو `rejected`.

---

#### 1️⃣5️⃣ تقييم الطلب

**Endpoint:** `POST /orders/:id/rate`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**

```dart
{
  "rating": 5,                    // مطلوب (1-5)
  "comment": "تجربة رائعة!"       // اختياري
}
```

**Response:**

```dart
{
  "status": "success",
  "data": { /* Order object محدث */ },
  "message": "Order rated successfully",
  "messageAr": "تم تقييم الطلب بنجاح"
}
```

**Flutter Code:**

```dart
/// تقييم الطلب
Future<Order> rateOrder({
  required String orderId,
  required int rating, // 1-5
  String? comment,
}) async {
  final response = await _dio.post('/orders/$orderId/rate', data: {
    'rating': rating,
    if (comment != null) 'comment': comment,
  });

  if (response.data['status'] == 'success') {
    return Order.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 1️⃣6️⃣ جلب الطلبات بانتظار الدفع

**Endpoint:** `GET /orders/pending-payment`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**الوصف:** يعيد الطلبات ذات `paymentMethod = bank_transfer` و `paymentStatus` يساوي `unpaid` أو `partial`.

**Response:**

```dart
{
  "status": "success",
  "data": [
    {
      "_id": "...",
      "orderNumber": "ORD-2024-001234",
      "status": "pending",
      "paymentStatus": "unpaid",
      "paymentMethod": "bank_transfer",
      "total": 1250,
      "createdAt": "2024-01-15T..."
    }
  ],
  "message": "Pending payment orders retrieved",
  "messageAr": "تم استرجاع الطلبات بانتظار الدفع"
}
```

**Flutter Code:**

```dart
/// جلب الطلبات بانتظار الدفع
Future<List<Order>> getPendingPaymentOrders() async {
  final response = await _dio.get('/orders/pending-payment');

  if (response.data['status'] == 'success') {
    return (response.data['data'] as List)
        .map((o) => Order.fromJson(o))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 1️⃣7️⃣ جلب الحسابات البنكية (Public)

**Endpoint:** `GET /bank-accounts`

**Headers:** لا يحتاج Token (Public endpoint) 🌐

**Response:**

```dart
{
  "status": "success",
  "data": [
    {
      "_id": "...",
      "bankName": "البنك الأهلي",
      "bankNameAr": "البنك الأهلي السعودي",
      "bankCode": "NCB",
      "accountName": "Tras Phone Company",
      "accountNameAr": "شركة تراس فون",
      "accountNumber": "1234567890",
      "iban": "SA1234567890123456789012",
      "displayName": "البنك الأهلي - حساب الشركة",
      "displayNameAr": "البنك الأهلي - حساب الشركة",
      "logo": "https://example.com/logo.png",
      "instructions": "Please include order number in transfer notes",
      "instructionsAr": "يرجى إضافة رقم الطلب في ملاحظات التحويل",
      "currencyCode": "SAR",
      "isActive": true,
      "isDefault": true,
      "sortOrder": 0,
      "totalReceived": 0,
      "createdAt": "2024-01-15T...",
      "updatedAt": "2024-01-15T..."
    }
  ],
  "message": "Bank accounts retrieved",
  "messageAr": "تم استرجاع الحسابات البنكية"
}
```

**Flutter Code:**

```dart
/// جلب الحسابات البنكية
Future<List<BankAccount>> getBankAccounts() async {
  final response = await _dio.get('/bank-accounts');

  if (response.data['status'] == 'success') {
    return (response.data['data'] as List)
        .map((a) => BankAccount.fromJson(a))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}

class BankAccount {
  final String id;
  final String bankName;
  final String? bankNameAr;
  final String? bankCode;
  final String accountName;
  final String? accountNameAr;
  final String accountNumber;
  final String? iban;
  final String displayName;
  final String? displayNameAr;
  final String? logo;
  final String? instructions;
  final String? instructionsAr;
  final String currencyCode;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final double totalReceived;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.bankName,
    this.bankNameAr,
    this.bankCode,
    required this.accountName,
    this.accountNameAr,
    required this.accountNumber,
    this.iban,
    required this.displayName,
    this.displayNameAr,
    this.logo,
    this.instructions,
    this.instructionsAr,
    required this.currencyCode,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
    required this.totalReceived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id'] ?? json['id'],
      bankName: json['bankName'],
      bankNameAr: json['bankNameAr'],
      bankCode: json['bankCode'],
      accountName: json['accountName'],
      accountNameAr: json['accountNameAr'],
      accountNumber: json['accountNumber'],
      iban: json['iban'],
      displayName: json['displayName'],
      displayNameAr: json['displayNameAr'],
      logo: json['logo'],
      instructions: json['instructions'],
      instructionsAr: json['instructionsAr'],
      currencyCode: json['currencyCode'] ?? 'SAR',
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      totalReceived: (json['totalReceived'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

---

## 🛒 السلة المحلية (Local Cart)

> **ملاحظة مهمة**: النظام يستخدم الآن **السلة المحلية** لجميع العمليات اليومية (إضافة، تعديل، حذف). هذه العمليات تكون فورية بدون انتظار السيرفر. يتم المزامنة مع السيرفر فقط عند الحاجة (قبل الدفع أو عند تسجيل الدخول).

### استخدام CartCubit في Flutter

```dart
// في ProductDetailsScreen - إضافة منتج للسلة (فوري)
context.read<CartCubit>().addToCartLocal(
  productId: product.id,
  quantity: 1,
  unitPrice: product.price,
  productName: product.name,
  productNameAr: product.nameAr,
  productImage: product.images.firstOrNull,
  productSku: product.sku,
);

// في CartScreen - تحديث الكمية (فوري)
context.read<CartCubit>().updateQuantityLocal(
  productId: item.productId,
  quantity: newQuantity,
);

// في CartScreen - حذف منتج (فوري)
context.read<CartCubit>().removeFromCartLocal(
  productId: item.productId,
);

// في CartScreen - جلب السلة المحلية
context.read<CartCubit>().loadLocalCart();

// قبل الدفع - مزامنة مع السيرفر
final result = await context.read<CartCubit>().syncCart();

if (result?.hasIssues == true) {
  // عرض نتائج المزامنة للمستخدم
  _showSyncIssuesDialog(result!);
} else {
  // المتابعة للدفع
  context.push('/checkout');
}
```

### حالات السلة (Cart States)

```dart
// CartInitial - الحالة الأولية
// CartLoading - جاري التحميل
// CartLoaded - تم تحميل السلة (من المحلي أو السيرفر)
// CartUpdating - جاري التحديث
// CartError - خطأ
// CartSyncing - جاري المزامنة
// CartSyncCompleted - تمت المزامنة بنجاح
// CartSyncError - خطأ في المزامنة

BlocBuilder<CartCubit, CartState>(
  builder: (context, state) {
    if (state is CartLoaded) {
      final cart = state.cart;
      // عرض السلة
    } else if (state is CartSyncing) {
      return CircularProgressIndicator();
    } else if (state is CartSyncCompleted) {
      final result = state.syncResult;
      // عرض نتائج المزامنة
    }
    return SizedBox.shrink();
  },
)
```

> 📚 **للمزيد من التفاصيل والأمثلة الكاملة**: راجع [Local Cart Module Documentation](./local-cart.md)

---

## 🧩 الـ Services الكاملة

### CartService (Legacy - للاستخدام مع Backend مباشرة)

> **ملاحظة**: في التطبيق الفعلي، يتم استخدام `CartCubit` مع العمليات المحلية بدلاً من هذه الـ Service. هذه الـ Service مخصصة للاستخدام المباشر مع Backend بدون استخدام Local Cart.

```dart
import 'package:dio/dio.dart';

class CartService {
  final Dio _dio;

  CartService(this._dio);

  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');
    if (response.data['status'] == 'success') {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Cart> addItem({
    required String productId,
    required int quantity,
    double? unitPrice,
  }) async {
    final response = await _dio.post('/cart/items', data: {
      'productId': productId,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
    });
    if (response.data['status'] == 'success') {
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
    if (response.data['status'] == 'success') {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Cart> removeItem(String productId) async {
    final response = await _dio.delete('/cart/items/$productId');
    if (response.data['status'] == 'success') {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Cart> clearCart() async {
    final response = await _dio.delete('/cart');
    if (response.data['status'] == 'success') {
      return Cart.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }


  Future<CartSyncResult> syncCart(List<CartSyncItem> items) async {
    final response = await _dio.post('/cart/sync', data: {
      'items': items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
      }).toList(),
    });

    if (response.data['status'] == 'success') {
      final data = response.data['data'];
      return CartSyncResult(
        cart: Cart.fromJson(data['cart']),
        removedItems: (data['removedItems'] as List?)
            ?.map((i) => RemovedCartItem.fromJson(i))
            .toList() ?? [],
        priceChangedItems: (data['priceChangedItems'] as List?)
            ?.map((i) => PriceChangedCartItem.fromJson(i))
            .toList() ?? [],
        quantityAdjustedItems: (data['quantityAdjustedItems'] as List?)
            ?.map((i) => QuantityAdjustedCartItem.fromJson(i))
            .toList() ?? [],
      );
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
    PaymentStatus? paymentStatus,
  }) async {
    final response = await _dio.get('/orders/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.value,
      if (paymentStatus != null) 'paymentStatus': paymentStatus.name,
    });

    if (response.data['status'] == 'success') {
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
    double? walletAmountUsed,
    OrderSource? source,
  }) async {
    final response = await _dio.post('/orders', data: {
      if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
      if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
      if (customerNotes != null) 'customerNotes': customerNotes,
      if (couponCode != null) 'couponCode': couponCode,
      if (walletAmountUsed != null && walletAmountUsed > 0)
        'walletAmountUsed': walletAmountUsed,
      if (source != null) 'source': source.value,
    });

    if (response.data['status'] == 'success') {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Order> getOrderDetails(String orderId) async {
    final response = await _dio.get('/orders/$orderId');

    if (response.data['status'] == 'success') {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<OrderStats> getMyStats() async {
    final response = await _dio.get('/orders/my/stats');

    if (response.data['status'] == 'success') {
      return OrderStats.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Order> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate, // YYYY-MM-DD format
    String? notes,
  }) async {
    final response = await _dio.post('/orders/$orderId/upload-receipt', data: {
      'receiptImage': receiptImage,
      if (transferReference != null) 'transferReference': transferReference,
      if (transferDate != null) 'transferDate': transferDate,
      if (notes != null) 'notes': notes,
    });

    if (response.data['status'] == 'success') {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<Order> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final response = await _dio.post('/orders/$orderId/rate', data: {
      'rating': rating,
      if (comment != null) 'comment': comment,
    });

    if (response.data['status'] == 'success') {
      return Order.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }

  Future<List<Order>> getPendingPaymentOrders() async {
    final response = await _dio.get('/orders/pending-payment');

    if (response.data['status'] == 'success') {
      return (response.data['data'] as List)
          .map((o) => Order.fromJson(o))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }

  Future<List<BankAccount>> getBankAccounts() async {
    final response = await _dio.get('/bank-accounts');

    if (response.data['status'] == 'success') {
      return (response.data['data'] as List)
          .map((a) => BankAccount.fromJson(a))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🎯 أمثلة الاستخدام

### عرض السلة مع الـ Checkout (باستخدام Local Cart)

```dart
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // جلب السلة المحلية (فوري)
    context.read<CartCubit>().loadLocalCart();
  }

  Future<void> _handleCheckout() async {
    // عرض loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    // مزامنة السلة مع السيرفر قبل الدفع
    final result = await context.read<CartCubit>().syncCart();

    // إغلاق loading
    Navigator.pop(context);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشلت المزامنة. حاول مرة أخرى.')),
      );
      return;
    }

    // التحقق من نتائج المزامنة
    if (result.hasIssues) {
      await _showSyncIssuesDialog(result);
    } else {
      // المتابعة للدفع
      Navigator.pushNamed(context, '/checkout');
    }
  }

  void _showSyncIssuesDialog(CartSyncResultEntity result) {
    // عرض نتائج المزامنة (منتجات محذوفة، أسعار متغيرة، كميات معدلة)
    // راجع local-cart.md للأمثلة الكاملة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('السلة')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            final cart = state.cart;

            if (cart.isEmpty) {
              return Center(child: Text('السلة فارغة'));
            }

            return Column(
              children: [
                // قائمة العناصر
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemTile(
                        item: item,
                        onQuantityChanged: (qty) {
                          // تحديث فوري بدون انتظار
                          context.read<CartCubit>().updateQuantityLocal(
                            item.productId,
                            qty,
                          );
                        },
                        onRemove: () {
                          // حذف فوري بدون انتظار
                          context.read<CartCubit>().removeFromCartLocal(
                            item.productId,
                          );
                        },
                      );
                    },
                  ),
                ),

                // ملخص السلة
                CartSummary(
                  subtotal: cart.subtotal,
                  discount: cart.discount + cart.couponDiscount,
                  shipping: cart.shippingCost,
                  tax: cart.taxAmount,
                  total: cart.total,
                ),

                // زر الإتمام
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('الدفع'),
                  ),
                ),
              ],
            );
          } else if (state is CartSyncing) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CartSyncCompleted) {
            // بعد المزامنة، إعادة بناء الواجهة
            return build(context);
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

### مثال: إضافة منتج للسلة (في ProductDetailsScreen)

```dart
ElevatedButton(
  onPressed: () {
    // إضافة فورية للسلة المحلية
    context.read<CartCubit>().addToCartLocal(
      productId: product.id,
      quantity: 1,
      unitPrice: product.price,
      productName: product.name,
      productNameAr: product.nameAr,
      productImage: product.images.firstOrNull,
      productSku: product.sku,
    );

    // عرض رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت الإضافة للسلة')),
    );
  },
  child: Text('أضف للسلة'),
)
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

| Method   | Endpoint                 | الوصف                               |
| -------- | ------------------------ | ----------------------------------- |
| GET      | `/cart`                  | جلب السلة من السيرفر                |
| POST     | `/cart/items`            | إضافة عنصر للسلة على السيرفر        |
| PUT      | `/cart/items/:productId` | تحديث كمية عنصر على السيرفر         |
| DELETE   | `/cart/items/:productId` | حذف عنصر من السلة على السيرفر       |
| DELETE   | `/cart`                  | تفريغ السلة على السيرفر             |
| POST     | `/cart/coupon`           | تطبيق كوبون على السلة               |
| DELETE   | `/cart/coupon`           | إزالة كوبون من السلة                |
| **POST** | **`/cart/sync`**         | **مزامنة السلة المحلية مع السيرفر** |

> **⚠️ ملاحظات مهمة:**
>
> - في التطبيق، يتم استخدام العمليات المحلية (`addToCartLocal`, `updateQuantityLocal`, `removeFromCartLocal`) للعمليات اليومية.
> - endpoint `/cart/sync` يُستخدم فقط قبل الدفع للتحقق من المخزون والأسعار.
> - **الكوبونات**: يمكن تطبيقها في السلة باستخدام `/cart/coupon` أو إرسال `couponCode` مباشرة عند إنشاء الطلب.

### 📦 Orders

| Method | Endpoint                     | الوصف                     |
| ------ | ---------------------------- | ------------------------- |
| GET    | `/orders/my`                 | طلباتي                    |
| GET    | `/orders/my/stats`           | إحصائيات طلباتي           |
| POST   | `/orders`                    | إنشاء طلب                 |
| GET    | `/orders/:id`                | تفاصيل الطلب              |
| POST   | `/orders/:id/cancel`         | إلغاء الطلب               |
| POST   | `/orders/:id/upload-receipt` | رفع إيصال الدفع           |
| POST   | `/orders/:id/rate`           | تقييم الطلب               |
| GET    | `/orders/pending-payment`    | الطلبات بانتظار الدفع     |
| GET    | `/bank-accounts`             | الحسابات البنكية (Public) |

---

## ⚠️ ملاحظات مهمة

### 1. استخدام السلة المحلية

- **العمليات اليومية**: استخدم `addToCartLocal`, `updateQuantityLocal`, `removeFromCartLocal` (فورية)
- **المزامنة**: استخدم `syncCart()` فقط قبل الدفع أو عند تسجيل الدخول
- **الكوبونات**: في تدفق `Local Cart` لا يتم حفظ الكوبون محلياً؛ يتم إرساله عادة عند الدفع (`couponCode`) أو تطبيقه على سلة السيرفر عبر `/cart/coupon`

### 2. تدفق العمل الموصى به

```
إضافة منتج → addToCartLocal() (فوري)
    ↓
تحديث الكمية → updateQuantityLocal() (فوري)
    ↓
الضغط على Checkout → syncCart() (للتحقق)
    ↓
عرض نتائج المزامنة → إذا كانت هناك تغييرات
    ↓
إنشاء الطلب → POST /orders
```

### 3. معالجة نتائج المزامنة

عند استخدام `syncCart()`, تأكد من:

- التحقق من `result.hasIssues`
- عرض المنتجات المحذوفة للمستخدم
- عرض المنتجات التي تغير سعرها
- عرض المنتجات التي تم تعديل كميتها
- الحصول على موافقة المستخدم قبل المتابعة

---

## 📚 مراجع إضافية

- [Local Cart Module Documentation](./local-cart.md) - دليل شامل عن السلة المحلية والمزامنة
- [API Documentation](../../backend/README.md) - توثيق API الكامل

---

> 🔗 **السابق:** [customers.md](./customers.md) - دليل العملاء  
> 🔗 **التالي:** [products.md](./products.md) - دليل المنتجات (قريباً)
