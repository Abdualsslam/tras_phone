# 📍 Locations Module - دليل ربط المواقع والمدن

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ الدول (Countries)
- ✅ المدن (Cities)
- ✅ الأسواق/الأحياء (Markets)
- ✅ مناطق الشحن (Shipping Zones)
- ✅ حساب تكلفة الشحن (Shipping Calculator)

> **ملاحظة**: معظم الـ endpoints **عامة** 🌐 ولا تحتاج Token

---

## 📁 Flutter Models

### Country Model

```dart
class Country {
  final String id;
  final String name;
  final String nameAr;
  final String code;       // ISO 3166-1 alpha-2 (e.g., SA)
  final String code3;      // ISO 3166-1 alpha-3 (e.g., SAU)
  final String phoneCode;  // e.g., +966
  final String currency;
  final String? flag;
  final bool isActive;
  final bool isDefault;

  Country({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    required this.code3,
    required this.phoneCode,
    required this.currency,
    this.flag,
    required this.isActive,
    required this.isDefault,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      code3: json['code3'],
      phoneCode: json['phoneCode'],
      currency: json['currency'] ?? 'SAR',
      flag: json['flag'],
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// تنسيق رقم الهاتف
  String formatPhone(String phone) => '$phoneCode$phone';
}
```

### City Model

```dart
class City {
  final String id;
  final String name;
  final String nameAr;
  final String countryId;
  final String shippingZoneId;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final String? region;
  final String? regionAr;
  final bool isActive;
  final bool isCapital;
  final int displayOrder;

  City({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.countryId,
    required this.shippingZoneId,
    this.latitude,
    this.longitude,
    this.timezone,
    this.region,
    this.regionAr,
    required this.isActive,
    required this.isCapital,
    required this.displayOrder,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      countryId: json['countryId'] is String 
          ? json['countryId'] 
          : json['countryId']?['_id'] ?? '',
      shippingZoneId: json['shippingZoneId'] is String 
          ? json['shippingZoneId'] 
          : json['shippingZoneId']?['_id'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      region: json['region'],
      regionAr: json['regionAr'],
      isActive: json['isActive'] ?? true,
      isCapital: json['isCapital'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على المنطقة حسب اللغة
  String? getRegion(String locale) => locale == 'ar' ? regionAr : region;
}
```

### Market Model

```dart
class Market {
  final String id;
  final String name;
  final String nameAr;
  final String cityId;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? descriptionAr;
  final List<String>? landmarks;
  final bool isActive;
  final int displayOrder;

  Market({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.cityId,
    this.latitude,
    this.longitude,
    this.description,
    this.descriptionAr,
    this.landmarks,
    required this.isActive,
    required this.displayOrder,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      cityId: json['cityId'] is String 
          ? json['cityId'] 
          : json['cityId']?['_id'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      landmarks: json['landmarks'] != null 
          ? List<String>.from(json['landmarks']) 
          : null,
      isActive: json['isActive'] ?? true,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
}
```

### ShippingZone Model

```dart
class ShippingZone {
  final String id;
  final String name;
  final String nameAr;
  final String countryId;
  final double baseCost;
  final double costPerKg;
  final double? freeShippingThreshold;
  final int? estimatedDeliveryDays;
  final int? minDeliveryDays;
  final int? maxDeliveryDays;
  final bool isActive;

  ShippingZone({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.countryId,
    required this.baseCost,
    required this.costPerKg,
    this.freeShippingThreshold,
    this.estimatedDeliveryDays,
    this.minDeliveryDays,
    this.maxDeliveryDays,
    required this.isActive,
  });

  factory ShippingZone.fromJson(Map<String, dynamic> json) {
    return ShippingZone(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      countryId: json['countryId'] is String 
          ? json['countryId'] 
          : json['countryId']?['_id'] ?? '',
      baseCost: (json['baseCost'] ?? 0).toDouble(),
      costPerKg: (json['costPerKg'] ?? 0).toDouble(),
      freeShippingThreshold: json['freeShippingThreshold']?.toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'],
      minDeliveryDays: json['minDeliveryDays'],
      maxDeliveryDays: json['maxDeliveryDays'],
      isActive: json['isActive'] ?? true,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// حساب تكلفة الشحن
  double calculateShippingCost(double weight, double orderTotal) {
    if (freeShippingThreshold != null && orderTotal >= freeShippingThreshold!) {
      return 0;
    }
    return baseCost + (weight * costPerKg);
  }
  
  /// نص وقت التوصيل
  String getDeliveryText(String locale) {
    if (minDeliveryDays != null && maxDeliveryDays != null) {
      return locale == 'ar' 
          ? '$minDeliveryDays - $maxDeliveryDays أيام'
          : '$minDeliveryDays - $maxDeliveryDays days';
    }
    if (estimatedDeliveryDays != null) {
      return locale == 'ar' 
          ? '$estimatedDeliveryDays أيام'
          : '$estimatedDeliveryDays days';
    }
    return '';
  }
}
```

### ShippingCalculation Model

```dart
class ShippingCalculation {
  final double baseCost;
  final double weightCost;
  final double totalCost;
  final bool isFreeShipping;
  final double? freeShippingThreshold;
  final int? estimatedDeliveryDays;
  final String zoneName;
  final String zoneNameAr;

  ShippingCalculation({
    required this.baseCost,
    required this.weightCost,
    required this.totalCost,
    required this.isFreeShipping,
    this.freeShippingThreshold,
    this.estimatedDeliveryDays,
    required this.zoneName,
    required this.zoneNameAr,
  });

  factory ShippingCalculation.fromJson(Map<String, dynamic> json) {
    return ShippingCalculation(
      baseCost: (json['baseCost'] ?? 0).toDouble(),
      weightCost: (json['weightCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      isFreeShipping: json['isFreeShipping'] ?? false,
      freeShippingThreshold: json['freeShippingThreshold']?.toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'],
      zoneName: json['zoneName'] ?? '',
      zoneNameAr: json['zoneNameAr'] ?? '',
    );
  }

  /// الحصول على اسم المنطقة حسب اللغة
  String getZoneName(String locale) => locale == 'ar' ? zoneNameAr : zoneName;
}
```

---

## 📞 API Endpoints

### 🌍 Countries

#### 1️⃣ جلب قائمة الدول

**Endpoint:** `GET /locations/countries` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Saudi Arabia",
      "nameAr": "المملكة العربية السعودية",
      "code": "SA",
      "code3": "SAU",
      "phoneCode": "+966",
      "currency": "SAR",
      "flag": "🇸🇦",
      "isActive": true,
      "isDefault": true
    },
    {
      "_id": "...",
      "name": "United Arab Emirates",
      "nameAr": "الإمارات العربية المتحدة",
      "code": "AE",
      "code3": "ARE",
      "phoneCode": "+971",
      "currency": "AED",
      "flag": "🇦🇪",
      "isActive": true,
      "isDefault": false
    }
  ],
  "message": "Countries retrieved",
  "messageAr": "تم استرجاع الدول"
}
```

**Flutter Code:**
```dart
class LocationsService {
  final Dio _dio;
  
  LocationsService(this._dio);
  
  /// جلب قائمة الدول
  Future<List<Country>> getCountries() async {
    final response = await _dio.get('/locations/countries');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Country.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

### 🏙️ Cities

#### 2️⃣ جلب قائمة المدن

**Endpoint:** `GET /locations/cities` 🌐 (Public)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `countryId` | string | ❌ | فلترة حسب الدولة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Riyadh",
      "nameAr": "الرياض",
      "countryId": "...",
      "shippingZoneId": "...",
      "latitude": 24.7136,
      "longitude": 46.6753,
      "timezone": "Asia/Riyadh",
      "region": "Riyadh Region",
      "regionAr": "منطقة الرياض",
      "isActive": true,
      "isCapital": true,
      "displayOrder": 1
    },
    {
      "_id": "...",
      "name": "Jeddah",
      "nameAr": "جدة",
      "countryId": "...",
      "shippingZoneId": "...",
      "latitude": 21.4858,
      "longitude": 39.1925,
      "region": "Makkah Region",
      "regionAr": "منطقة مكة المكرمة",
      "isActive": true,
      "isCapital": false,
      "displayOrder": 2
    }
  ],
  "message": "Cities retrieved",
  "messageAr": "تم استرجاع المدن"
}
```

**Flutter Code:**
```dart
/// جلب قائمة المدن
Future<List<City>> getCities({String? countryId}) async {
  final response = await _dio.get('/locations/cities', queryParameters: {
    if (countryId != null) 'countryId': countryId,
  });
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((c) => City.fromJson(c))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ جلب تفاصيل مدينة

**Endpoint:** `GET /locations/cities/:id` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "name": "Riyadh",
    "nameAr": "الرياض",
    "countryId": {
      "_id": "...",
      "name": "Saudi Arabia",
      "nameAr": "المملكة العربية السعودية",
      "code": "SA"
    },
    "shippingZoneId": {
      "_id": "...",
      "name": "Central Region",
      "nameAr": "المنطقة الوسطى",
      "baseCost": 25,
      "estimatedDeliveryDays": 2
    },
    "latitude": 24.7136,
    "longitude": 46.6753,
    "isCapital": true,
    ...
  },
  "message": "City retrieved",
  "messageAr": "تم استرجاع المدينة"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل مدينة
Future<City> getCityById(String cityId) async {
  final response = await _dio.get('/locations/cities/$cityId');
  
  if (response.data['success']) {
    return City.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 🏪 Markets

#### 4️⃣ جلب أسواق المدينة

**Endpoint:** `GET /locations/cities/:cityId/markets` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Al Olaya District",
      "nameAr": "حي العليا",
      "cityId": "...",
      "latitude": 24.7011,
      "longitude": 46.6850,
      "description": "Business district with major malls",
      "descriptionAr": "حي الأعمال مع المولات الكبرى",
      "landmarks": ["Kingdom Tower", "Al Faisaliah Tower"],
      "isActive": true,
      "displayOrder": 1
    },
    {
      "_id": "...",
      "name": "Al Malaz District",
      "nameAr": "حي الملز",
      "cityId": "...",
      "description": "Central area near King Fahd Stadium",
      "descriptionAr": "منطقة وسطية قرب ملعب الملك فهد",
      "isActive": true,
      "displayOrder": 2
    }
  ],
  "message": "Markets retrieved",
  "messageAr": "تم استرجاع الأسواق"
}
```

**Flutter Code:**
```dart
/// جلب أسواق/أحياء المدينة
Future<List<Market>> getMarketsByCity(String cityId) async {
  final response = await _dio.get('/locations/cities/$cityId/markets');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((m) => Market.fromJson(m))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ جلب تفاصيل سوق

**Endpoint:** `GET /locations/markets/:id` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "name": "Al Olaya District",
    "nameAr": "حي العليا",
    "cityId": {
      "_id": "...",
      "name": "Riyadh",
      "nameAr": "الرياض"
    },
    "latitude": 24.7011,
    "longitude": 46.6850,
    "landmarks": ["Kingdom Tower", "Al Faisaliah Tower"],
    ...
  },
  "message": "Market retrieved",
  "messageAr": "تم استرجاع السوق"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل سوق/حي
Future<Market> getMarketById(String marketId) async {
  final response = await _dio.get('/locations/markets/$marketId');
  
  if (response.data['success']) {
    return Market.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 📦 Shipping

#### 6️⃣ حساب تكلفة الشحن

**Endpoint:** `GET /locations/shipping/calculate` 🌐 (Public)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cityId` | string | ✅ | معرف المدينة |
| `weight` | number | ❌ | الوزن بالكيلوجرام |
| `orderTotal` | number | ❌ | قيمة الطلب (للشحن المجاني) |

**Response:**
```dart
{
  "success": true,
  "data": {
    "baseCost": 25.00,
    "weightCost": 5.00,
    "totalCost": 30.00,
    "isFreeShipping": false,
    "freeShippingThreshold": 500.00,
    "estimatedDeliveryDays": 2,
    "zoneName": "Central Region",
    "zoneNameAr": "المنطقة الوسطى"
  },
  "message": "Shipping calculated",
  "messageAr": "تم حساب الشحن"
}
```

**Free Shipping Response:**
```dart
{
  "success": true,
  "data": {
    "baseCost": 0,
    "weightCost": 0,
    "totalCost": 0,
    "isFreeShipping": true,
    "freeShippingThreshold": 500.00,
    "estimatedDeliveryDays": 2,
    "zoneName": "Central Region",
    "zoneNameAr": "المنطقة الوسطى"
  }
}
```

**Flutter Code:**
```dart
/// حساب تكلفة الشحن
Future<ShippingCalculation> calculateShipping({
  required String cityId,
  double? weight,
  double? orderTotal,
}) async {
  final response = await _dio.get('/locations/shipping/calculate', 
    queryParameters: {
      'cityId': cityId,
      if (weight != null) 'weight': weight,
      if (orderTotal != null) 'orderTotal': orderTotal,
    },
  );
  
  if (response.data['success']) {
    return ShippingCalculation.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 7️⃣ جلب مناطق الشحن

**Endpoint:** `GET /locations/shipping-zones`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Central Region",
      "nameAr": "المنطقة الوسطى",
      "countryId": "...",
      "baseCost": 25.00,
      "costPerKg": 5.00,
      "freeShippingThreshold": 500.00,
      "estimatedDeliveryDays": 2,
      "minDeliveryDays": 1,
      "maxDeliveryDays": 3,
      "isActive": true
    },
    {
      "_id": "...",
      "name": "Western Region",
      "nameAr": "المنطقة الغربية",
      "baseCost": 30.00,
      "costPerKg": 5.00,
      "freeShippingThreshold": 500.00,
      "estimatedDeliveryDays": 3,
      "isActive": true
    }
  ],
  "message": "Zones retrieved",
  "messageAr": "تم استرجاع المناطق"
}
```

**Flutter Code:**
```dart
/// جلب مناطق الشحن
Future<List<ShippingZone>> getShippingZones() async {
  final response = await _dio.get('/locations/shipping-zones');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((z) => ShippingZone.fromJson(z))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

## 🧩 LocationsService الكامل

```dart
import 'package:dio/dio.dart';

class LocationsService {
  final Dio _dio;
  
  LocationsService(this._dio);
  
  // ═════════════════════════════════════
  // Countries
  // ═════════════════════════════════════
  
  Future<List<Country>> getCountries() async {
    final response = await _dio.get('/locations/countries');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Country.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Cities
  // ═════════════════════════════════════
  
  Future<List<City>> getCities({String? countryId}) async {
    final response = await _dio.get('/locations/cities', queryParameters: {
      if (countryId != null) 'countryId': countryId,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => City.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<City> getCityById(String cityId) async {
    final response = await _dio.get('/locations/cities/$cityId');
    
    if (response.data['success']) {
      return City.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Markets
  // ═════════════════════════════════════
  
  Future<List<Market>> getMarketsByCity(String cityId) async {
    final response = await _dio.get('/locations/cities/$cityId/markets');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((m) => Market.fromJson(m))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Market> getMarketById(String marketId) async {
    final response = await _dio.get('/locations/markets/$marketId');
    
    if (response.data['success']) {
      return Market.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Shipping
  // ═════════════════════════════════════
  
  Future<ShippingCalculation> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    final response = await _dio.get('/locations/shipping/calculate', 
      queryParameters: {
        'cityId': cityId,
        if (weight != null) 'weight': weight,
        if (orderTotal != null) 'orderTotal': orderTotal,
      },
    );
    
    if (response.data['success']) {
      return ShippingCalculation.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<ShippingZone>> getShippingZones() async {
    final response = await _dio.get('/locations/shipping-zones');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((z) => ShippingZone.fromJson(z))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🎯 أمثلة الاستخدام

### اختيار المدينة في Checkout

```dart
class CitySelector extends StatelessWidget {
  final Function(City) onCitySelected;
  
  const CitySelector({required this.onCitySelected});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<City>>(
      future: locationsService.getCities(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cities = snapshot.data!;
          return DropdownButtonFormField<City>(
            decoration: InputDecoration(
              labelText: 'المدينة',
              border: OutlineInputBorder(),
            ),
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Row(
                  children: [
                    if (city.isCapital)
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(city.getName('ar')),
                  ],
                ),
              );
            }).toList(),
            onChanged: (city) {
              if (city != null) onCitySelected(city);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### عرض تكلفة الشحن

```dart
class ShippingCostWidget extends StatelessWidget {
  final String cityId;
  final double orderTotal;
  
  const ShippingCostWidget({
    required this.cityId,
    required this.orderTotal,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ShippingCalculation>(
      future: locationsService.calculateShipping(
        cityId: cityId,
        orderTotal: orderTotal,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shipping = snapshot.data!;
          
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الشحن إلى ${shipping.getZoneName('ar')}'),
                      if (shipping.isFreeShipping)
                        Chip(
                          label: Text('شحن مجاني'),
                          backgroundColor: Colors.green[100],
                        )
                      else
                        Text(
                          '${shipping.totalCost.toStringAsFixed(2)} ر.س',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  
                  if (shipping.estimatedDeliveryDays != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16),
                        SizedBox(width: 8),
                        Text('التوصيل خلال ${shipping.estimatedDeliveryDays} أيام'),
                      ],
                    ),
                  ],
                  
                  // رسالة الشحن المجاني
                  if (!shipping.isFreeShipping && 
                      shipping.freeShippingThreshold != null) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'أضف ${(shipping.freeShippingThreshold! - orderTotal).toStringAsFixed(2)} ر.س للحصول على شحن مجاني',
                        style: TextStyle(color: Colors.blue[800], fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 80, color: Colors.white),
        );
      },
    );
  }
}
```

### اختيار الحي/السوق

```dart
class MarketPicker extends StatelessWidget {
  final String cityId;
  final Function(Market) onMarketSelected;
  
  const MarketPicker({
    required this.cityId,
    required this.onMarketSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Market>>(
      future: locationsService.getMarketsByCity(cityId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final markets = snapshot.data!;
          
          if (markets.isEmpty) {
            return Text('لا توجد أحياء متاحة');
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اختر الحي', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: markets.map((market) {
                  return ActionChip(
                    label: Text(market.getName('ar')),
                    onPressed: () => onMarketSelected(market),
                  );
                }).toList(),
              ),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

---

## ⚠️ الأخطاء المحتملة

| Error Code | Message | الوصف |
|------------|---------|-------|
| `CITY_NOT_FOUND` | City not found | المدينة غير موجودة |
| `MARKET_NOT_FOUND` | Market not found | السوق/الحي غير موجود |
| `COUNTRY_NOT_FOUND` | Country not found | الدولة غير موجودة |
| `SHIPPING_ZONE_NOT_FOUND` | Shipping zone not found | منطقة الشحن غير موجودة |

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/locations/countries` | ❌ | قائمة الدول |
| GET | `/locations/cities` | ❌ | قائمة المدن |
| GET | `/locations/cities/:id` | ❌ | تفاصيل مدينة |
| GET | `/locations/cities/:cityId/markets` | ❌ | أسواق المدينة |
| GET | `/locations/markets/:id` | ❌ | تفاصيل سوق |
| GET | `/locations/shipping/calculate` | ❌ | حساب تكلفة الشحن |
| GET | `/locations/shipping-zones` | ✅ | مناطق الشحن |

---

> 🔗 **السابق:** [wallet.md](./wallet.md) - دليل المحفظة والولاء  
> 🔗 **التالي:** [returns.md](./returns.md) - دليل المرتجعات
