# 🔄 Returns Module - دليل ربط المرتجعات

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ إنشاء طلبات الإرجاع (Return Requests)
- ✅ تتبع حالة المرتجعات
- ✅ أسباب الإرجاع (Return Reasons)
- ✅ عناصر المرتجعات (Return Items)
- ✅ **دعم الإرجاع من عدة فواتير** (Multiple Orders)
- ✅ **حساب الأسعار تلقائياً من الفواتير**
- ✅ **التحويل التلقائي للمحفظة** (Automatic Wallet Credit)

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒 باستثناء `GET /returns/reasons`

> **💡 مهم**: النظام يستخرج معرفات الفواتير (`orderIds`) تلقائياً من عناصر الطلبات (`orderItemIds`) المُرسلة. الأسعار تُجلب تلقائياً من الفواتير الأصلية لضمان الدقة والأمان.

---

## 📁 Flutter Models

### ReturnRequest Model

```dart
class ReturnRequest {
  final String id;
  final String returnNumber;
  final List<String> orderIds; // دعم عدة فواتير
  final String customerId;
  final ReturnStatus status;
  final ReturnType returnType;
  final String reasonId;
  final ReturnReason? reason;
  final String? customerNotes;
  final List<String>? customerImages;
  final double totalItemsValue;
  final double restockingFee;
  final double shippingDeduction;
  final double refundAmount;
  final DateTime? scheduledPickupDate;
  final String? pickupTrackingNumber;
  final String? exchangeOrderId;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime? completedAt;
  final List<ReturnItem>? items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReturnRequest({
    required this.id,
    required this.returnNumber,
    required this.orderIds,
    required this.customerId,
    required this.status,
    required this.returnType,
    required this.reasonId,
    this.reason,
    this.customerNotes,
    this.customerImages,
    required this.totalItemsValue,
    required this.restockingFee,
    required this.shippingDeduction,
    required this.refundAmount,
    this.scheduledPickupDate,
    this.pickupTrackingNumber,
    this.exchangeOrderId,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.completedAt,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['_id'] ?? json['id'],
      returnNumber: json['returnNumber'],
      orderIds: json['orderIds'] != null
          ? (json['orderIds'] as List).map((id) => 
              id is String ? id : id['_id']?.toString() ?? '').toList()
          : (json['orderId'] != null ? [json['orderId']] : []), // backward compatibility
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']?['_id'] ?? '',
      status: ReturnStatus.fromString(json['status']),
      returnType: ReturnType.fromString(json['returnType']),
      reasonId: json['reasonId'] is String 
          ? json['reasonId'] 
          : json['reasonId']?['_id'] ?? '',
      reason: json['reasonId'] is Map 
          ? ReturnReason.fromJson(json['reasonId']) 
          : null,
      customerNotes: json['customerNotes'],
      customerImages: json['customerImages'] != null 
          ? List<String>.from(json['customerImages']) 
          : null,
      totalItemsValue: (json['totalItemsValue'] ?? 0).toDouble(),
      restockingFee: (json['restockingFee'] ?? 0).toDouble(),
      shippingDeduction: (json['shippingDeduction'] ?? 0).toDouble(),
      refundAmount: (json['refundAmount'] ?? 0).toDouble(),
      scheduledPickupDate: json['scheduledPickupDate'] != null 
          ? DateTime.parse(json['scheduledPickupDate']) 
          : null,
      pickupTrackingNumber: json['pickupTrackingNumber'],
      exchangeOrderId: json['exchangeOrderId'],
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      rejectedAt: json['rejectedAt'] != null 
          ? DateTime.parse(json['rejectedAt']) 
          : null,
      rejectionReason: json['rejectionReason'],
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      items: json['items'] != null 
          ? (json['items'] as List).map((i) => ReturnItem.fromJson(i)).toList() 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// هل يمكن إلغاء الطلب؟
  bool get canCancel => status == ReturnStatus.pending;
  
  /// هل الطلب نشط؟
  bool get isActive => ![
    ReturnStatus.completed, 
    ReturnStatus.cancelled, 
    ReturnStatus.rejected
  ].contains(status);
  
  /// المبلغ الصافي للاسترداد
  double get netRefund => totalItemsValue - restockingFee - shippingDeduction;
}
```

### ReturnItem Model

```dart
class ReturnItem {
  final String id;
  final String returnRequestId;
  final String orderItemId;
  final String productId;
  final String productSku;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final InspectionStatus inspectionStatus;
  final ItemCondition? condition;
  final int approvedQuantity;
  final int rejectedQuantity;
  final String? inspectionNotes;

  ReturnItem({
    required this.id,
    required this.returnRequestId,
    required this.orderItemId,
    required this.productId,
    required this.productSku,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.inspectionStatus,
    this.condition,
    required this.approvedQuantity,
    required this.rejectedQuantity,
    this.inspectionNotes,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['_id'] ?? json['id'],
      returnRequestId: json['returnRequestId'] is String 
          ? json['returnRequestId'] 
          : json['returnRequestId']?['_id'] ?? '',
      orderItemId: json['orderItemId'] is String 
          ? json['orderItemId'] 
          : json['orderItemId']?['_id'] ?? '',
      productId: json['productId'] is String 
          ? json['productId'] 
          : json['productId']?['_id'] ?? '',
      productSku: json['productSku'],
      productName: json['productName'],
      productImage: json['productImage'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      inspectionStatus: InspectionStatus.fromString(json['inspectionStatus']),
      condition: json['condition'] != null 
          ? ItemCondition.fromString(json['condition']) 
          : null,
      approvedQuantity: json['approvedQuantity'] ?? 0,
      rejectedQuantity: json['rejectedQuantity'] ?? 0,
      inspectionNotes: json['inspectionNotes'],
    );
  }
}
```

### ReturnReason Model

```dart
class ReturnReason {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final ReasonCategory category;
  final bool requiresPhoto;
  final bool eligibleForRefund;
  final bool eligibleForExchange;
  final int displayOrder;
  final bool isActive;

  ReturnReason({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    required this.category,
    required this.requiresPhoto,
    required this.eligibleForRefund,
    required this.eligibleForExchange,
    required this.displayOrder,
    required this.isActive,
  });

  factory ReturnReason.fromJson(Map<String, dynamic> json) {
    return ReturnReason(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      category: ReasonCategory.fromString(json['category']),
      requiresPhoto: json['requiresPhoto'] ?? true,
      eligibleForRefund: json['eligibleForRefund'] ?? true,
      eligibleForExchange: json['eligibleForExchange'] ?? true,
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}
```

### Enums

```dart
/// حالة طلب الإرجاع
enum ReturnStatus {
  pending,          // في انتظار المراجعة
  approved,         // تمت الموافقة
  rejected,         // مرفوض
  pickupScheduled,  // تم جدولة الاستلام
  pickedUp,         // تم الاستلام
  inspecting,       // قيد الفحص
  completed,        // مكتمل
  cancelled;        // ملغي

  static ReturnStatus fromString(String value) {
    switch (value) {
      case 'pending': return ReturnStatus.pending;
      case 'approved': return ReturnStatus.approved;
      case 'rejected': return ReturnStatus.rejected;
      case 'pickup_scheduled': return ReturnStatus.pickupScheduled;
      case 'picked_up': return ReturnStatus.pickedUp;
      case 'inspecting': return ReturnStatus.inspecting;
      case 'completed': return ReturnStatus.completed;
      case 'cancelled': return ReturnStatus.cancelled;
      default: return ReturnStatus.pending;
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReturnStatus.pending: return 'في انتظار المراجعة';
      case ReturnStatus.approved: return 'تمت الموافقة';
      case ReturnStatus.rejected: return 'مرفوض';
      case ReturnStatus.pickupScheduled: return 'تم جدولة الاستلام';
      case ReturnStatus.pickedUp: return 'تم الاستلام';
      case ReturnStatus.inspecting: return 'قيد الفحص';
      case ReturnStatus.completed: return 'مكتمل';
      case ReturnStatus.cancelled: return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case ReturnStatus.pending: return Colors.orange;
      case ReturnStatus.approved: return Colors.blue;
      case ReturnStatus.rejected: return Colors.red;
      case ReturnStatus.pickupScheduled: return Colors.purple;
      case ReturnStatus.pickedUp: return Colors.indigo;
      case ReturnStatus.inspecting: return Colors.teal;
      case ReturnStatus.completed: return Colors.green;
      case ReturnStatus.cancelled: return Colors.grey;
    }
  }
}

/// نوع الإرجاع
enum ReturnType {
  refund,       // استرداد مالي
  exchange,     // استبدال
  storeCredit;  // رصيد متجر

  static ReturnType fromString(String value) {
    switch (value) {
      case 'refund': return ReturnType.refund;
      case 'exchange': return ReturnType.exchange;
      case 'store_credit': return ReturnType.storeCredit;
      default: return ReturnType.refund;
    }
  }

  String toApiString() {
    switch (this) {
      case ReturnType.refund: return 'refund';
      case ReturnType.exchange: return 'exchange';
      case ReturnType.storeCredit: return 'store_credit';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReturnType.refund: return 'استرداد مالي';
      case ReturnType.exchange: return 'استبدال';
      case ReturnType.storeCredit: return 'رصيد متجر';
    }
  }
}

/// فئة سبب الإرجاع
enum ReasonCategory {
  defective,      // عيب في المنتج
  wrongItem,      // منتج خاطئ
  notAsDescribed, // لا يطابق الوصف
  changedMind,    // تغيير الرأي
  damaged,        // تالف
  other;          // أخرى

  static ReasonCategory fromString(String value) {
    switch (value) {
      case 'defective': return ReasonCategory.defective;
      case 'wrong_item': return ReasonCategory.wrongItem;
      case 'not_as_described': return ReasonCategory.notAsDescribed;
      case 'changed_mind': return ReasonCategory.changedMind;
      case 'damaged': return ReasonCategory.damaged;
      case 'other': return ReasonCategory.other;
      default: return ReasonCategory.other;
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReasonCategory.defective: return 'عيب في المنتج';
      case ReasonCategory.wrongItem: return 'منتج خاطئ';
      case ReasonCategory.notAsDescribed: return 'لا يطابق الوصف';
      case ReasonCategory.changedMind: return 'تغيير الرأي';
      case ReasonCategory.damaged: return 'تالف';
      case ReasonCategory.other: return 'أخرى';
    }
  }
}

/// حالة فحص العنصر
enum InspectionStatus {
  pending,
  inspected,
  approved,
  rejected;

  static InspectionStatus fromString(String value) {
    return InspectionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InspectionStatus.pending,
    );
  }
}

/// حالة العنصر
enum ItemCondition {
  good,         // جيد
  damaged,      // تالف
  used,         // مستخدم
  missingParts, // أجزاء ناقصة
  notOriginal;  // غير أصلي

  static ItemCondition fromString(String value) {
    switch (value) {
      case 'good': return ItemCondition.good;
      case 'damaged': return ItemCondition.damaged;
      case 'used': return ItemCondition.used;
      case 'missing_parts': return ItemCondition.missingParts;
      case 'not_original': return ItemCondition.notOriginal;
      default: return ItemCondition.good;
    }
  }
}
```

---

## 📞 API Endpoints

### 📋 Return Reasons

#### 1️⃣ جلب أسباب الإرجاع

**Endpoint:** `GET /returns/reasons` 🌐 (Public)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Defective Product",
      "nameAr": "عيب في المنتج",
      "description": "Product has manufacturing defects",
      "category": "defective",
      "requiresPhoto": true,
      "eligibleForRefund": true,
      "eligibleForExchange": true,
      "displayOrder": 1,
      "isActive": true,
      "createdAt": "2024-01-01T10:00:00Z",
      "updatedAt": "2024-01-01T10:00:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Wrong Item Received",
      "nameAr": "استلمت منتج خاطئ",
      "description": "Received different item than ordered",
      "category": "wrong_item",
      "requiresPhoto": true,
      "eligibleForRefund": true,
      "eligibleForExchange": true,
      "displayOrder": 2,
      "isActive": true,
      "createdAt": "2024-01-01T10:00:00Z",
      "updatedAt": "2024-01-01T10:00:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439013",
      "name": "Changed My Mind",
      "nameAr": "غيرت رأيي",
      "description": "Customer changed their mind",
      "category": "changed_mind",
      "requiresPhoto": false,
      "eligibleForRefund": true,
      "eligibleForExchange": true,
      "displayOrder": 5,
      "isActive": true,
      "createdAt": "2024-01-01T10:00:00Z",
      "updatedAt": "2024-01-01T10:00:00Z"
    }
  ],
  "message": "Reasons retrieved",
  "messageAr": "تم استرجاع الأسباب"
}
```

**Flutter Code:**
```dart
class ReturnsService {
  final Dio _dio;
  
  ReturnsService(this._dio);
  
  /// جلب أسباب الإرجاع المتاحة
  Future<List<ReturnReason>> getReasons() async {
    final response = await _dio.get('/returns/reasons');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((r) => ReturnReason.fromJson(r))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

### 🔄 My Returns

#### 2️⃣ جلب طلبات الإرجاع الخاصة بي

**Endpoint:** `GET /returns/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة |
| `limit` | number | ❌ | عدد النتائج |
| `status` | string | ❌ | فلترة بحالة الطلب |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439014",
      "returnNumber": "RET-2024-001234",
      "orderIds": [
        {
          "_id": "507f1f77bcf86cd799439001",
          "orderNumber": "ORD-2024-001234"
        }
      ],
      "customerId": {
        "_id": "507f1f77bcf86cd799439010",
        "shopName": "محل الإلكترونيات",
        "responsiblePersonName": "أحمد محمد",
        "phone": "+966501234567"
      },
      "status": "approved",
      "returnType": "refund",
      "reasonId": {
        "_id": "507f1f77bcf86cd799439011",
        "name": "Defective Product",
        "nameAr": "عيب في المنتج"
      },
      "totalItemsValue": 500.00,
      "refundAmount": 480.00,
      "restockingFee": 20.00,
      "shippingDeduction": 0,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-16T14:30:00Z"
    }
  ],
  "meta": {
    "total": 5
  },
  "message": "Returns retrieved",
  "messageAr": "تم استرجاع المرتجعات"
}
```

**Flutter Code:**
```dart
/// جلب طلبات الإرجاع الخاصة بي
Future<List<ReturnRequest>> getMyReturns({
  int page = 1,
  int limit = 10,
  ReturnStatus? status,
}) async {
  final response = await _dio.get('/returns/my', queryParameters: {
    'page': page,
    'limit': limit,
    if (status != null) 'status': status.name,
  });
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((r) => ReturnRequest.fromJson(r))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ إنشاء طلب إرجاع جديد

**Endpoint:** `POST /returns`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```json
{
  "returnType": "refund",
  "reasonId": "507f1f77bcf86cd799439011",
  "items": [
    {
      "orderItemId": "507f1f77bcf86cd799439012",
      "quantity": 1
    },
    {
      "orderItemId": "507f1f77bcf86cd799439013",
      "quantity": 2
    }
  ],
  "customerNotes": "الشاشة بها خدوش",
  "customerImages": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ]
}
```

**Validation Rules:**
- `returnType`: مطلوب، يجب أن يكون أحد: `refund`, `exchange`, `store_credit`
- `reasonId`: مطلوب، MongoDB ObjectId صحيح
- `items`: مطلوب، مصفوفة غير فارغة
  - `orderItemId`: مطلوب، MongoDB ObjectId صحيح
  - `quantity`: مطلوب، رقم >= 1
- `customerNotes`: اختياري، نص
- `customerImages`: اختياري، مصفوفة من URLs

> **💡 الأسعار والفواتير تُجلب تلقائياً**: 
> - لا حاجة لإرسال أسعار المنتجات - يتم جلبها من الفواتير الأصلية
> - معرفات الفواتير (`orderIds`) تُستخرج تلقائياً من `orderItemIds`
> - يتم التحقق من صحة الكميات والملكية تلقائياً

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "returnNumber": "RET-2024-001235",
    "orderIds": [
      "507f1f77bcf86cd799439001",
      "507f1f77bcf86cd799439002"
    ],
    "customerId": "507f1f77bcf86cd799439010",
    "status": "pending",
    "returnType": "refund",
    "reasonId": "507f1f77bcf86cd799439011",
    "customerNotes": "الشاشة بها خدوش",
    "customerImages": [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg"
    ],
    "totalItemsValue": 750.00,
    "restockingFee": 0,
    "shippingDeduction": 0,
    "refundAmount": 0,
    "createdAt": "2024-01-16T14:00:00Z",
    "updatedAt": "2024-01-16T14:00:00Z"
  },
  "message": "Return request created",
  "messageAr": "تم إنشاء طلب الإرجاع"
}
```

**Flutter Code:**
```dart
/// إنشاء طلب إرجاع جديد
/// ملاحظة: orderIds يُستخرج تلقائياً من orderItemIds
Future<ReturnRequest> createReturn({
  required ReturnType returnType,
  required String reasonId,
  required List<ReturnItemRequest> items,
  String? customerNotes,
  List<String>? customerImages,
}) async {
  final response = await _dio.post('/returns', data: {
    'returnType': returnType.toApiString(),
    'reasonId': reasonId,
    'items': items.map((i) => i.toJson()).toList(),
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (customerImages != null) 'customerImages': customerImages,
  });
  
  if (response.data['success']) {
    return ReturnRequest.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr'] ?? response.data['message']);
}

/// طلب عنصر للإرجاع
class ReturnItemRequest {
  final String orderItemId;
  final int quantity;

  const ReturnItemRequest({
    required this.orderItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'orderItemId': orderItemId,
    'quantity': quantity,
  };
}
```

---

#### 4️⃣ جلب تفاصيل طلب إرجاع

**Endpoint:** `GET /returns/:id`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": {
    "returnRequest": {
      "_id": "507f1f77bcf86cd799439014",
      "returnNumber": "RET-2024-001234",
      "orderIds": [
        {
          "_id": "507f1f77bcf86cd799439001",
          "orderNumber": "ORD-2024-001234"
        }
      ],
      "customerId": {
        "_id": "507f1f77bcf86cd799439010",
        "shopName": "محل الإلكترونيات",
        "responsiblePersonName": "أحمد محمد",
        "phone": "+966501234567"
      },
      "status": "approved",
      "returnType": "refund",
      "reasonId": {
        "_id": "507f1f77bcf86cd799439011",
        "name": "Defective Product",
        "nameAr": "عيب في المنتج",
        "category": "defective"
      },
      "customerNotes": "الشاشة بها خدوش",
      "customerImages": ["https://example.com/image1.jpg"],
      "totalItemsValue": 500.00,
      "restockingFee": 20.00,
      "shippingDeduction": 0,
      "refundAmount": 480.00,
      "scheduledPickupDate": "2024-01-18T10:00:00Z",
      "approvedAt": "2024-01-16T14:30:00Z",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-16T14:30:00Z"
    },
    "items": [
      {
        "_id": "507f1f77bcf86cd799439015",
        "returnRequestId": "507f1f77bcf86cd799439014",
        "orderItemId": "507f1f77bcf86cd799439012",
        "productId": "507f1f77bcf86cd799439003",
        "productSku": "IPH15PRO-256",
        "productName": "iPhone 15 Pro",
        "productImage": "https://example.com/iphone15pro.jpg",
        "quantity": 1,
        "unitPrice": 500.00,
        "totalValue": 500.00,
        "inspectionStatus": "pending",
        "approvedQuantity": 0,
        "rejectedQuantity": 0
      }
    ]
  },
  "message": "Return retrieved",
  "messageAr": "تم استرجاع طلب الإرجاع"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل طلب إرجاع
Future<ReturnRequest> getReturnById(String returnId) async {
  final response = await _dio.get('/returns/$returnId');
  
  if (response.data['success']) {
    final data = response.data['data'];
    // Response includes both returnRequest and items
    final returnRequest = ReturnRequest.fromJson(data['returnRequest']);
    final items = (data['items'] as List?)
        ?.map((i) => ReturnItem.fromJson(i))
        .toList();
    
    // You can either return returnRequest with items or handle separately
    return returnRequest.copyWith(items: items);
  }
  throw Exception(response.data['messageAr'] ?? response.data['message']);
}
```

---

## 🧩 ReturnsService الكامل

```dart
import 'package:dio/dio.dart';

class ReturnsService {
  final Dio _dio;
  
  ReturnsService(this._dio);
  
  // ═════════════════════════════════════
  // Reasons (Public)
  // ═════════════════════════════════════
  
  Future<List<ReturnReason>> getReasons() async {
    final response = await _dio.get('/returns/reasons');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((r) => ReturnReason.fromJson(r))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // My Returns
  // ═════════════════════════════════════
  
  Future<List<ReturnRequest>> getMyReturns({
    int page = 1,
    int limit = 10,
    ReturnStatus? status,
  }) async {
    final response = await _dio.get('/returns/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((r) => ReturnRequest.fromJson(r))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<ReturnRequest> createReturn({
    required ReturnType returnType,
    required String reasonId,
    required List<ReturnItemRequest> items,
    String? customerNotes,
    List<String>? customerImages,
  }) async {
    final response = await _dio.post('/returns', data: {
      'returnType': returnType.toApiString(),
      'reasonId': reasonId,
      'items': items.map((i) => i.toJson()).toList(),
      if (customerNotes != null) 'customerNotes': customerNotes,
      if (customerImages != null) 'customerImages': customerImages,
    });
    
    if (response.data['success']) {
      return ReturnRequest.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
  
  Future<ReturnRequest> getReturnById(String returnId) async {
    final response = await _dio.get('/returns/$returnId');
    
    if (response.data['success']) {
      final data = response.data['data'];
      final returnRequest = ReturnRequest.fromJson(data['returnRequest']);
      final items = (data['items'] as List?)
          ?.map((i) => ReturnItem.fromJson(i))
          .toList();
      
      return returnRequest.copyWith(items: items);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
}

class ReturnItemRequest {
  final String orderItemId;
  final int quantity;

  ReturnItemRequest({
    required this.orderItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'orderItemId': orderItemId,
    'quantity': quantity,
  };
}
```

---

## 🎯 أمثلة الاستخدام

### شاشة اختيار المنتجات من جميع الطلبات

```dart
class SelectItemsForReturnScreen extends StatefulWidget {
  const SelectItemsForReturnScreen({Key? key}) : super(key: key);

  @override
  State<SelectItemsForReturnScreen> createState() => _SelectItemsForReturnScreenState();
}

class _SelectItemsForReturnScreenState extends State<SelectItemsForReturnScreen> {
  Map<String, int> selectedItems = {}; // orderItemId -> quantity
  List<Order> eligibleOrders = [];
  
  @override
  void initState() {
    super.initState();
    _loadEligibleOrders();
  }
  
  Future<void> _loadEligibleOrders() async {
    // جلب الطلبات المؤهلة للإرجاع
    // status = 'delivered' و تاريخ التسليم خلال فترة الإرجاع
    eligibleOrders = await ordersService.getMyOrders(status: 'delivered');
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختر المنتجات للإرجاع')),
      body: ListView.builder(
        itemCount: eligibleOrders.length,
        itemBuilder: (context, index) {
          final order = eligibleOrders[index];
          return ExpansionTile(
            title: Text('طلب ${order.orderNumber}'),
            subtitle: Text('${order.items.length} منتج'),
            children: order.items.map((item) {
              return CheckboxListTile(
                value: selectedItems.containsKey(item.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedItems[item.id] = item.quantity;
                    } else {
                      selectedItems.remove(item.id);
                    }
                  });
                },
                title: Text(item.productName),
                subtitle: Text('السعر: ${item.unitPrice} ر.س - الكمية: ${item.quantity}'),
                secondary: item.productImage != null 
                    ? Image.network(item.productImage!, width: 50) 
                    : null,
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: selectedItems.isNotEmpty ? SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // تحويل إلى CreateReturnItemRequest
              final items = selectedItems.entries
                  .map((e) => CreateReturnItemRequest(
                        orderItemId: e.key,
                        quantity: e.value,
                      ))
                  .toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateReturnScreen(preSelectedItems: items),
                ),
              );
            },
            child: Text('متابعة (${selectedItems.length} منتج)'),
          ),
        ),
      ) : null,
    );
  }
}
```

### شاشة إنشاء طلب الإرجاع

```dart
class _CreateReturnScreenState extends State<CreateReturnScreen> {
  ReturnReason? selectedReason;
  ReturnType selectedType = ReturnType.refund;
  List<ReturnReason> reasons = [];
  List<String> uploadedImages = [];
  final notesController = TextEditingController();
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadReasons();
  }
  
  Future<void> _loadReasons() async {
    reasons = await returnsService.getReasons();
    setState(() {});
  }
  
  Future<void> _submitReturn() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اختر سبب الإرجاع')),
      );
      return;
    }
    
    if (widget.preSelectedItems == null || widget.preSelectedItems!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد منتجات محددة')),
      );
      return;
    }
    
    if (selectedReason!.requiresPhoto && uploadedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إرفاق صور للمنتج')),
      );
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final result = await returnsService.createReturn(
        // لا يوجد orderId - يُحدد تلقائياً
        returnType: selectedType,
        reasonId: selectedReason!.id,
        items: widget.preSelectedItems!,
        customerNotes: notesController.text.isNotEmpty 
            ? notesController.text 
            : null,
        customerImages: uploadedImages.isNotEmpty 
            ? uploadedImages 
            : null,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReturnSuccessScreen(returnRequest: result),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب إرجاع')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اختيار المنتجات
            Text('اختر المنتجات للإرجاع', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...widget.order.items.map((item) => CheckboxListTile(
              value: selectedItems.containsKey(item.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedItems[item.id] = item.quantity;
                  } else {
                    selectedItems.remove(item.id);
                  }
                });
              },
              title: Text(item.productName),
              subtitle: Text('الكمية: ${item.quantity}'),
              secondary: item.productImage != null 
                  ? Image.network(item.productImage!, width: 50) 
                  : null,
            )),
            
            Divider(height: 32),
            
            // نوع الإرجاع
            Text('نوع الإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReturnType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.displayNameAr),
                  selected: selectedType == type,
                  onSelected: (_) => setState(() => selectedType = type),
                );
              }).toList(),
            ),
            
            SizedBox(height: 16),
            
            // سبب الإرجاع
            Text('سبب الإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<ReturnReason>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'اختر السبب',
              ),
              value: selectedReason,
              items: reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason.getName('ar')),
                );
              }).toList(),
              onChanged: (reason) => setState(() => selectedReason = reason),
            ),
            
            SizedBox(height: 16),
            
            // الصور (إذا مطلوبة)
            if (selectedReason?.requiresPhoto == true) ...[
              Text('صور المنتج (مطلوبة)', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ImageUploader(
                images: uploadedImages,
                onImagesChanged: (images) {
                  setState(() => uploadedImages = images);
                },
              ),
              SizedBox(height: 16),
            ],
            
            // ملاحظات
            Text('ملاحظات إضافية', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'أدخل أي تفاصيل إضافية...',
              ),
            ),
            
            SizedBox(height: 24),
            
            // زر الإرسال
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitReturn,
                child: isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('إرسال طلب الإرجاع'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### عرض حالة طلب الإرجاع

```dart
class ReturnStatusCard extends StatelessWidget {
  final ReturnRequest returnRequest;
  
  const ReturnStatusCard({required this.returnRequest});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${returnRequest.returnNumber}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    returnRequest.status.displayNameAr,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: returnRequest.status.color,
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Timeline
            _buildStatusTimeline(),
            
            SizedBox(height: 12),
            
            // Refund Amount
            if (returnRequest.refundAmount > 0)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مبلغ الاسترداد'),
                    Text(
                      '${returnRequest.refundAmount.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Rejection Reason
            if (returnRequest.status == ReturnStatus.rejected &&
                returnRequest.rejectionReason != null)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        returnRequest.rejectionReason!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusTimeline() {
    final statuses = [
      ReturnStatus.pending,
      ReturnStatus.approved,
      ReturnStatus.pickupScheduled,
      ReturnStatus.pickedUp,
      ReturnStatus.inspecting,
      ReturnStatus.completed,
    ];
    
    final currentIndex = statuses.indexOf(returnRequest.status);
    
    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCompleted ? Colors.green : Colors.grey[300],
                child: isCompleted 
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

---

## 💰 التحويل التلقائي للمحفظة وسداد المديونية

### كيف يعمل؟ (النظام الجديد - أولوية سداد المديونية)

عند معالجة الاسترداد (`processRefund`)، يتم اتباع الأولوية التالية:

1. ✅ **سداد المديونية أولاً**: إذا كان العميل لديه `creditUsed > 0`، يُخصم المبلغ من المديونية
2. ✅ **المتبقي للمحفظة**: أي مبلغ متبقي بعد سداد المديونية يُضاف للمحفظة
3. ✅ يتم تحديث حالة الاسترداد إلى `completed`

### مثال عملي:

#### الحالة 1: عميل لديه مديونية (creditUsed = 100 ريال)
```
المبلغ المسترد: 100 ريال
creditUsed: 100 ريال

النتيجة:
- amountToCreditSettlement: 100 ريال (سداد كامل المديونية)
- amountToWallet: 0 ريال
- creditUsed يصبح: 0 ريال
```

#### الحالة 2: مبلغ الاسترداد أكبر من المديونية
```
المبلغ المسترد: 150 ريال
creditUsed: 100 ريال

النتيجة:
- amountToCreditSettlement: 100 ريال (سداد كامل المديونية)
- amountToWallet: 50 ريال (الباقي للمحفظة)
- creditUsed يصبح: 0 ريال
- walletBalance يزيد: +50 ريال
```

#### الحالة 3: عميل بدون مديونية
```
المبلغ المسترد: 100 ريال
creditUsed: 0 ريال

النتيجة:
- amountToCreditSettlement: 0 ريال
- amountToWallet: 100 ريال (كامل المبلغ للمحفظة)
- walletBalance يزيد: +100 ريال
```

### حقول Refund الجديدة:

```json
{
  "refundNumber": "REF20240116001",
  "amount": 150.00,
  "amountToCreditSettlement": 100.00,
  "amountToWallet": 50.00,
  "refundMethod": "wallet",
  "status": "completed"
}
```

### مثال على Transaction للمحفظة:

```dart
{
  "transactionNumber": "WTX20240116001",
  "transactionType": "order_refund",
  "amount": 50.00,  // المبلغ المتبقي بعد سداد المديونية
  "direction": "credit",
  "balanceBefore": 100.00,
  "balanceAfter": 150.00,
  "referenceType": "refund",
  "referenceId": "refund_id_here",
  "referenceNumber": "REF20240116001",
  "description": "Refund for return request",
  "descriptionAr": "استرداد مبلغ المرتجع RET-2024-001234",
  "status": "completed"
}
```

### عرض في التطبيق:

```dart
// يمكن للعميل رؤية رصيده المحدث فوراً
final wallet = await walletService.getBalance();
print('رصيد المحفظة: ${wallet.balance} ر.س');

// رؤية المديونية (إذا كانت موجودة)
final customer = await customerService.getProfile();
print('المديونية: ${customer.creditUsed} ر.س');
print('الائتمان المتاح: ${customer.availableCredit} ر.س');

// رؤية سجل المعاملات
final transactions = await walletService.getTransactions();
// سيظهر معاملة order_refund مع رقم المرتجع
```

---

## 🔢 حساب الأسعار والفواتير التلقائي

### المزايا:
- ✅ **الأمان**: لا يمكن للعميل التلاعب بالأسعار
- ✅ **الدقة**: الأسعار من الفواتير الأصلية دائماً
- ✅ **التبسيط**: لا حاجة لإرسال أسعار أو معرفات فواتير
- ✅ **المرونة**: دعم الإرجاع من عدة فواتير في طلب واحد

### كيف يعمل؟

```javascript
// 1. العميل يرسل فقط orderItemId و quantity
{
  "items": [
    {
      "orderItemId": "507f1f77bcf86cd799439012",
      "quantity": 1
    },
    {
      "orderItemId": "507f1f77bcf86cd799439013",  // من فاتورة أخرى
      "quantity": 2
    }
  ]
}

// 2. Backend يجلب OrderItems من قاعدة البيانات
const orderItems = await OrderItem.find({
  _id: { $in: orderItemIds }
}).populate('orderId');

// 3. يستخرج معرفات الفواتير تلقائياً
const orderIds = [...new Set(orderItems.map(i => i.orderId._id))];
// Result: ["507f1f77bcf86cd799439001", "507f1f77bcf86cd799439002"]

// 4. يحسب القيمة الإجمالية من الأسعار الفعلية
const totalItemsValue = items.reduce((sum, item) => {
  const orderItem = orderItems.find(oi => oi._id === item.orderItemId);
  return sum + (item.quantity * orderItem.unitPrice);
}, 0);

// 5. ينشئ ReturnItems بالبيانات من الفواتير
const returnItems = items.map(item => {
  const orderItem = orderItems.find(oi => oi._id === item.orderItemId);
  return {
    orderItemId: item.orderItemId,
    productId: orderItem.productId,
    productSku: orderItem.productSku,
    productName: orderItem.productName,
    productImage: orderItem.productImage,
    quantity: item.quantity,
    unitPrice: orderItem.unitPrice,  // من الفاتورة
    totalValue: item.quantity * orderItem.unitPrice
  };
});

// 6. ينشئ ReturnRequest مع orderIds المستخرجة
const returnRequest = {
  returnNumber: "RET-2024-001234",
  orderIds: ["507f1f77bcf86cd799439001", "507f1f77bcf86cd799439002"],
  customerId: "507f1f77bcf86cd799439010",
  totalItemsValue: 750.00,
  // ... بقية البيانات
};
```

### Validations تتم تلقائياً:
- ✅ التحقق من وجود OrderItems
- ✅ التحقق من أن الكمية المطلوب إرجاعها <= الكمية المطلوبة
- ✅ التحقق من ملكية العميل للفواتير
- ✅ حساب القيمة الإجمالية بدقة

---

## ⚠️ الأخطاء المحتملة

| HTTP Code | Message | الوصف |
|-----------|---------|-------|
| `400` | Some order items not found | بعض عناصر الطلب غير موجودة |
| `400` | Return quantity exceeds ordered quantity | الكمية المطلوب إرجاعها تتجاوز الكمية المطلوبة |
| `400` | Invalid return quantity | كمية غير صالحة |
| `400` | Photos are required for this reason | الصور مطلوبة لهذا السبب |
| `404` | Return request not found | طلب الإرجاع غير موجود |
| `404` | Order item not found | عنصر الطلب غير موجود |
| `401` | Unauthorized | غير مصرح - تحتاج لتسجيل الدخول |
| `403` | Forbidden | ممنوع - ليس لديك صلاحية |

### مثال على معالجة الأخطاء:

```dart
try {
  final returnRequest = await returnsService.createReturn(
    returnType: ReturnType.refund,
    reasonId: selectedReason.id,
    items: selectedItems,
  );
  
  // نجح الطلب
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReturnSuccessScreen(returnRequest: returnRequest),
    ),
  );
} on DioException catch (e) {
  String errorMessage = 'حدث خطأ غير متوقع';
  
  if (e.response != null) {
    final statusCode = e.response!.statusCode;
    final data = e.response!.data;
    
    switch (statusCode) {
      case 400:
        errorMessage = data['messageAr'] ?? data['message'] ?? 'بيانات غير صحيحة';
        break;
      case 401:
        errorMessage = 'يرجى تسجيل الدخول أولاً';
        // Redirect to login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      case 404:
        errorMessage = 'العنصر المطلوب غير موجود';
        break;
      default:
        errorMessage = data['messageAr'] ?? data['message'] ?? 'حدث خطأ في السيرفر';
    }
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('حدث خطأ: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 📝 ملخص الـ Endpoints

### Customer Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/returns/reasons` | ❌ | أسباب الإرجاع (Public) |
| GET | `/returns/my` | ✅ | طلبات الإرجاع الخاصة بي |
| POST | `/returns` | ✅ | إنشاء طلب إرجاع جديد |
| GET | `/returns/:id` | ✅ | تفاصيل طلب إرجاع |

### Admin Endpoints (للتوثيق فقط)

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/returns` | Admin | جميع طلبات الإرجاع |
| PUT | `/returns/:id/status` | Admin | تحديث حالة طلب الإرجاع |
| PUT | `/returns/items/:itemId/inspect` | Admin | فحص عنصر مرتجع |
| POST | `/returns/:id/refund` | Admin | معالجة الاسترداد |
| PUT | `/returns/refunds/:refundId/complete` | Admin | إكمال الاسترداد |

---

> 🔗 **السابق:** [locations.md](./locations.md) - دليل المواقع  
> 🔗 **التالي:** [promotions.md](./promotions.md) - دليل العروض والكوبونات
