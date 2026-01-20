# 🎯 Banners Module - دليل ربط البانرات

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ جلب البانرات حسب الموضع (Position)
- ✅ تتبع المشاهدات والنقرات (Impressions & Clicks)
- ✅ دعم أنواع مختلفة من البانرات (Hero, Promotional, Category, Popup, etc.)
- ✅ دعم الصور للجوال وسطح المكتب
- ✅ ربط البانرات بمنتجات أو فئات أو صفحات
- ✅ جدولة البانرات (Start Date & End Date)
- ✅ استهداف العملاء (Customer Targeting)

> **ملاحظة**: جميع الـ endpoints هنا **عامة (Public)** ولا تحتاج Token.

---

## 📁 Flutter Models

### Banner Type Enum

```dart
enum BannerType {
  hero,
  promotional,
  category,
  popup,
  sidebar,
  inline;

  String get value {
    switch (this) {
      case BannerType.hero: return 'hero';
      case BannerType.promotional: return 'promotional';
      case BannerType.category: return 'category';
      case BannerType.popup: return 'popup';
      case BannerType.sidebar: return 'sidebar';
      case BannerType.inline: return 'inline';
    }
  }

  String getName(String locale) {
    switch (this) {
      case BannerType.hero:
        return locale == 'ar' ? 'بانر رئيسي' : 'Hero';
      case BannerType.promotional:
        return locale == 'ar' ? 'ترويجي' : 'Promotional';
      case BannerType.category:
        return locale == 'ar' ? 'فئة' : 'Category';
      case BannerType.popup:
        return locale == 'ar' ? 'منبثق' : 'Popup';
      case BannerType.sidebar:
        return locale == 'ar' ? 'شريط جانبي' : 'Sidebar';
      case BannerType.inline:
        return locale == 'ar' ? 'ضمني' : 'Inline';
    }
  }
}
```

### Banner Position Enum

```dart
enum BannerPosition {
  homeTop,
  homeMiddle,
  homeBottom,
  categoryTop,
  productTop,
  cartTop,
  checkoutTop,
  globalPopup;

  String get value {
    switch (this) {
      case BannerPosition.homeTop: return 'home_top';
      case BannerPosition.homeMiddle: return 'home_middle';
      case BannerPosition.homeBottom: return 'home_bottom';
      case BannerPosition.categoryTop: return 'category_top';
      case BannerPosition.productTop: return 'product_top';
      case BannerPosition.cartTop: return 'cart_top';
      case BannerPosition.checkoutTop: return 'checkout_top';
      case BannerPosition.globalPopup: return 'global_popup';
    }
  }

  String getName(String locale) {
    switch (this) {
      case BannerPosition.homeTop:
        return locale == 'ar' ? 'أعلى الصفحة الرئيسية' : 'Home Top';
      case BannerPosition.homeMiddle:
        return locale == 'ar' ? 'وسط الصفحة الرئيسية' : 'Home Middle';
      case BannerPosition.homeBottom:
        return locale == 'ar' ? 'أسفل الصفحة الرئيسية' : 'Home Bottom';
      case BannerPosition.categoryTop:
        return locale == 'ar' ? 'أعلى صفحة الفئة' : 'Category Top';
      case BannerPosition.productTop:
        return locale == 'ar' ? 'أعلى صفحة المنتج' : 'Product Top';
      case BannerPosition.cartTop:
        return locale == 'ar' ? 'أعلى السلة' : 'Cart Top';
      case BannerPosition.checkoutTop:
        return locale == 'ar' ? 'أعلى الدفع' : 'Checkout Top';
      case BannerPosition.globalPopup:
        return locale == 'ar' ? 'منبثق عام' : 'Global Popup';
    }
  }
}
```

### Banner Action Type Enum

```dart
enum BannerActionType {
  link,
  product,
  category,
  brand,
  page,
  none;

  String get value {
    switch (this) {
      case BannerActionType.link: return 'link';
      case BannerActionType.product: return 'product';
      case BannerActionType.category: return 'category';
      case BannerActionType.brand: return 'brand';
      case BannerActionType.page: return 'page';
      case BannerActionType.none: return 'none';
    }
  }
}
```

### Banner Media Model

```dart
class BannerMedia {
  final String imageDesktopAr;
  final String imageDesktopEn;
  final String? imageMobileAr;
  final String? imageMobileEn;
  final String? videoUrl;
  final String? altTextAr;
  final String? altTextEn;

  BannerMedia({
    required this.imageDesktopAr,
    required this.imageDesktopEn,
    this.imageMobileAr,
    this.imageMobileEn,
    this.videoUrl,
    this.altTextAr,
    this.altTextEn,
  });

  factory BannerMedia.fromJson(Map<String, dynamic> json) {
    return BannerMedia(
      imageDesktopAr: json['imageDesktopAr'],
      imageDesktopEn: json['imageDesktopEn'],
      imageMobileAr: json['imageMobileAr'],
      imageMobileEn: json['imageMobileEn'],
      videoUrl: json['videoUrl'],
      altTextAr: json['altTextAr'],
      altTextEn: json['altTextEn'],
    );
  }

  /// الحصول على الصورة حسب اللغة والجهاز
  String getImage({required String locale, required bool isMobile}) {
    if (isMobile) {
      return locale == 'ar' 
          ? (imageMobileAr ?? imageDesktopAr)
          : (imageMobileEn ?? imageDesktopEn);
    }
    return locale == 'ar' ? imageDesktopAr : imageDesktopEn;
  }

  /// الحصول على نص بديل حسب اللغة
  String? getAltText(String locale) => 
      locale == 'ar' ? altTextAr : altTextEn;
  
  /// هل يحتوي على فيديو؟
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}
```

### Banner Action Model

```dart
class BannerAction {
  final BannerActionType type;
  final String? url;
  final String? refId;
  final String? refModel; // 'Product', 'Category', 'Brand', 'Page'
  final bool openInNewTab;

  BannerAction({
    required this.type,
    this.url,
    this.refId,
    this.refModel,
    this.openInNewTab = false,
  });

  factory BannerAction.fromJson(Map<String, dynamic> json) {
    return BannerAction(
      type: BannerActionType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => BannerActionType.none,
      ),
      url: json['url'],
      refId: json['refId'] is String 
          ? json['refId'] 
          : json['refId']?['_id']?.toString(),
      refModel: json['refModel'],
      openInNewTab: json['openInNewTab'] ?? false,
    );
  }

  /// هل البانر قابل للنقر؟
  bool get isClickable => type != BannerActionType.none;
  
  /// الحصول على الرابط للتنقل
  String? get navigationPath {
    switch (type) {
      case BannerActionType.link:
        return url;
      case BannerActionType.product:
        return '/product/${refId}';
      case BannerActionType.category:
        return '/category/${refId}';
      case BannerActionType.brand:
        return '/brand/${refId}';
      case BannerActionType.page:
        return '/page/${refId}';
      case BannerActionType.none:
        return null;
    }
  }
}
```

### Banner Content Model

```dart
class BannerContent {
  final String? headingAr;
  final String? headingEn;
  final String? subheadingAr;
  final String? subheadingEn;
  final String? buttonTextAr;
  final String? buttonTextEn;
  final String? textColor;
  final String? overlayColor;
  final double? overlayOpacity;

  BannerContent({
    this.headingAr,
    this.headingEn,
    this.subheadingAr,
    this.subheadingEn,
    this.buttonTextAr,
    this.buttonTextEn,
    this.textColor,
    this.overlayColor,
    this.overlayOpacity,
  });

  factory BannerContent.fromJson(Map<String, dynamic> json) {
    return BannerContent(
      headingAr: json['headingAr'],
      headingEn: json['headingEn'],
      subheadingAr: json['subheadingAr'],
      subheadingEn: json['subheadingEn'],
      buttonTextAr: json['buttonTextAr'],
      buttonTextEn: json['buttonTextEn'],
      textColor: json['textColor'],
      overlayColor: json['overlayColor'],
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble(),
    );
  }

  /// الحصول على العنوان حسب اللغة
  String? getHeading(String locale) => 
      locale == 'ar' ? headingAr : headingEn;
  
  /// الحصول على العنوان الفرعي حسب اللغة
  String? getSubheading(String locale) => 
      locale == 'ar' ? subheadingAr : subheadingEn;
  
  /// الحصول على نص الزر حسب اللغة
  String? getButtonText(String locale) => 
      locale == 'ar' ? buttonTextAr : buttonTextEn;
  
  /// تحويل لون النص إلى Color
  Color? getTextColor() {
    if (textColor == null) return null;
    final hex = textColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
  
  /// تحويل لون الـ Overlay إلى Color
  Color? getOverlayColor() {
    if (overlayColor == null) return null;
    final hex = overlayColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### Banner Targeting Model

```dart
class BannerTargeting {
  final List<String> customerSegments;
  final List<String>? categories;
  final List<String> userTypes; // 'guest', 'registered', 'all'
  final List<String> devices; // 'mobile', 'tablet', 'desktop'

  BannerTargeting({
    this.customerSegments = const [],
    this.categories,
    this.userTypes = const ['all'],
    this.devices = const [],
  });

  factory BannerTargeting.fromJson(Map<String, dynamic> json) {
    return BannerTargeting(
      customerSegments: List<String>.from(json['customerSegments'] ?? []),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      userTypes: List<String>.from(json['userTypes'] ?? ['all']),
      devices: List<String>.from(json['devices'] ?? []),
    );
  }

  /// هل البانر يستهدف جميع المستخدمين؟
  bool get isForAllUsers => userTypes.contains('all');
  
  /// هل البانر يستهدف الضيوف فقط؟
  bool get isForGuestsOnly => 
      userTypes.contains('guest') && !userTypes.contains('registered');
  
  /// هل البانر يستهدف المستخدمين المسجلين فقط؟
  bool get isForRegisteredOnly => 
      userTypes.contains('registered') && !userTypes.contains('guest');
  
  /// هل البانر يستهدف جهاز معين؟
  bool isForDevice(String device) => 
      devices.isEmpty || devices.contains(device);
}
```

### Banner Model

```dart
class Banner {
  final String id;
  final String nameAr;
  final String nameEn;
  final BannerType type;
  final BannerPosition position;
  final BannerMedia media;
  final BannerAction action;
  final BannerContent content;
  final BannerTargeting targeting;
  
  // Schedule
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Status
  final bool isActive;
  final int sortOrder;
  final int priority;
  
  // Statistics
  final int impressions;
  final int clicks;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  Banner({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.position,
    required this.media,
    required this.action,
    required this.content,
    required this.targeting,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sortOrder = 0,
    this.priority = 0,
    this.impressions = 0,
    this.clicks = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['_id'] ?? json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      type: BannerType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => BannerType.promotional,
      ),
      position: BannerPosition.values.firstWhere(
        (e) => e.value == json['position'],
        orElse: () => BannerPosition.homeTop,
      ),
      media: BannerMedia.fromJson(json['media']),
      action: BannerAction.fromJson(json['action'] ?? {}),
      content: BannerContent.fromJson(json['content'] ?? {}),
      targeting: BannerTargeting.fromJson(json['targeting'] ?? {}),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      priority: json['priority'] ?? 0,
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => 
      locale == 'ar' ? nameAr : nameEn;
  
  /// هل البانر نشط حالياً؟
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
  
  /// معدل النقر (CTR)
  double get clickThroughRate {
    if (impressions == 0) return 0.0;
    return (clicks / impressions) * 100;
  }
  
  /// هل البانر من نوع Popup؟
  bool get isPopup => type == BannerType.popup;
}
```

---

## 📞 API Endpoints

### 1️⃣ جلب البانرات حسب الموضع

**Endpoint:** `GET /banners`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `placement` | string | ❌ | موضع البانر (افتراضي: `home_top`) |

**قيم `placement` المتاحة:**
- `home_top` - أعلى الصفحة الرئيسية
- `home_middle` - وسط الصفحة الرئيسية
- `home_bottom` - أسفل الصفحة الرئيسية
- `category_top` - أعلى صفحة الفئة
- `product_top` - أعلى صفحة المنتج
- `cart_top` - أعلى السلة
- `checkout_top` - أعلى صفحة الدفع
- `global_popup` - منبثق عام

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "nameAr": "عرض خاص على الشاشات",
      "nameEn": "Special Offer on Screens",
      "type": "promotional",
      "position": "home_top",
      "media": {
        "imageDesktopAr": "https://cdn.example.com/banners/screens-ar-desktop.jpg",
        "imageDesktopEn": "https://cdn.example.com/banners/screens-en-desktop.jpg",
        "imageMobileAr": "https://cdn.example.com/banners/screens-ar-mobile.jpg",
        "imageMobileEn": "https://cdn.example.com/banners/screens-en-mobile.jpg",
        "altTextAr": "عرض خاص على الشاشات",
        "altTextEn": "Special Offer on Screens"
      },
      "action": {
        "type": "category",
        "refId": "507f1f77bcf86cd799439001",
        "refModel": "Category",
        "openInNewTab": false
      },
      "content": {
        "headingAr": "عرض خاص",
        "headingEn": "Special Offer",
        "subheadingAr": "خصم 20% على جميع الشاشات",
        "subheadingEn": "20% off on all screens",
        "buttonTextAr": "تسوق الآن",
        "buttonTextEn": "Shop Now",
        "textColor": "#FFFFFF",
        "overlayColor": "#000000",
        "overlayOpacity": 0.3
      },
      "targeting": {
        "customerSegments": [],
        "categories": [],
        "userTypes": ["all"],
        "devices": []
      },
      "startDate": "2024-01-01T00:00:00.000Z",
      "endDate": "2024-12-31T23:59:59.000Z",
      "isActive": true,
      "sortOrder": 1,
      "priority": 10,
      "impressions": 1250,
      "clicks": 45,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "message": "Banners retrieved",
  "messageAr": "تم استرجاع البانرات"
}
```

**Flutter Code:**
```dart
class BannersService {
  final Dio _dio;
  
  BannersService(this._dio);
  
  Future<List<Banner>> getBanners({
    BannerPosition? placement,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (placement != null) {
        queryParams['placement'] = placement.value;
      }
      
      final response = await _dio.get(
        '/banners',
        queryParameters: queryParams,
      );
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((b) => Banner.fromJson(b))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

---

### 2️⃣ تسجيل مشاهدة البانر (Track Impression)

**Endpoint:** `POST /content/banners/:id/impression`

> **ملاحظة**: يُنصح باستدعاء هذا الـ endpoint عند عرض البانر للمستخدم لتتبع الإحصائيات.

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Impression recorded",
  "messageAr": "تم تسجيل المشاهدة"
}
```

**Flutter Code:**
```dart
Future<void> recordImpression(String bannerId) async {
  try {
    await _dio.post('/content/banners/$bannerId/impression');
  } on DioException catch (e) {
    // لا نرمي خطأ هنا لأن تتبع الإحصائيات ليس حرجاً
    print('Failed to record impression: $e');
  }
}
```

---

### 3️⃣ تسجيل نقر على البانر (Track Click)

**Endpoint:** `POST /content/banners/:id/click`

> **ملاحظة**: يُنصح باستدعاء هذا الـ endpoint عند النقر على البانر لتتبع الإحصائيات.

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Click recorded",
  "messageAr": "تم تسجيل النقر"
}
```

**Flutter Code:**
```dart
Future<void> recordClick(String bannerId) async {
  try {
    await _dio.post('/content/banners/$bannerId/click');
  } on DioException catch (e) {
    // لا نرمي خطأ هنا لأن تتبع الإحصائيات ليس حرجاً
    print('Failed to record click: $e');
  }
}
```

---

## 🛠️ BannersService الكامل

```dart
import 'package:dio/dio.dart';

class BannersService {
  final Dio _dio;
  
  BannersService(this._dio);
  
  /// جلب البانرات حسب الموضع
  Future<List<Banner>> getBanners({
    BannerPosition? placement,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (placement != null) {
        queryParams['placement'] = placement.value;
      }
      
      final response = await _dio.get(
        '/banners',
        queryParameters: queryParams,
      );
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((b) => Banner.fromJson(b))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// تسجيل مشاهدة البانر
  Future<void> recordImpression(String bannerId) async {
    try {
      await _dio.post('/content/banners/$bannerId/impression');
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      print('Failed to record impression: $e');
    }
  }
  
  /// تسجيل نقر على البانر
  Future<void> recordClick(String bannerId) async {
    try {
      await _dio.post('/content/banners/$bannerId/click');
    } catch (e) {
      // لا نرمي خطأ لأن تتبع الإحصائيات ليس حرجاً
      print('Failed to record click: $e');
    }
  }
  
  // ═════════════════════════════════════
  // Error Handling
  // ═════════════════════════════════════
  
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        final message = data['messageAr'] ?? data['message'] ?? 'خطأ غير معروف';
        return Exception(message);
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return Exception('لا يوجد اتصال بالإنترنت');
      default:
        return Exception('حدث خطأ غير متوقع');
    }
  }
}
```

---

## 🎯 State Management - BannersCubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class BannersState {}

class BannersInitial extends BannersState {}

class BannersLoading extends BannersState {}

class BannersLoaded extends BannersState {
  final List<Banner> banners;
  
  BannersLoaded(this.banners);
}

class BannersError extends BannersState {
  final String message;
  
  BannersError(this.message);
}

// Cubit
class BannersCubit extends Cubit<BannersState> {
  final BannersService _service;
  
  BannersCubit(this._service) : super(BannersInitial());
  
  /// جلب البانرات
  Future<void> loadBanners({BannerPosition? placement}) async {
    emit(BannersLoading());
    try {
      final banners = await _service.getBanners(placement: placement);
      emit(BannersLoaded(banners));
    } catch (e) {
      emit(BannersError(e.toString()));
    }
  }
  
  /// تسجيل مشاهدة
  Future<void> trackImpression(String bannerId) async {
    await _service.recordImpression(bannerId);
  }
  
  /// تسجيل نقر
  Future<void> trackClick(String bannerId) async {
    await _service.recordClick(bannerId);
  }
}
```

---

## 🏗️ UI Examples

### Banner Widget

```dart
class BannerWidget extends StatelessWidget {
  final Banner banner;
  final String locale;
  final bool isMobile;
  final VoidCallback? onTap;
  
  const BannerWidget({
    required this.banner,
    required this.locale,
    required this.isMobile,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.media.getImage(
      locale: locale,
      isMobile: isMobile,
    );
    
    return BlocProvider(
      create: (context) => BannersCubit(BannersService(dio))
        ..trackImpression(banner.id),
      child: GestureDetector(
        onTap: () {
          if (banner.action.isClickable) {
            context.read<BannersCubit>().trackClick(banner.id);
            _handleBannerTap(context);
            onTap?.call();
          }
        },
        child: Stack(
          children: [
            // Banner Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 64),
                  );
                },
              ),
            ),
            
            // Overlay
            if (banner.content.overlayColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: banner.content.getOverlayColor()?.withOpacity(
                      banner.content.overlayOpacity ?? 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            
            // Content
            if (banner.content.getHeading(locale) != null ||
                banner.content.getSubheading(locale) != null ||
                banner.content.getButtonText(locale) != null)
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner.content.getHeading(locale) != null)
                        Text(
                          banner.content.getHeading(locale)!,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: banner.content.getTextColor() ?? Colors.white,
                          ),
                        ),
                      if (banner.content.getSubheading(locale) != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          banner.content.getSubheading(locale)!,
                          style: TextStyle(
                            fontSize: 16,
                            color: banner.content.getTextColor() ?? Colors.white,
                          ),
                        ),
                      ],
                      if (banner.content.getButtonText(locale) != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BannersCubit>().trackClick(banner.id);
                            _handleBannerTap(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                          ),
                          child: Text(
                            banner.content.getButtonText(locale)!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _handleBannerTap(BuildContext context) {
    if (!banner.action.isClickable) return;
    
    final path = banner.action.navigationPath;
    if (path != null) {
      Navigator.pushNamed(context, path);
    } else if (banner.action.url != null) {
      // Open URL in browser
      // launchUrl(Uri.parse(banner.action.url!));
    }
  }
}
```

### Home Screen with Banners

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return BlocProvider(
      create: (context) => BannersCubit(BannersService(dio))
        ..loadBanners(placement: BannerPosition.homeTop),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<BannersCubit>()
                .loadBanners(placement: BannerPosition.homeTop);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('الصفحة الرئيسية'),
                ),
              ),
              
              // Top Banners
              SliverToBoxAdapter(
                child: BlocBuilder<BannersCubit, BannersState>(
                  builder: (context, state) {
                    if (state is BannersLoaded && state.banners.isNotEmpty) {
                      return Column(
                        children: [
                          // Hero Banner (Full Width)
                          if (state.banners.any((b) => b.type == BannerType.hero))
                            BannerWidget(
                              banner: state.banners.firstWhere(
                                (b) => b.type == BannerType.hero,
                              ),
                              locale: locale,
                              isMobile: isMobile,
                            ),
                          
                          // Promotional Banners (Carousel)
                          if (state.banners.any((b) => b.type == BannerType.promotional))
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                itemCount: state.banners
                                    .where((b) => b.type == BannerType.promotional)
                                    .length,
                                itemBuilder: (context, index) {
                                  final promotionalBanners = state.banners
                                      .where((b) => b.type == BannerType.promotional)
                                      .toList();
                                  return BannerWidget(
                                    banner: promotionalBanners[index],
                                    locale: locale,
                                    isMobile: isMobile,
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    } else if (state is BannersLoading) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              
              // Other Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Categories Section
                    // Products Section
                    // etc.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Popup Banner Widget

```dart
class PopupBannerWidget extends StatelessWidget {
  final Banner banner;
  final String locale;
  final bool isMobile;
  
  const PopupBannerWidget({
    required this.banner,
    required this.locale,
    required this.isMobile,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!banner.isPopup) return const SizedBox();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              banner.media.getImage(locale: locale, isMobile: isMobile),
              fit: BoxFit.cover,
            ),
          ),
          
          // Close Button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Content
          if (banner.content.getHeading(locale) != null ||
              banner.content.getButtonText(locale) != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (banner.content.getHeading(locale) != null)
                      Text(
                        banner.content.getHeading(locale)!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (banner.content.getButtonText(locale) != null) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          context.read<BannersCubit>().trackClick(banner.id);
                          Navigator.pop(context);
                          // Navigate to action
                        },
                        child: Text(banner.content.getButtonText(locale)!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/banners` | ❌ | جلب البانرات حسب الموضع |
| POST | `/content/banners/:id/impression` | ❌ | تسجيل مشاهدة البانر |
| POST | `/content/banners/:id/click` | ❌ | تسجيل نقر على البانر |

---

## ⚠️ ملاحظات مهمة

### أنواع البانرات (Banner Types)
- `hero`: بانر رئيسي كبير
- `promotional`: بانر ترويجي
- `category`: بانر للفئات
- `popup`: بانر منبثق
- `sidebar`: بانر في الشريط الجانبي
- `inline`: بانر ضمني في المحتوى

### مواضع البانرات (Banner Positions)
- `home_top`: أعلى الصفحة الرئيسية
- `home_middle`: وسط الصفحة الرئيسية
- `home_bottom`: أسفل الصفحة الرئيسية
- `category_top`: أعلى صفحة الفئة
- `product_top`: أعلى صفحة المنتج
- `cart_top`: أعلى السلة
- `checkout_top`: أعلى صفحة الدفع
- `global_popup`: منبثق عام

### أنواع الإجراءات (Action Types)
- `link`: رابط خارجي
- `product`: منتج
- `category`: فئة
- `brand`: علامة تجارية
- `page`: صفحة ثابتة
- `none`: بدون إجراء

### الصور
- البانرات تدعم صور منفصلة للجوال وسطح المكتب
- صور منفصلة للعربية والإنجليزية
- إذا لم توجد صورة للجوال، يتم استخدام صورة سطح المكتب

### الجدولة
- يمكن جدولة البانرات باستخدام `startDate` و `endDate`
- البانرات النشطة فقط يتم إرجاعها (مع مراعاة التواريخ)

### الاستهداف (Targeting)
- يمكن استهداف البانرات لفئات عملاء محددة
- يمكن استهداف البانرات للضيوف أو المسجلين أو الجميع
- يمكن استهداف البانرات لأجهزة محددة (mobile, tablet, desktop)

### الإحصائيات
- `impressions`: عدد المشاهدات
- `clicks`: عدد النقرات
- `ctr`: معدل النقر (Click Through Rate) = (clicks / impressions) * 100

---

## 🔗 Related Documentation

- [Products Module](./3-products.md) - المنتجات المرتبطة
- [Catalog Module](./2-catalog.md) - الفئات المرتبطة

---

> 🔗 **السابق:** [14-educational-content.md](./14-educational-content.md) - دليل المحتوى التعليمي  
> 🔗 **التالي:** [README.md](./README.md) - الفهرس العام
