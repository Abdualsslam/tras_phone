# 📍 Addresses Module - دليل ربط نظام العناوين

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ إدارة عناوين التوصيل للعملاء
- ✅ إضافة عناوين متعددة
- ✅ تحديد عنوان افتراضي
- ✅ تحديث وحذف العناوين
- ✅ ربط العناوين بالمدن والأسواق

---

## 📁 Flutter Models

### City Entity

```dart
class CityEntity {
  final String id;
  final String name;
  final String? nameAr;

  const CityEntity({
    required this.id,
    required this.name,
    this.nameAr,
  });

  String getName(String locale) =>
      locale == 'ar' && nameAr != null ? nameAr! : name;
}
```

### Address Entity

```dart
class AddressEntity {
  final String id;
  final String customerId;
  final String label;              // مثل: "المنزل"، "العمل"، "المحل"
  final String? recipientName;     // اسم المستلم (اختياري)
  final String? phone;             // رقم الهاتف (اختياري)
  final String cityId;             // معرف المدينة (مطلوب)
  final String? marketId;          // معرف السوق (اختياري)
  final String addressLine;        // تفاصيل العنوان (مطلوب)
  final double? latitude;          // خط العرض (اختياري)
  final double? longitude;         // خط الطول (اختياري)
  final bool isDefault;            // عنوان افتراضي
  final DateTime createdAt;
  final DateTime updatedAt;
  final CityEntity? city;          // بيانات المدينة المرتبطة

  const AddressEntity({
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
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.city,
  });

  // دمج العنوان الكامل
  String get fullAddress {
    final parts = <String>[];
    parts.add(addressLine);
    if (city != null) {
      parts.add(city!.nameAr ?? city!.name);
    }
    return parts.join('، ');
  }

  AddressEntity copyWith({
    String? id,
    String? customerId,
    String? label,
    String? recipientName,
    String? phone,
    String? cityId,
    String? marketId,
    String? addressLine,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    CityEntity? city,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      cityId: cityId ?? this.cityId,
      marketId: marketId ?? this.marketId,
      addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      city: city ?? this.city,
    );
  }
}
```

### Address Request Model

```dart
@JsonSerializable()
class AddressRequest {
  final String label;
  final String? recipientName;
  final String? phone;
  final String cityId;
  final String? marketId;
  final String addressLine;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressRequest({
    required this.label,
    this.recipientName,
    this.phone,
    required this.cityId,
    this.marketId,
    required this.addressLine,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
```

### Address Model (Data Layer)

```dart
@JsonSerializable()
class AddressModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'customerId', readValue: _readCustomerId)
  final String customerId;

  final String label;
  final String? recipientName;
  final String? phone;

  @JsonKey(name: 'cityId', readValue: _readCityId)
  final String cityId;

  @JsonKey(name: 'marketId', readValue: _readOptionalId)
  final String? marketId;

  final String addressLine;
  final double? latitude;
  final double? longitude;

  @JsonKey(defaultValue: false)
  final bool isDefault;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated city object
  @JsonKey(includeFromJson: true, includeToJson: false)
  final CityModel? city;

  const AddressModel({
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
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.city,
  });

  // Helper methods لقراءة MongoDB IDs
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  static Object? _readCustomerId(Map<dynamic, dynamic> json, String key) {
    final value = json['customerId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  static Object? _readCityId(Map<dynamic, dynamic> json, String key) {
    final value = json['cityId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  static Object? _readOptionalId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Extract city if populated
    CityModel? cityObj;
    if (json['cityId'] is Map) {
      cityObj = CityModel.fromJson(json['cityId'] as Map<String, dynamic>);
    }

    return AddressModel(
      id: _readId(json, 'id')?.toString() ?? '',
      customerId: _readCustomerId(json, 'customerId')?.toString() ?? '',
      label: json['label'] ?? '',
      recipientName: json['recipientName'] as String?,
      phone: json['phone'] as String?,
      cityId: _readCityId(json, 'cityId')?.toString() ?? '',
      marketId: _readOptionalId(json, 'marketId')?.toString(),
      addressLine: json['addressLine'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      city: cityObj,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'label': label,
    'recipientName': recipientName,
    'phone': phone,
    'cityId': cityId,
    'marketId': marketId,
    'addressLine': addressLine,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Convert to domain entity
  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      customerId: customerId,
      label: label,
      recipientName: recipientName,
      phone: phone,
      cityId: cityId,
      marketId: marketId,
      addressLine: addressLine,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      city: city != null
          ? CityEntity(id: city!.id, name: city!.name, nameAr: city!.nameAr)
          : null,
    );
  }
}
```

---

## 🔌 API Endpoints

### Base URL
```
/customer/addresses
```

### Authentication
جميع الـ endpoints تتطلب JWT Token في الـ Header:
```
Authorization: Bearer <access_token>
```

---

## 📡 API Calls

### 1. جلب جميع العناوين

**Endpoint:**
```
GET /customer/addresses
```

**Response:**
```json
{
  "success": true,
  "message": "Addresses retrieved successfully",
  "messageAr": "تم استرجاع العناوين بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "customerId": "507f1f77bcf86cd799439010",
      "label": "المنزل",
      "recipientName": "أحمد محمد",
      "phone": "0501234567",
      "cityId": {
        "_id": "507f1f77bcf86cd799439001",
        "name": "Riyadh",
        "nameAr": "الرياض"
      },
      "marketId": "507f1f77bcf86cd799439002",
      "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
      "latitude": 24.7136,
      "longitude": 46.6753,
      "isDefault": true,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439012",
      "customerId": "507f1f77bcf86cd799439010",
      "label": "المحل",
      "recipientName": "متجر الإلكترونيات",
      "phone": "0501234568",
      "cityId": {
        "_id": "507f1f77bcf86cd799439001",
        "name": "Riyadh",
        "nameAr": "الرياض"
      },
      "addressLine": "حي العليا، شارع التحلية، محل رقم 25",
      "isDefault": false,
      "createdAt": "2024-01-16T11:00:00Z",
      "updatedAt": "2024-01-16T11:00:00Z"
    }
  ]
}
```

**Flutter Code:**
```dart
Future<List<AddressEntity>> getAddresses() async {
  try {
    final response = await _apiClient.get(ApiEndpoints.addresses);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => AddressModel.fromJson(json).toEntity()).toList();
  } catch (e) {
    developer.log('Error fetching addresses: $e', name: 'ProfileDataSource');
    throw Exception('Failed to fetch addresses');
  }
}
```

**Using Cubit:**
```dart
// في InitState أو onRefresh
context.read<AddressesCubit>().loadAddresses();

// في Widget
BlocBuilder<AddressesCubit, AddressesState>(
  builder: (context, state) {
    if (state is AddressesLoading) {
      return const CircularProgressIndicator();
    } else if (state is AddressesLoaded) {
      return ListView.builder(
        itemCount: state.addresses.length,
        itemBuilder: (context, index) {
          final address = state.addresses[index];
          return AddressCard(address: address);
        },
      );
    } else if (state is AddressesError) {
      return Text('Error: ${state.message}');
    }
    return const SizedBox();
  },
)
```

---

### 2. جلب عنوان محدد بالـ ID

**Endpoint:**
```
GET /customer/addresses/:addressId
```

**Response:**
```json
{
  "success": true,
  "message": "Address retrieved successfully",
  "messageAr": "تم استرجاع العنوان بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "customerId": "507f1f77bcf86cd799439010",
    "label": "المنزل",
    "recipientName": "أحمد محمد",
    "phone": "0501234567",
    "cityId": {
      "_id": "507f1f77bcf86cd799439001",
      "name": "Riyadh",
      "nameAr": "الرياض"
    },
    "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
    "latitude": 24.7136,
    "longitude": 46.6753,
    "isDefault": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

**Flutter Code:**
```dart
Future<AddressEntity> getAddressById(String id) async {
  try {
    final response = await _apiClient.get('${ApiEndpoints.addresses}/$id');
    final data = response.data['data'] ?? response.data;

    return AddressModel.fromJson(data).toEntity();
  } catch (e) {
    developer.log('Error fetching address: $e', name: 'ProfileDataSource');
    throw Exception('Failed to fetch address');
  }
}
```

---

### 3. إضافة عنوان جديد

**Endpoint:**
```
POST /customer/addresses
```

**Request Body:**
```json
{
  "label": "المنزل",
  "recipientName": "أحمد محمد",
  "phone": "0501234567",
  "cityId": "507f1f77bcf86cd799439001",
  "marketId": "507f1f77bcf86cd799439002",
  "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "isDefault": true
}
```

**Validation Rules:**
- `label`: مطلوب، نص
- `recipientName`: اختياري، نص
- `phone`: اختياري، نص
- `cityId`: مطلوب، MongoDB ObjectId صحيح
- `marketId`: اختياري، MongoDB ObjectId
- `addressLine`: مطلوب، نص
- `latitude`: اختياري، رقم
- `longitude`: اختياري، رقم
- `isDefault`: اختياري، boolean (افتراضي: false)

**Response:**
```json
{
  "success": true,
  "message": "Address created successfully",
  "messageAr": "تم إنشاء العنوان بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "customerId": "507f1f77bcf86cd799439010",
    "label": "المنزل",
    "recipientName": "أحمد محمد",
    "phone": "0501234567",
    "cityId": "507f1f77bcf86cd799439001",
    "marketId": "507f1f77bcf86cd799439002",
    "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
    "latitude": 24.7136,
    "longitude": 46.6753,
    "isDefault": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

**Flutter Code:**
```dart
Future<AddressEntity> createAddress(AddressRequest request) async {
  try {
    final response = await _apiClient.post(
      ApiEndpoints.addresses,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return AddressModel.fromJson(data).toEntity();
  } catch (e) {
    developer.log('Error creating address: $e', name: 'ProfileDataSource');
    throw Exception('Failed to create address');
  }
}
```

**Using Cubit:**
```dart
// في AddAddressScreen
await context.read<AddressesCubit>().createAddress(
  label: labelController.text,
  cityId: selectedCityId,
  addressLine: addressLineController.text,
  recipientName: recipientNameController.text,
  phone: phoneController.text,
  marketId: selectedMarketId,
  latitude: selectedLatitude,
  longitude: selectedLongitude,
  isDefault: isDefaultSwitch,
);

// الاستماع للنتيجة
BlocListener<AddressesCubit, AddressesState>(
  listener: (context, state) {
    if (state is AddressOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      Navigator.of(context).pop();
    } else if (state is AddressesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

---

### 4. تحديث عنوان

**Endpoint:**
```
PUT /customer/addresses/:addressId
```

**Request Body (جميع الحقول اختيارية):**
```json
{
  "label": "المحل الجديد",
  "recipientName": "متجر الإلكترونيات المحدّث",
  "phone": "0509876543",
  "cityId": "507f1f77bcf86cd799439003",
  "marketId": "507f1f77bcf86cd799439004",
  "addressLine": "حي العليا، شارع التحلية الجديد، محل رقم 30",
  "latitude": 24.7200,
  "longitude": 46.6800,
  "isDefault": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Address updated successfully",
  "messageAr": "تم تحديث العنوان بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "customerId": "507f1f77bcf86cd799439010",
    "label": "المحل الجديد",
    "recipientName": "متجر الإلكترونيات المحدّث",
    "phone": "0509876543",
    "cityId": "507f1f77bcf86cd799439003",
    "marketId": "507f1f77bcf86cd799439004",
    "addressLine": "حي العليا، شارع التحلية الجديد، محل رقم 30",
    "latitude": 24.7200,
    "longitude": 46.6800,
    "isDefault": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-16T14:20:00Z"
  }
}
```

**Flutter Code:**
```dart
Future<AddressEntity> updateAddress(
  String id,
  Map<String, dynamic> updates,
) async {
  try {
    final response = await _apiClient.put(
      '${ApiEndpoints.addresses}/$id',
      data: updates,
    );

    final data = response.data['data'] ?? response.data;
    return AddressModel.fromJson(data).toEntity();
  } catch (e) {
    developer.log('Error updating address: $e', name: 'ProfileDataSource');
    throw Exception('Failed to update address');
  }
}
```

**Using Cubit:**
```dart
// تحديث عنوان
await context.read<AddressesCubit>().updateAddress(
  id: addressId,
  label: labelController.text,
  addressLine: addressLineController.text,
  recipientName: recipientNameController.text,
  phone: phoneController.text,
  cityId: selectedCityId,
  isDefault: isDefaultSwitch,
);
```

---

### 5. حذف عنوان

**Endpoint:**
```
DELETE /customer/addresses/:addressId
```

**Response:**
```json
{
  "success": true,
  "message": "Address deleted successfully",
  "messageAr": "تم حذف العنوان بنجاح",
  "data": null
}
```

**Flutter Code:**
```dart
Future<bool> deleteAddress(String id) async {
  try {
    final response = await _apiClient.delete('${ApiEndpoints.addresses}/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    developer.log('Error deleting address: $e', name: 'ProfileDataSource');
    throw Exception('Failed to delete address');
  }
}
```

**Using Cubit:**
```dart
// حذف عنوان
await context.read<AddressesCubit>().deleteAddress(addressId);

// مع تأكيد
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('تأكيد الحذف'),
    content: const Text('هل تريد حذف هذا العنوان؟'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      TextButton(
        onPressed: () {
          context.read<AddressesCubit>().deleteAddress(addressId);
          Navigator.pop(context);
        },
        child: const Text('حذف'),
      ),
    ],
  ),
);
```

---

### 6. تعيين عنوان كافتراضي

**Endpoint:**
```
PUT /customer/addresses/:addressId
```

**Request Body:**
```json
{
  "isDefault": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Address updated successfully",
  "messageAr": "تم تحديث العنوان بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "customerId": "507f1f77bcf86cd799439010",
    "label": "المنزل",
    "isDefault": true,
    ...
  }
}
```

**Flutter Code:**
```dart
Future<bool> setDefaultAddress(String id) async {
  try {
    final response = await _apiClient.put(
      '${ApiEndpoints.addresses}/$id',
      data: {'isDefault': true},
    );

    return response.statusCode == 200;
  } catch (e) {
    developer.log('Error setting default address: $e', name: 'ProfileDataSource');
    throw Exception('Failed to set default address');
  }
}
```

**Using Cubit:**
```dart
// تعيين عنوان افتراضي
await context.read<AddressesCubit>().setDefaultAddress(addressId);

// الحصول على العنوان الافتراضي
final defaultAddress = context.read<AddressesCubit>().defaultAddress;
```

---

## 🎯 State Management - AddressesCubit

### States

```dart
// الحالات
abstract class AddressesState {
  const AddressesState();
}

class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

class AddressesLoaded extends AddressesState {
  final List<AddressEntity> addresses;
  
  const AddressesLoaded(this.addresses);
}

class AddressOperationLoading extends AddressesState {
  final List<AddressEntity> currentAddresses;
  
  const AddressOperationLoading(this.currentAddresses);
}

class AddressOperationSuccess extends AddressesState {
  final List<AddressEntity> addresses;
  final String message;
  
  const AddressOperationSuccess(this.addresses, this.message);
}

class AddressesError extends AddressesState {
  final String message;
  
  const AddressesError(this.message);
}
```

### Cubit Implementation

```dart
class AddressesCubit extends Cubit<AddressesState> {
  final ProfileRepository _repository;
  List<AddressEntity> _addresses = [];

  AddressesCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const AddressesInitial());

  /// Load all addresses
  Future<void> loadAddresses() async {
    emit(const AddressesLoading());
    try {
      _addresses = await _repository.getAddresses();
      emit(AddressesLoaded(_addresses));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  /// Create new address
  Future<void> createAddress({
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
    emit(AddressOperationLoading(_addresses));
    try {
      final request = AddressRequest(
        label: label,
        cityId: cityId,
        addressLine: addressLine,
        recipientName: recipientName,
        phone: phone,
        marketId: marketId,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      final newAddress = await _repository.createAddress(request);

      // If new address is default, update other addresses
      if (isDefault) {
        _addresses = _addresses
            .map((a) => a.copyWith(isDefault: false))
            .toList();
      }

      _addresses.add(newAddress);
      emit(AddressOperationSuccess(_addresses, 'تم إضافة العنوان بنجاح'));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  /// Update existing address
  Future<void> updateAddress({
    required String id,
    String? label,
    String? addressLine,
    String? cityId,
    String? recipientName,
    String? phone,
    String? marketId,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    emit(AddressOperationLoading(_addresses));
    try {
      final updates = <String, dynamic>{};
      if (label != null) updates['label'] = label;
      if (addressLine != null) updates['addressLine'] = addressLine;
      if (cityId != null) updates['cityId'] = cityId;
      if (recipientName != null) updates['recipientName'] = recipientName;
      if (phone != null) updates['phone'] = phone;
      if (marketId != null) updates['marketId'] = marketId;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (isDefault != null) updates['isDefault'] = isDefault;

      final updated = await _repository.updateAddress(id, updates);

      // Update local list
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        // If setting as default, update others
        if (isDefault == true) {
          _addresses = _addresses
              .map((a) => a.copyWith(isDefault: false))
              .toList();
        }
        _addresses[index] = updated;
      }

      emit(AddressOperationSuccess(_addresses, 'تم تحديث العنوان بنجاح'));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    emit(AddressOperationLoading(_addresses));
    try {
      await _repository.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      emit(AddressOperationSuccess(_addresses, 'تم حذف العنوان بنجاح'));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  /// Set address as default
  Future<void> setDefaultAddress(String id) async {
    emit(AddressOperationLoading(_addresses));
    try {
      await _repository.setDefaultAddress(id);

      // Update local list
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();

      emit(AddressOperationSuccess(_addresses, 'تم تعيين العنوان الافتراضي'));
    } catch (e) {
      emit(AddressesError(e.toString()));
    }
  }

  /// Get default address
  AddressEntity? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull;
}
```

---

## 🏗️ UI Examples

### Address List Screen

```dart
class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({Key? key}) : super(key: key);

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressesCubit>().loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عناويني'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/address/add'),
          ),
        ],
      ),
      body: BlocConsumer<AddressesCubit, AddressesState>(
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AddressesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddressesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AddressesLoaded || 
                     state is AddressOperationSuccess) {
            final addresses = state is AddressesLoaded 
                ? state.addresses 
                : (state as AddressOperationSuccess).addresses;

            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('لا توجد عناوين محفوظة'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/address/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة عنوان'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return AddressCard(
                  address: address,
                  onEdit: () => Navigator.pushNamed(
                    context, 
                    '/address/edit',
                    arguments: address,
                  ),
                  onDelete: () => _showDeleteDialog(context, address.id),
                  onSetDefault: () => context
                      .read<AddressesCubit>()
                      .setDefaultAddress(address.id),
                );
              },
            );
          } else if (state is AddressesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AddressesCubit>().loadAddresses(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AddressesCubit>().deleteAddress(addressId);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

### Address Card Widget

```dart
class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    Key? key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    address.isDefault ? Icons.home : Icons.location_on,
                    color: address.isDefault ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'افتراضي',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (address.recipientName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(address.recipientName!),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (address.phone != null) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(address.phone!),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  const Icon(Icons.location_city, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(address.fullAddress)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('تعيين كافتراضي'),
                    ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Add/Edit Address Screen

```dart
class AddEditAddressScreen extends StatefulWidget {
  final AddressEntity? address; // null للإضافة، موجود للتعديل

  const AddEditAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _recipientNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLineController;
  
  String? _selectedCityId;
  String? _selectedMarketId;
  double? _latitude;
  double? _longitude;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label);
    _recipientNameController = TextEditingController(text: address?.recipientName);
    _phoneController = TextEditingController(text: address?.phone);
    _addressLineController = TextEditingController(text: address?.addressLine);
    _selectedCityId = address?.cityId;
    _selectedMarketId = address?.marketId;
    _latitude = address?.latitude;
    _longitude = address?.longitude;
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل العنوان' : 'إضافة عنوان جديد'),
      ),
      body: BlocListener<AddressesCubit, AddressesState>(
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is AddressesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'اسم العنوان *',
                  hintText: 'مثل: المنزل، المحل، العمل',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم العنوان';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستلم',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // City Dropdown (يمكن استبداله بـ Dropdown مع بيانات حقيقية)
              DropdownButtonFormField<String>(
                value: _selectedCityId,
                decoration: const InputDecoration(
                  labelText: 'المدينة *',
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('الرياض')),
                  DropdownMenuItem(value: '2', child: Text('جدة')),
                  DropdownMenuItem(value: '3', child: Text('الدمام')),
                ],
                onChanged: (value) => setState(() => _selectedCityId = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار المدينة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressLineController,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل العنوان *',
                  hintText: 'الحي، الشارع، رقم المبنى، رقم الشقة',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال تفاصيل العنوان';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تعيين كعنوان افتراضي'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة العنوان'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<AddressesCubit>();

      if (widget.address != null) {
        // تحديث
        cubit.updateAddress(
          id: widget.address!.id,
          label: _labelController.text,
          recipientName: _recipientNameController.text,
          phone: _phoneController.text,
          cityId: _selectedCityId,
          addressLine: _addressLineController.text,
          isDefault: _isDefault,
        );
      } else {
        // إضافة
        cubit.createAddress(
          label: _labelController.text,
          recipientName: _recipientNameController.text,
          phone: _phoneController.text,
          cityId: _selectedCityId!,
          addressLine: _addressLineController.text,
          isDefault: _isDefault,
        );
      }
    }
  }
}
```

---

## ⚠️ Error Handling

### Common Errors

```dart
try {
  await context.read<AddressesCubit>().createAddress(...);
} catch (e) {
  if (e is DioException) {
    switch (e.response?.statusCode) {
      case 400:
        // Validation error
        final message = e.response?.data['message'] ?? 'خطأ في البيانات المدخلة';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        break;
      case 401:
        // Unauthorized
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        break;
      case 404:
        // Not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('العنوان غير موجود')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ، الرجاء المحاولة مرة أخرى')),
        );
    }
  }
}
```

---

## 📝 Notes

### تعيين العنوان الافتراضي
- عند تعيين عنوان كافتراضي (`isDefault: true`)، يقوم السيرفر تلقائياً بإلغاء العنوان الافتراضي السابق
- يمكن أن يكون لدى العميل عنوان افتراضي واحد فقط

### Populate City Data
- عند جلب العناوين، يتم populate بيانات المدينة تلقائياً
- يمكن استخدام `city.nameAr` للعرض بالعربية

### Location Coordinates
- `latitude` و `longitude` اختياريان
- يمكن استخدامهما للتكامل مع الخرائط (Google Maps, etc.)

### Validation
- جميع الحقول المطلوبة تتم عليها validation من جانب السيرفر
- يُنصح بعمل validation من جانب التطبيق أيضاً لتجربة مستخدم أفضل

---

## ✅ Best Practices

1. **Cache العناوين محلياً** للوصول السريع
2. **Refresh العناوين** بعد كل عملية إضافة/تحديث/حذف
3. **عرض loading state** أثناء العمليات
4. **إظهار confirmations** قبل الحذف
5. **استخدام default address** في checkout مباشرة
6. **دعم الـ pull-to-refresh** لتحديث العناوين

---

## 🔗 Related Documentation

- [Auth Module](./1-auth.md)
- [Locations](./locations.md) - للحصول على المدن والأسواق
- [Orders](./orders.md) - استخدام العناوين في الطلبات
