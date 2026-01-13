# 💰 Wallet & Loyalty Module - دليل ربط المحفظة والولاء

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ رصيد المحفظة (Wallet Balance)
- ✅ معاملات المحفظة (Wallet Transactions)
- ✅ نقاط الولاء (Loyalty Points)
- ✅ مستويات الولاء (Loyalty Tiers)
- ✅ معاملات النقاط (Points Transactions)

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒 باستثناء `GET /wallet/tiers`

---

## 📁 Flutter Models

### WalletBalance Model

```dart
class WalletBalance {
  final double balance;
  
  WalletBalance({required this.balance});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}
```

### WalletTransaction Model

```dart
class WalletTransaction {
  final String id;
  final String transactionNumber;
  final String customerId;
  final WalletTransactionType transactionType;
  final double amount;
  final TransactionDirection direction;
  final double balanceBefore;
  final double balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String? referenceNumber;
  final String? paymentMethod;
  final WalletTransactionStatus status;
  final String? description;
  final String? descriptionAr;
  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.transactionNumber,
    required this.customerId,
    required this.transactionType,
    required this.amount,
    required this.direction,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.referenceNumber,
    this.paymentMethod,
    required this.status,
    this.description,
    this.descriptionAr,
    this.expiresAt,
    required this.isExpired,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'] ?? json['id'],
      transactionNumber: json['transactionNumber'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      transactionType: WalletTransactionType.fromString(json['transactionType']),
      amount: (json['amount'] ?? 0).toDouble(),
      direction: TransactionDirection.fromString(json['direction']),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
      referenceNumber: json['referenceNumber'],
      paymentMethod: json['paymentMethod'],
      status: WalletTransactionStatus.fromString(json['status']),
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      isExpired: json['isExpired'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// الحصول على الوصف حسب اللغة
  String getDescription(String locale) => 
      locale == 'ar' ? (descriptionAr ?? description ?? '') : (description ?? '');
  
  /// هل هي إضافة للرصيد؟
  bool get isCredit => direction == TransactionDirection.credit;
}
```

### LoyaltyPoints Model

```dart
class LoyaltyPoints {
  final int points;
  final LoyaltyTier tier;
  final List<ExpiringPoints> expiringPoints;
  final int expiringTotal;

  LoyaltyPoints({
    required this.points,
    required this.tier,
    required this.expiringPoints,
    required this.expiringTotal,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      points: json['points'] ?? 0,
      tier: LoyaltyTier.fromJson(json['tier']),
      expiringPoints: (json['expiringPoints'] as List? ?? [])
          .map((e) => ExpiringPoints.fromJson(e))
          .toList(),
      expiringTotal: json['expiringTotal'] ?? 0,
    );
  }
}

class ExpiringPoints {
  final int remainingPoints;
  final DateTime expiresAt;

  ExpiringPoints({
    required this.remainingPoints,
    required this.expiresAt,
  });

  factory ExpiringPoints.fromJson(Map<String, dynamic> json) {
    return ExpiringPoints(
      remainingPoints: json['remainingPoints'] ?? 0,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
  
  /// عدد الأيام المتبقية
  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;
}
```

### LoyaltyTier Model

```dart
class LoyaltyTier {
  final String id;
  final String name;
  final String nameAr;
  final String code;
  final String? description;
  final String? descriptionAr;
  final int minPoints;
  final double? minSpend;
  final int? minOrders;
  final double pointsMultiplier;
  final double discountPercentage;
  final bool freeShipping;
  final bool prioritySupport;
  final bool earlyAccess;
  final List<String>? customBenefits;
  final String? icon;
  final String? color;
  final String? badgeImage;
  final int displayOrder;
  final bool isActive;

  LoyaltyTier({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    required this.minPoints,
    this.minSpend,
    this.minOrders,
    required this.pointsMultiplier,
    required this.discountPercentage,
    required this.freeShipping,
    required this.prioritySupport,
    required this.earlyAccess,
    this.customBenefits,
    this.icon,
    this.color,
    this.badgeImage,
    required this.displayOrder,
    required this.isActive,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      minPoints: json['minPoints'] ?? 0,
      minSpend: json['minSpend']?.toDouble(),
      minOrders: json['minOrders'],
      pointsMultiplier: (json['pointsMultiplier'] ?? 1).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      freeShipping: json['freeShipping'] ?? false,
      prioritySupport: json['prioritySupport'] ?? false,
      earlyAccess: json['earlyAccess'] ?? false,
      customBenefits: json['customBenefits'] != null 
          ? List<String>.from(json['customBenefits']) 
          : null,
      icon: json['icon'],
      color: json['color'],
      badgeImage: json['badgeImage'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
  
  /// تحويل اللون hex إلى Color
  Color? getColor() {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### LoyaltyTransaction Model

```dart
class LoyaltyTransaction {
  final String id;
  final String transactionNumber;
  final String customerId;
  final LoyaltyTransactionType transactionType;
  final int points;
  final PointsDirection direction;
  final int pointsBefore;
  final int pointsAfter;
  final String? referenceType;
  final String? referenceId;
  final String? referenceNumber;
  final double? orderAmount;
  final double? multiplier;
  final double? redeemedValue;
  final String? description;
  final String? descriptionAr;
  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.transactionNumber,
    required this.customerId,
    required this.transactionType,
    required this.points,
    required this.direction,
    required this.pointsBefore,
    required this.pointsAfter,
    this.referenceType,
    this.referenceId,
    this.referenceNumber,
    this.orderAmount,
    this.multiplier,
    this.redeemedValue,
    this.description,
    this.descriptionAr,
    this.expiresAt,
    required this.isExpired,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['_id'] ?? json['id'],
      transactionNumber: json['transactionNumber'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      transactionType: LoyaltyTransactionType.fromString(json['transactionType']),
      points: json['points'] ?? 0,
      direction: PointsDirection.fromString(json['direction']),
      pointsBefore: json['pointsBefore'] ?? 0,
      pointsAfter: json['pointsAfter'] ?? 0,
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
      referenceNumber: json['referenceNumber'],
      orderAmount: json['orderAmount']?.toDouble(),
      multiplier: json['multiplier']?.toDouble(),
      redeemedValue: json['redeemedValue']?.toDouble(),
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      isExpired: json['isExpired'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// هل هي نقاط مكتسبة؟
  bool get isEarned => direction == PointsDirection.earn;
  
  /// الحصول على الوصف حسب اللغة
  String getDescription(String locale) => 
      locale == 'ar' ? (descriptionAr ?? description ?? '') : (description ?? '');
}
```

### Enums

```dart
/// أنواع معاملات المحفظة
enum WalletTransactionType {
  orderPayment,      // دفع طلب من المحفظة
  orderRefund,       // استرداد مبلغ طلب
  walletTopup,       // شحن المحفظة
  walletWithdrawal,  // سحب من المحفظة
  referralReward,    // مكافأة إحالة
  loyaltyReward,     // مكافأة ولاء
  adminCredit,       // إضافة من الإدارة
  adminDebit,        // خصم من الإدارة
  expiredBalance;    // رصيد منتهي

  static WalletTransactionType fromString(String value) {
    switch (value) {
      case 'order_payment': return WalletTransactionType.orderPayment;
      case 'order_refund': return WalletTransactionType.orderRefund;
      case 'wallet_topup': return WalletTransactionType.walletTopup;
      case 'wallet_withdrawal': return WalletTransactionType.walletWithdrawal;
      case 'referral_reward': return WalletTransactionType.referralReward;
      case 'loyalty_reward': return WalletTransactionType.loyaltyReward;
      case 'admin_credit': return WalletTransactionType.adminCredit;
      case 'admin_debit': return WalletTransactionType.adminDebit;
      case 'expired_balance': return WalletTransactionType.expiredBalance;
      default: return WalletTransactionType.orderPayment;
    }
  }

  String get displayNameAr {
    switch (this) {
      case WalletTransactionType.orderPayment: return 'دفع طلب';
      case WalletTransactionType.orderRefund: return 'استرداد';
      case WalletTransactionType.walletTopup: return 'شحن رصيد';
      case WalletTransactionType.walletWithdrawal: return 'سحب';
      case WalletTransactionType.referralReward: return 'مكافأة إحالة';
      case WalletTransactionType.loyaltyReward: return 'مكافأة ولاء';
      case WalletTransactionType.adminCredit: return 'إضافة إدارية';
      case WalletTransactionType.adminDebit: return 'خصم إداري';
      case WalletTransactionType.expiredBalance: return 'رصيد منتهي';
    }
  }
}

/// اتجاه المعاملة
enum TransactionDirection {
  credit,  // إضافة
  debit;   // خصم

  static TransactionDirection fromString(String value) {
    return TransactionDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionDirection.credit,
    );
  }
}

/// حالة معاملة المحفظة
enum WalletTransactionStatus {
  pending,
  completed,
  failed,
  cancelled;

  static WalletTransactionStatus fromString(String value) {
    return WalletTransactionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WalletTransactionStatus.completed,
    );
  }

  String get displayNameAr {
    switch (this) {
      case WalletTransactionStatus.pending: return 'قيد الانتظار';
      case WalletTransactionStatus.completed: return 'مكتملة';
      case WalletTransactionStatus.failed: return 'فاشلة';
      case WalletTransactionStatus.cancelled: return 'ملغاة';
    }
  }
}

/// أنواع معاملات نقاط الولاء
enum LoyaltyTransactionType {
  orderEarn,      // كسب من طلب
  orderRedeem,    // استخدام في طلب
  orderCancel,    // إلغاء نقاط طلب
  signupBonus,    // مكافأة التسجيل
  referralEarn,   // كسب من إحالة
  birthdayBonus,  // مكافأة عيد الميلاد
  tierUpgrade,    // مكافأة ترقية المستوى
  adminGrant,     // إضافة من الإدارة
  adminDeduct,    // خصم من الإدارة
  pointsExpiry,   // انتهاء صلاحية النقاط
  transferOut,    // تحويل لعميل آخر
  transferIn;     // استلام تحويل

  static LoyaltyTransactionType fromString(String value) {
    switch (value) {
      case 'order_earn': return LoyaltyTransactionType.orderEarn;
      case 'order_redeem': return LoyaltyTransactionType.orderRedeem;
      case 'order_cancel': return LoyaltyTransactionType.orderCancel;
      case 'signup_bonus': return LoyaltyTransactionType.signupBonus;
      case 'referral_earn': return LoyaltyTransactionType.referralEarn;
      case 'birthday_bonus': return LoyaltyTransactionType.birthdayBonus;
      case 'tier_upgrade': return LoyaltyTransactionType.tierUpgrade;
      case 'admin_grant': return LoyaltyTransactionType.adminGrant;
      case 'admin_deduct': return LoyaltyTransactionType.adminDeduct;
      case 'points_expiry': return LoyaltyTransactionType.pointsExpiry;
      case 'transfer_out': return LoyaltyTransactionType.transferOut;
      case 'transfer_in': return LoyaltyTransactionType.transferIn;
      default: return LoyaltyTransactionType.orderEarn;
    }
  }

  String get displayNameAr {
    switch (this) {
      case LoyaltyTransactionType.orderEarn: return 'كسب من طلب';
      case LoyaltyTransactionType.orderRedeem: return 'استخدام في طلب';
      case LoyaltyTransactionType.orderCancel: return 'إلغاء نقاط';
      case LoyaltyTransactionType.signupBonus: return 'مكافأة تسجيل';
      case LoyaltyTransactionType.referralEarn: return 'مكافأة إحالة';
      case LoyaltyTransactionType.birthdayBonus: return 'مكافأة عيد ميلاد';
      case LoyaltyTransactionType.tierUpgrade: return 'ترقية مستوى';
      case LoyaltyTransactionType.adminGrant: return 'إضافة إدارية';
      case LoyaltyTransactionType.adminDeduct: return 'خصم إداري';
      case LoyaltyTransactionType.pointsExpiry: return 'انتهاء صلاحية';
      case LoyaltyTransactionType.transferOut: return 'تحويل صادر';
      case LoyaltyTransactionType.transferIn: return 'تحويل وارد';
    }
  }
}

/// اتجاه النقاط
enum PointsDirection {
  earn,    // كسب
  redeem,  // استخدام
  expire,  // انتهاء
  adjust;  // تعديل

  static PointsDirection fromString(String value) {
    return PointsDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PointsDirection.earn,
    );
  }
}
```

---

## 📞 API Endpoints

### 💰 Wallet

#### 1️⃣ جلب رصيد المحفظة

**Endpoint:** `GET /wallet/balance`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "balance": 2500.00
  },
  "message": "Balance retrieved",
  "messageAr": "تم استرجاع الرصيد"
}
```

**Flutter Code:**
```dart
class WalletService {
  final Dio _dio;
  
  WalletService(this._dio);
  
  /// جلب رصيد المحفظة
  Future<double> getBalance() async {
    final response = await _dio.get('/wallet/balance');
    
    if (response.data['success']) {
      return (response.data['data']['balance'] ?? 0).toDouble();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 2️⃣ جلب معاملات المحفظة

**Endpoint:** `GET /wallet/transactions`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة |
| `limit` | number | ❌ | عدد النتائج |
| `transactionType` | string | ❌ | فلترة بنوع المعاملة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "transactionNumber": "WLT-2024-001234",
      "transactionType": "order_refund",
      "amount": 150.00,
      "direction": "credit",
      "balanceBefore": 2350.00,
      "balanceAfter": 2500.00,
      "referenceType": "order",
      "referenceNumber": "ORD-2024-001234",
      "status": "completed",
      "description": "Refund for order #ORD-2024-001234",
      "descriptionAr": "استرداد للطلب #ORD-2024-001234",
      "createdAt": "2024-01-15T10:30:00Z",
      ...
    }
  ],
  "message": "Transactions retrieved",
  "messageAr": "تم استرجاع المعاملات"
}
```

**Flutter Code:**
```dart
/// جلب معاملات المحفظة
Future<List<WalletTransaction>> getTransactions({
  int page = 1,
  int limit = 20,
  WalletTransactionType? transactionType,
}) async {
  final response = await _dio.get('/wallet/transactions', queryParameters: {
    'page': page,
    'limit': limit,
    if (transactionType != null) 'transactionType': transactionType.name,
  });
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((t) => WalletTransaction.fromJson(t))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

### ⭐ Loyalty Points

#### 3️⃣ جلب نقاط الولاء

**Endpoint:** `GET /wallet/points`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "points": 1250,
    "tier": {
      "_id": "...",
      "name": "Gold",
      "nameAr": "ذهبي",
      "code": "gold",
      "minPoints": 1000,
      "pointsMultiplier": 1.5,
      "discountPercentage": 5,
      "freeShipping": true,
      "color": "#FFD700",
      ...
    },
    "expiringPoints": [
      {
        "remainingPoints": 200,
        "expiresAt": "2024-03-01T00:00:00Z"
      }
    ],
    "expiringTotal": 200
  },
  "message": "Points retrieved",
  "messageAr": "تم استرجاع النقاط"
}
```

**Flutter Code:**
```dart
/// جلب نقاط الولاء مع معلومات المستوى
Future<LoyaltyPoints> getPoints() async {
  final response = await _dio.get('/wallet/points');
  
  if (response.data['success']) {
    return LoyaltyPoints.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 4️⃣ جلب معاملات النقاط

**Endpoint:** `GET /wallet/points/transactions`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "transactionNumber": "LYL-2024-001234",
      "transactionType": "order_earn",
      "points": 125,
      "direction": "earn",
      "pointsBefore": 1125,
      "pointsAfter": 1250,
      "referenceType": "order",
      "referenceNumber": "ORD-2024-001234",
      "orderAmount": 1250.00,
      "multiplier": 1.5,
      "description": "Points earned from order #ORD-2024-001234",
      "descriptionAr": "نقاط مكتسبة من الطلب #ORD-2024-001234",
      "createdAt": "2024-01-15T10:30:00Z",
      ...
    }
  ],
  "message": "Transactions retrieved",
  "messageAr": "تم استرجاع المعاملات"
}
```

**Flutter Code:**
```dart
/// جلب معاملات نقاط الولاء
Future<List<LoyaltyTransaction>> getPointsTransactions() async {
  final response = await _dio.get('/wallet/points/transactions');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((t) => LoyaltyTransaction.fromJson(t))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ جلب مستويات الولاء

**Endpoint:** `GET /wallet/tiers` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Bronze",
      "nameAr": "برونزي",
      "code": "bronze",
      "minPoints": 0,
      "pointsMultiplier": 1,
      "discountPercentage": 0,
      "freeShipping": false,
      "prioritySupport": false,
      "color": "#CD7F32",
      ...
    },
    {
      "_id": "...",
      "name": "Silver",
      "nameAr": "فضي",
      "code": "silver",
      "minPoints": 500,
      "pointsMultiplier": 1.25,
      "discountPercentage": 2,
      "freeShipping": false,
      "color": "#C0C0C0",
      ...
    },
    {
      "_id": "...",
      "name": "Gold",
      "nameAr": "ذهبي",
      "code": "gold",
      "minPoints": 1000,
      "pointsMultiplier": 1.5,
      "discountPercentage": 5,
      "freeShipping": true,
      "color": "#FFD700",
      ...
    },
    {
      "_id": "...",
      "name": "Platinum",
      "nameAr": "بلاتيني",
      "code": "platinum",
      "minPoints": 2500,
      "pointsMultiplier": 2,
      "discountPercentage": 10,
      "freeShipping": true,
      "prioritySupport": true,
      "earlyAccess": true,
      "color": "#E5E4E2",
      ...
    }
  ],
  "message": "Tiers retrieved",
  "messageAr": "تم استرجاع المستويات"
}
```

**Flutter Code:**
```dart
/// جلب مستويات برنامج الولاء
Future<List<LoyaltyTier>> getTiers() async {
  final response = await _dio.get('/wallet/tiers');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((t) => LoyaltyTier.fromJson(t))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

## 🧩 WalletService الكامل

```dart
import 'package:dio/dio.dart';

class WalletService {
  final Dio _dio;
  
  WalletService(this._dio);
  
  // ═════════════════════════════════════
  // Wallet
  // ═════════════════════════════════════
  
  Future<double> getBalance() async {
    final response = await _dio.get('/wallet/balance');
    
    if (response.data['success']) {
      return (response.data['data']['balance'] ?? 0).toDouble();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) async {
    final response = await _dio.get('/wallet/transactions', queryParameters: {
      'page': page,
      'limit': limit,
      if (transactionType != null) 'transactionType': transactionType.name,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((t) => WalletTransaction.fromJson(t))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Loyalty
  // ═════════════════════════════════════
  
  Future<LoyaltyPoints> getPoints() async {
    final response = await _dio.get('/wallet/points');
    
    if (response.data['success']) {
      return LoyaltyPoints.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<LoyaltyTransaction>> getPointsTransactions() async {
    final response = await _dio.get('/wallet/points/transactions');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((t) => LoyaltyTransaction.fromJson(t))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<LoyaltyTier>> getTiers() async {
    final response = await _dio.get('/wallet/tiers');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((t) => LoyaltyTier.fromJson(t))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🎯 أمثلة الاستخدام

### عرض بطاقة المحفظة

```dart
class WalletCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: walletService.getBalance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رصيد المحفظة', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.data!.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### عرض بطاقة نقاط الولاء

```dart
class LoyaltyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoyaltyPoints>(
      future: walletService.getPoints(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return Card(
            color: data.tier.getColor(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // شارة المستوى
                  Row(
                    children: [
                      if (data.tier.badgeImage != null)
                        Image.network(data.tier.badgeImage!, width: 40),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.tier.getName('ar'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('x${data.tier.pointsMultiplier} نقاط'),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // النقاط
                  Text(
                    '${data.points}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('نقطة'),
                  
                  // نقاط ستنتهي صلاحيتها
                  if (data.expiringTotal > 0) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${data.expiringTotal} نقطة ستنتهي قريباً',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                  
                  // المزايا
                  if (data.tier.freeShipping)
                    Chip(label: Text('شحن مجاني')),
                  if (data.tier.discountPercentage > 0)
                    Chip(label: Text('خصم ${data.tier.discountPercentage}%')),
                ],
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### عرض مستويات الولاء

```dart
class LoyaltyTiersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoyaltyTier>>(
      future: walletService.getTiers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tier = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tier.getColor(),
                    child: Text(tier.name[0]),
                  ),
                  title: Text(tier.getName('ar')),
                  subtitle: Text('${tier.minPoints}+ نقطة'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('x${tier.pointsMultiplier}'),
                      if (tier.freeShipping)
                        Icon(Icons.local_shipping, size: 16),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/wallet/balance` | ✅ | رصيد المحفظة |
| GET | `/wallet/transactions` | ✅ | معاملات المحفظة |
| GET | `/wallet/points` | ✅ | نقاط الولاء والمستوى |
| GET | `/wallet/points/transactions` | ✅ | معاملات النقاط |
| GET | `/wallet/tiers` | ❌ | مستويات الولاء (Public) |

---

> 🔗 **السابق:** [customers.md](./customers.md) - دليل العملاء  
> 🔗 **التالي:** [locations.md](./locations.md) - دليل المواقع
