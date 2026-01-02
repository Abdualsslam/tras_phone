# 👥 Customers Module - دليل ربط العملاء

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ ملف العميل (Customer Profile)
- ✅ العناوين (Addresses)
- ✅ نظام الولاء (Loyalty)
- ✅ نظام الإحالة (Referrals)
- ✅ المحفظة (Wallet)

> **ملاحظة**: هذا التوثيق مخصص لتطبيق العميل (Customer App).  
> جميع الـ endpoints هنا تحتاج **Token** 🔒

---

## 📁 Flutter Models

### Customer Model

```dart
class Customer {
  final String id;
  final String userId;
  final String customerCode;
  
  // معلومات العمل
  final String responsiblePersonName;
  final String shopName;
  final String? shopNameAr;
  final BusinessType businessType;
  
  // الموقع
  final String cityId;
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;
  
  // التسعير والائتمان
  final String priceLevelId;
  final double creditLimit;
  final double creditUsed;
  double get availableCredit => creditLimit - creditUsed;
  
  // المحفظة
  final double walletBalance;
  
  // الولاء
  final int loyaltyPoints;
  final LoyaltyTier loyaltyTier;
  
  // الإحصائيات
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final DateTime? lastOrderAt;
  
  // التفضيلات
  final PaymentMethod? preferredPaymentMethod;
  final String? preferredShippingTime;
  final ContactMethod preferredContactMethod;
  
  // التواصل الاجتماعي
  final String? instagramHandle;
  final String? twitterHandle;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.userId,
    required this.customerCode,
    required this.responsiblePersonName,
    required this.shopName,
    this.shopNameAr,
    required this.businessType,
    required this.cityId,
    this.marketId,
    this.address,
    this.latitude,
    this.longitude,
    required this.priceLevelId,
    required this.creditLimit,
    required this.creditUsed,
    required this.walletBalance,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    this.lastOrderAt,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    required this.preferredContactMethod,
    this.instagramHandle,
    this.twitterHandle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] is String 
          ? json['userId'] 
          : json['userId']['_id'],
      customerCode: json['customerCode'],
      responsiblePersonName: json['responsiblePersonName'],
      shopName: json['shopName'],
      shopNameAr: json['shopNameAr'],
      businessType: BusinessType.fromString(json['businessType']),
      cityId: json['cityId'] is String 
          ? json['cityId'] 
          : json['cityId']['_id'],
      marketId: json['marketId'] is String 
          ? json['marketId'] 
          : json['marketId']?['_id'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      priceLevelId: json['priceLevelId'] is String 
          ? json['priceLevelId'] 
          : json['priceLevelId']['_id'],
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      creditUsed: (json['creditUsed'] ?? 0).toDouble(),
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      loyaltyTier: LoyaltyTier.fromString(json['loyaltyTier']),
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      lastOrderAt: json['lastOrderAt'] != null 
          ? DateTime.parse(json['lastOrderAt']) 
          : null,
      preferredPaymentMethod: json['preferredPaymentMethod'] != null
          ? PaymentMethod.fromString(json['preferredPaymentMethod'])
          : null,
      preferredShippingTime: json['preferredShippingTime'],
      preferredContactMethod: ContactMethod.fromString(
          json['preferredContactMethod'] ?? 'whatsapp'),
      instagramHandle: json['instagramHandle'],
      twitterHandle: json['twitterHandle'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  /// الحصول على اسم المحل حسب اللغة
  String getShopName(String locale) => 
      locale == 'ar' && shopNameAr != null ? shopNameAr! : shopName;
}
```

### Enums

```dart
enum BusinessType {
  shop,
  technician,
  distributor,
  other;
  
  static BusinessType fromString(String value) {
    return BusinessType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BusinessType.shop,
    );
  }
  
  String get displayName {
    switch (this) {
      case BusinessType.shop: return 'متجر';
      case BusinessType.technician: return 'فني';
      case BusinessType.distributor: return 'موزع';
      case BusinessType.other: return 'آخر';
    }
  }
}

enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum;
  
  static LoyaltyTier fromString(String value) {
    return LoyaltyTier.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoyaltyTier.bronze,
    );
  }
  
  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze: return 'برونزي';
      case LoyaltyTier.silver: return 'فضي';
      case LoyaltyTier.gold: return 'ذهبي';
      case LoyaltyTier.platinum: return 'بلاتيني';
    }
  }
  
  Color get color {
    switch (this) {
      case LoyaltyTier.bronze: return const Color(0xFFCD7F32);
      case LoyaltyTier.silver: return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold: return const Color(0xFFFFD700);
      case LoyaltyTier.platinum: return const Color(0xFFE5E4E2);
    }
  }
}

enum PaymentMethod {
  cod,
  bankTransfer,
  wallet;
  
  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'cod': return PaymentMethod.cod;
      case 'bank_transfer': return PaymentMethod.bankTransfer;
      case 'wallet': return PaymentMethod.wallet;
      default: return PaymentMethod.cod;
    }
  }
  
  String get value {
    switch (this) {
      case PaymentMethod.cod: return 'cod';
      case PaymentMethod.bankTransfer: return 'bank_transfer';
      case PaymentMethod.wallet: return 'wallet';
    }
  }
  
  String get displayName {
    switch (this) {
      case PaymentMethod.cod: return 'الدفع عند الاستلام';
      case PaymentMethod.bankTransfer: return 'تحويل بنكي';
      case PaymentMethod.wallet: return 'المحفظة';
    }
  }
}

enum ContactMethod {
  phone,
  whatsapp,
  email;
  
  static ContactMethod fromString(String value) {
    return ContactMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContactMethod.whatsapp,
    );
  }
}
```

### CustomerAddress Model

```dart
class CustomerAddress {
  final String id;
  final String customerId;
  final String label;
  final String? recipientName;
  final String? phone;
  final String cityId;
  final String? marketId;
  final String addressLine;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // يمكن تعبئتها إذا تم populate
  City? city;

  CustomerAddress({
    required this.id,
    required this.customerId,
    required this.label,
    this.recipientName,
    this.phone,
    required this.cityId,
    this.marketId,
    required this.addressLine,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.city,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      label: json['label'],
      recipientName: json['recipientName'],
      phone: json['phone'],
      cityId: json['cityId'] is String 
          ? json['cityId'] 
          : json['cityId']['_id'],
      marketId: json['marketId'] is String 
          ? json['marketId'] 
          : json['marketId']?['_id'],
      addressLine: json['addressLine'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      city: json['cityId'] is Map ? City.fromJson(json['cityId']) : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'label': label,
      if (recipientName != null) 'recipientName': recipientName,
      if (phone != null) 'phone': phone,
      'cityId': cityId,
      if (marketId != null) 'marketId': marketId,
      'addressLine': addressLine,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
```

### Referral Model

```dart
enum ReferralStatus {
  pending,
  completed,
  expired,
  cancelled;
  
  static ReferralStatus fromString(String value) {
    return ReferralStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReferralStatus.pending,
    );
  }
}

class Referral {
  final String id;
  final String referrerId;
  final String referredId;
  final String referralCode;
  final ReferralStatus status;
  final double? referrerRewardAmount;
  final double? referredRewardAmount;
  final DateTime? referrerRewardedAt;
  final DateTime? referredRewardedAt;
  final double? minOrderAmount;
  final String? qualifyingOrderId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // يمكن تعبئتها إذا تم populate
  Customer? referrer;
  Customer? referred;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    required this.status,
    this.referrerRewardAmount,
    this.referredRewardAmount,
    this.referrerRewardedAt,
    this.referredRewardedAt,
    this.minOrderAmount,
    this.qualifyingOrderId,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.referrer,
    this.referred,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['_id'] ?? json['id'],
      referrerId: json['referrerId'] is String 
          ? json['referrerId'] 
          : json['referrerId']['_id'],
      referredId: json['referredId'] is String 
          ? json['referredId'] 
          : json['referredId']['_id'],
      referralCode: json['referralCode'],
      status: ReferralStatus.fromString(json['status']),
      referrerRewardAmount: json['referrerRewardAmount']?.toDouble(),
      referredRewardAmount: json['referredRewardAmount']?.toDouble(),
      referrerRewardedAt: json['referrerRewardedAt'] != null 
          ? DateTime.parse(json['referrerRewardedAt']) 
          : null,
      referredRewardedAt: json['referredRewardedAt'] != null 
          ? DateTime.parse(json['referredRewardedAt']) 
          : null,
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      qualifyingOrderId: json['qualifyingOrderId'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      referrer: json['referrerId'] is Map 
          ? Customer.fromJson(json['referrerId']) 
          : null,
      referred: json['referredId'] is Map 
          ? Customer.fromJson(json['referredId']) 
          : null,
    );
  }
  
  /// هل الإحالة فعالة؟
  bool get isActive => 
      status == ReferralStatus.pending && 
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}
```

---

## 📞 API Endpoints

### 👤 ملف العميل

#### 1️⃣ جلب ملف العميل الحالي

**Endpoint:** `GET /customers/:customerId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "...",
    "customerCode": "CUST-001234",
    "responsiblePersonName": "أحمد محمد",
    "shopName": "Tech Mobile",
    "shopNameAr": "تك موبايل",
    "businessType": "shop",
    "cityId": { "_id": "...", "name": "Riyadh", "nameAr": "الرياض" },
    "priceLevelId": "...",
    "creditLimit": 50000,
    "creditUsed": 15000,
    "walletBalance": 2500,
    "loyaltyPoints": 1250,
    "loyaltyTier": "gold",
    "totalOrders": 45,
    "totalSpent": 125000,
    "averageOrderValue": 2778,
    "lastOrderAt": "2024-01-10T...",
    "preferredPaymentMethod": "wallet",
    "preferredContactMethod": "whatsapp",
    ...
  },
  "message": "Customer retrieved successfully",
  "messageAr": "تم استرجاع العميل بنجاح"
}
```

**Flutter Code:**
```dart
class CustomerService {
  final Dio _dio;
  
  CustomerService(this._dio);
  
  /// جلب ملف العميل
  Future<Customer> getProfile(String customerId) async {
    final response = await _dio.get('/customers/$customerId');
    
    if (response.data['success']) {
      return Customer.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

### 📍 العناوين

#### 2️⃣ جلب عناوين العميل

**Endpoint:** `GET /customers/:customerId/addresses`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "customerId": "...",
      "label": "المحل الرئيسي",
      "recipientName": "أحمد محمد",
      "phone": "+966501234567",
      "cityId": { "_id": "...", "name": "Riyadh", "nameAr": "الرياض" },
      "addressLine": "شارع الملك فهد، مجمع البوابة، محل 15",
      "latitude": 24.7136,
      "longitude": 46.6753,
      "isDefault": true,
      ...
    }
  ],
  "message": "Addresses retrieved successfully",
  "messageAr": "تم استرجاع العناوين بنجاح"
}
```

**Flutter Code:**
```dart
/// جلب عناوين العميل
Future<List<CustomerAddress>> getAddresses(String customerId) async {
  final response = await _dio.get('/customers/$customerId/addresses');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((a) => CustomerAddress.fromJson(a))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ إضافة عنوان جديد

**Endpoint:** `POST /customers/:customerId/addresses`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "label": "الفرع الجديد",        // مطلوب
  "recipientName": "محمد أحمد",   // اختياري
  "phone": "+966507654321",      // اختياري
  "cityId": "507f1f77bcf...",   // مطلوب
  "marketId": "507f1f77bcf...", // اختياري
  "addressLine": "شارع...",     // مطلوب
  "latitude": 24.7136,          // اختياري
  "longitude": 46.6753,         // اختياري
  "isDefault": false            // اختياري
}
```

**Response (201 Created):**
```dart
{
  "success": true,
  "data": { /* CustomerAddress object */ },
  "message": "Address created successfully",
  "messageAr": "تم إنشاء العنوان بنجاح"
}
```

**Flutter Code:**
```dart
/// إضافة عنوان جديد
Future<CustomerAddress> createAddress({
  required String customerId,
  required String label,
  required String cityId,
  required String addressLine,
  String? recipientName,
  String? phone,
  String? marketId,
  double? latitude,
  double? longitude,
  bool isDefault = false,
}) async {
  final response = await _dio.post(
    '/customers/$customerId/addresses',
    data: {
      'label': label,
      'cityId': cityId,
      'addressLine': addressLine,
      if (recipientName != null) 'recipientName': recipientName,
      if (phone != null) 'phone': phone,
      if (marketId != null) 'marketId': marketId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
    },
  );
  
  if (response.data['success']) {
    return CustomerAddress.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 4️⃣ تحديث عنوان

**Endpoint:** `PUT /customers/:customerId/addresses/:addressId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:** (جميع الحقول اختيارية)
```dart
{
  "label": "اسم جديد",
  "addressLine": "عنوان محدث",
  "isDefault": true,
  // ... أي حقول أخرى للتحديث
}
```

**Flutter Code:**
```dart
/// تحديث عنوان
Future<CustomerAddress> updateAddress({
  required String customerId,
  required String addressId,
  String? label,
  String? addressLine,
  String? cityId,
  bool? isDefault,
  // ... حقول أخرى
}) async {
  final response = await _dio.put(
    '/customers/$customerId/addresses/$addressId',
    data: {
      if (label != null) 'label': label,
      if (addressLine != null) 'addressLine': addressLine,
      if (cityId != null) 'cityId': cityId,
      if (isDefault != null) 'isDefault': isDefault,
    },
  );
  
  if (response.data['success']) {
    return CustomerAddress.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ حذف عنوان

**Endpoint:** `DELETE /customers/:customerId/addresses/:addressId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (204 No Content):**
```dart
{
  "success": true,
  "data": null,
  "message": "Address deleted successfully",
  "messageAr": "تم حذف العنوان بنجاح"
}
```

**Flutter Code:**
```dart
/// حذف عنوان
Future<void> deleteAddress({
  required String customerId,
  required String addressId,
}) async {
  final response = await _dio.delete(
    '/customers/$customerId/addresses/$addressId',
  );
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🧩 CustomerService الكامل

```dart
import 'package:dio/dio.dart';

class CustomerService {
  final Dio _dio;
  
  CustomerService(this._dio);
  
  // ═════════════════════════════════════
  // Profile
  // ═════════════════════════════════════
  
  Future<Customer> getProfile(String customerId) async {
    final response = await _dio.get('/customers/$customerId');
    
    if (response.data['success']) {
      return Customer.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Addresses
  // ═════════════════════════════════════
  
  Future<List<CustomerAddress>> getAddresses(String customerId) async {
    final response = await _dio.get('/customers/$customerId/addresses');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((a) => CustomerAddress.fromJson(a))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<CustomerAddress> createAddress({
    required String customerId,
    required String label,
    required String cityId,
    required String addressLine,
    String? recipientName,
    String? phone,
    String? marketId,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final response = await _dio.post(
      '/customers/$customerId/addresses',
      data: {
        'label': label,
        'cityId': cityId,
        'addressLine': addressLine,
        if (recipientName != null) 'recipientName': recipientName,
        if (phone != null) 'phone': phone,
        if (marketId != null) 'marketId': marketId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'isDefault': isDefault,
      },
    );
    
    if (response.data['success']) {
      return CustomerAddress.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<CustomerAddress> updateAddress({
    required String customerId,
    required String addressId,
    Map<String, dynamic>? updates,
  }) async {
    final response = await _dio.put(
      '/customers/$customerId/addresses/$addressId',
      data: updates ?? {},
    );
    
    if (response.data['success']) {
      return CustomerAddress.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<void> deleteAddress({
    required String customerId,
    required String addressId,
  }) async {
    final response = await _dio.delete(
      '/customers/$customerId/addresses/$addressId',
    );
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
  
  /// تعيين عنوان كافتراضي
  Future<CustomerAddress> setDefaultAddress({
    required String customerId,
    required String addressId,
  }) async {
    return updateAddress(
      customerId: customerId,
      addressId: addressId,
      updates: {'isDefault': true},
    );
  }
}
```

---

## 🎯 أمثلة الاستخدام

### عرض ملف العميل

```dart
class CustomerProfileScreen extends StatelessWidget {
  final String customerId;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Customer>(
      future: customerService.getProfile(customerId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final customer = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text(customer.shopName)),
            body: ListView(
              children: [
                // بطاقة الولاء
                LoyaltyCard(
                  tier: customer.loyaltyTier,
                  points: customer.loyaltyPoints,
                ),
                
                // معلومات الائتمان
                CreditInfoCard(
                  limit: customer.creditLimit,
                  used: customer.creditUsed,
                  available: customer.availableCredit,
                ),
                
                // رصيد المحفظة
                WalletCard(balance: customer.walletBalance),
                
                // إحصائيات
                StatsCard(
                  totalOrders: customer.totalOrders,
                  totalSpent: customer.totalSpent,
                  averageOrder: customer.averageOrderValue,
                ),
              ],
            ),
          );
        }
        return LoadingIndicator();
      },
    );
  }
}
```

### إدارة العناوين

```dart
class AddressesScreen extends StatefulWidget {
  final String customerId;
  
  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<CustomerAddress> _addresses = [];
  
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }
  
  Future<void> _loadAddresses() async {
    final addresses = await customerService.getAddresses(widget.customerId);
    setState(() => _addresses = addresses);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('عناويني')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return AddressTile(
            address: address,
            onSetDefault: () => _setDefault(address.id),
            onEdit: () => _editAddress(address),
            onDelete: () => _deleteAddress(address.id),
          );
        },
      ),
    );
  }
  
  Future<void> _setDefault(String addressId) async {
    await customerService.setDefaultAddress(
      customerId: widget.customerId,
      addressId: addressId,
    );
    _loadAddresses();
  }
  
  Future<void> _deleteAddress(String addressId) async {
    await customerService.deleteAddress(
      customerId: widget.customerId,
      addressId: addressId,
    );
    _loadAddresses();
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/customers/:id` | ✅ | جلب ملف العميل |
| GET | `/customers/:id/addresses` | ✅ | جلب العناوين |
| POST | `/customers/:id/addresses` | ✅ | إضافة عنوان |
| PUT | `/customers/:id/addresses/:addressId` | ✅ | تحديث عنوان |
| DELETE | `/customers/:id/addresses/:addressId` | ✅ | حذف عنوان |

---

> 🔗 **السابق:** [catalog.md](./catalog.md) - دليل الكتالوج  
> 🔗 **التالي:** [products.md](./products.md) - دليل المنتجات (قريباً)
