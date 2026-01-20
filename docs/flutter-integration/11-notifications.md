# 🔔 Notifications Module - دليل ربط الإشعارات

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ جلب الإشعارات
- ✅ تعليم كمقروء
- ✅ تسجيل Push Token (FCM/APNS)
- ✅ عدد الإشعارات غير المقروءة

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒

---

## 📁 Flutter Models

### Notification Model

```dart
class AppNotification {
  final String id;
  final String? customerId;
  final NotificationCategory category;
  
  // المحتوى
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String? image;
  
  // الإجراء
  final NotificationActionType? actionType;
  final String? actionId;
  final String? actionUrl;
  
  // المرجع
  final String? referenceType;
  final String? referenceId;
  
  // القنوات والحالة
  final List<String> channels; // ['push', 'sms', 'email']
  final Map<String, dynamic>? channelStatus;
  final String? templateId;
  final String? templateCode;
  final String? campaignId;
  final DateTime? scheduledAt;
  
  // الحالة
  final bool isRead;
  final DateTime? readAt;
  final bool isSent;
  final DateTime? sentAt;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    this.customerId,
    required this.category,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    this.image,
    this.actionType,
    this.actionId,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    required this.channels,
    this.channelStatus,
    this.templateId,
    this.templateCode,
    this.campaignId,
    this.scheduledAt,
    required this.isRead,
    this.readAt,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'],
      category: NotificationCategory.fromString(json['category']),
      title: json['title'],
      titleAr: json['titleAr'],
      body: json['body'],
      bodyAr: json['bodyAr'],
      image: json['image'],
      actionType: json['actionType'] != null 
          ? NotificationActionType.fromString(json['actionType']) 
          : null,
      actionId: json['actionId'],
      actionUrl: json['actionUrl'],
      referenceType: json['referenceType'],
      referenceId: json['referenceId'] is String 
          ? json['referenceId'] 
          : json['referenceId']?['_id']?.toString(),
      channels: json['channels'] != null 
          ? List<String>.from(json['channels']) 
          : ['push'],
      channelStatus: json['channelStatus'] as Map<String, dynamic>?,
      templateId: json['templateId'] is String 
          ? json['templateId'] 
          : json['templateId']?['_id']?.toString(),
      templateCode: json['templateCode'],
      campaignId: json['campaignId'] is String 
          ? json['campaignId'] 
          : json['campaignId']?['_id']?.toString(),
      scheduledAt: json['scheduledAt'] != null 
          ? DateTime.parse(json['scheduledAt']) 
          : null,
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isSent: json['isSent'] ?? false,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على العنوان حسب اللغة
  String getTitle(String locale) => locale == 'ar' ? titleAr : title;
  
  /// الحصول على المحتوى حسب اللغة
  String getBody(String locale) => locale == 'ar' ? bodyAr : body;
  
  /// هل يوجد إجراء؟
  bool get hasAction => actionType != null && (actionId != null || actionUrl != null);
}
```

### Enums

```dart
/// فئات الإشعارات
enum NotificationCategory {
  order,       // إشعارات الطلبات
  payment,     // إشعارات الدفع
  promotion,   // العروض والخصومات
  system,      // إشعارات النظام
  account,     // إشعارات الحساب
  support,     // الدعم الفني
  marketing;   // التسويق
  
  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationCategory.system,
    );
  }
  
  String get displayNameAr {
    switch (this) {
      case NotificationCategory.order: return 'الطلبات';
      case NotificationCategory.payment: return 'المدفوعات';
      case NotificationCategory.promotion: return 'العروض';
      case NotificationCategory.system: return 'النظام';
      case NotificationCategory.account: return 'الحساب';
      case NotificationCategory.support: return 'الدعم';
      case NotificationCategory.marketing: return 'التسويق';
    }
  }
  
  IconData get icon {
    switch (this) {
      case NotificationCategory.order: return Icons.shopping_bag;
      case NotificationCategory.payment: return Icons.payment;
      case NotificationCategory.promotion: return Icons.local_offer;
      case NotificationCategory.system: return Icons.settings;
      case NotificationCategory.account: return Icons.person;
      case NotificationCategory.support: return Icons.support_agent;
      case NotificationCategory.marketing: return Icons.campaign;
    }
  }
  
  Color get color {
    switch (this) {
      case NotificationCategory.order: return Colors.blue;
      case NotificationCategory.payment: return Colors.green;
      case NotificationCategory.promotion: return Colors.orange;
      case NotificationCategory.system: return Colors.grey;
      case NotificationCategory.account: return Colors.purple;
      case NotificationCategory.support: return Colors.teal;
      case NotificationCategory.marketing: return Colors.pink;
    }
  }
}

/// أنواع الإجراءات
enum NotificationActionType {
  order,
  product,
  promotion,
  url;
  
  static NotificationActionType fromString(String value) {
    return NotificationActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationActionType.url,
    );
  }
}

/// منصات الـ Push
enum PushPlatform {
  ios,
  android,
  web;
  
  static PushPlatform fromString(String value) {
    return PushPlatform.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PushPlatform.android,
    );
  }
}

/// مزودي الـ Push
enum PushProvider {
  fcm,   // Firebase Cloud Messaging
  apns,  // Apple Push Notification Service
  web;   // Web Push
  
  static PushProvider fromString(String value) {
    return PushProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PushProvider.fcm,
    );
  }
}
```

### NotificationsResponse Model

```dart
class NotificationsResponse {
  final List<AppNotification> notifications;
  final int total;
  final int unreadCount;

  NotificationsResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['data'] as List)
          .map((n) => AppNotification.fromJson(n))
          .toList(),
      total: json['meta']?['total'] ?? 0,
      unreadCount: json['meta']?['unreadCount'] ?? 0,
    );
  }
}
```

### PushToken Model

```dart
class PushToken {
  final String id;
  final String? customerId;
  final String token;
  final PushProvider provider;
  final PushPlatform platform;
  final String? deviceId;
  final String? deviceName;
  final String? deviceModel;
  final String? appVersion;
  final String? osVersion;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  PushToken({
    required this.id,
    this.customerId,
    required this.token,
    required this.provider,
    required this.platform,
    this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.appVersion,
    this.osVersion,
    required this.isActive,
    this.lastUsedAt,
    required this.createdAt,
  });

  factory PushToken.fromJson(Map<String, dynamic> json) {
    return PushToken(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'],
      token: json['token'],
      provider: PushProvider.fromString(json['provider']),
      platform: PushPlatform.fromString(json['platform']),
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceModel: json['deviceModel'],
      appVersion: json['appVersion'],
      osVersion: json['osVersion'],
      isActive: json['isActive'] ?? true,
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

---

## 📞 API Endpoints

### 1️⃣ جلب إشعاراتي

**Endpoint:** `GET /notifications/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | ❌ | عدد النتائج (default: 50) |
| `category` | string | ❌ | فلترة حسب الفئة |
| `isRead` | boolean | ❌ | فلترة المقروء/غير المقروء |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "customerId": "507f1f77bcf86cd799439010",
      "category": "order",
      "title": "Order Confirmed",
      "titleAr": "تم تأكيد الطلب",
      "body": "Your order #ORD-001234 has been confirmed",
      "bodyAr": "تم تأكيد طلبك رقم #ORD-001234",
      "image": null,
      "actionType": "order",
      "actionId": "507f1f77bcf86cd799439001",
      "actionUrl": null,
      "referenceType": "order",
      "referenceId": "507f1f77bcf86cd799439001",
      "channels": ["push"],
      "channelStatus": {
        "push": {
          "sent": true,
          "sentAt": "2024-01-15T10:30:00Z"
        }
      },
      "templateId": null,
      "templateCode": null,
      "campaignId": null,
      "scheduledAt": null,
      "isRead": false,
      "readAt": null,
      "isSent": true,
      "sentAt": "2024-01-15T10:30:00Z",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "message": "Notifications retrieved",
  "messageAr": "تم استرجاع الإشعارات",
  "meta": {
    "total": 25,
    "unreadCount": 5
  }
}
```

**Flutter Code:**
```dart
class NotificationsService {
  final Dio _dio;
  
  NotificationsService(this._dio);
  
  /// جلب إشعاراتي
  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    final response = await _dio.get('/notifications/my', queryParameters: {
      'limit': limit,
      if (category != null) 'category': category.name,
      if (isRead != null) 'isRead': isRead,
    });
    
    if (response.data['success']) {
      return NotificationsResponse(
        notifications: (response.data['data'] as List)
            .map((n) => AppNotification.fromJson(n))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
        unreadCount: response.data['meta']?['unreadCount'] ?? 0,
      );
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
}
```

---

### 2️⃣ تعليم إشعار كمقروء

**Endpoint:** `PUT /notifications/:id/read`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Marked as read",
  "messageAr": "تم التعليم كمقروء"
}
```

**Flutter Code:**
```dart
/// تعليم إشعار كمقروء
Future<void> markAsRead(String notificationId) async {
  final response = await _dio.put('/notifications/$notificationId/read');
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
}
```

---

### 3️⃣ تعليم الكل كمقروء

**Endpoint:** `PUT /notifications/read-all`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "All marked as read",
  "messageAr": "تم تعليم الكل كمقروء"
}
```

**Flutter Code:**
```dart
/// تعليم جميع الإشعارات كمقروءة
Future<void> markAllAsRead() async {
  final response = await _dio.put('/notifications/read-all');
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
}
```

---

### 4️⃣ تسجيل Push Token

**Endpoint:** `POST /notifications/token`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```json
{
  "token": "fMIGGdzaQ...",
  "provider": "fcm",
  "platform": "android",
  "deviceId": "unique_device_id",
  "deviceName": "Samsung Galaxy S23",
  "appVersion": "1.2.0"
}
```

**Parameters:**
- `token`: مطلوب، FCM/APNS token (string)
- `provider`: مطلوب، 'fcm' | 'apns' | 'web' (string)
- `platform`: مطلوب، 'ios' | 'android' | 'web' (string)
- `deviceId`: اختياري، معرف الجهاز الفريد (string)
- `deviceName`: اختياري، اسم الجهاز (string)
- `appVersion`: اختياري، إصدار التطبيق (string)

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "customerId": "507f1f77bcf86cd799439010",
    "token": "fMIGGdzaQ...",
    "provider": "fcm",
    "platform": "android",
    "deviceId": "unique_device_id",
    "deviceName": "Samsung Galaxy S23",
    "deviceModel": null,
    "appVersion": "1.2.0",
    "osVersion": null,
    "isActive": true,
    "lastUsedAt": "2024-01-15T10:30:00Z",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  },
  "message": "Token registered",
  "messageAr": "تم تسجيل التوكن"
}
```

**Flutter Code:**
```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// تسجيل Push Token
Future<PushToken> registerPushToken() async {
  // الحصول على FCM token
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) throw Exception('Failed to get FCM token');
  
  // معلومات الجهاز
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();
  
  String platform;
  String? deviceId;
  String? deviceName;
  String? deviceModel;
  String? osVersion;
  
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    platform = 'android';
    deviceId = androidInfo.id;
    deviceName = androidInfo.model;
    deviceModel = androidInfo.device;
    osVersion = androidInfo.version.release;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    platform = 'ios';
    deviceId = iosInfo.identifierForVendor;
    deviceName = iosInfo.name;
    deviceModel = iosInfo.model;
    osVersion = iosInfo.systemVersion;
  } else {
    platform = 'web';
  }
  
  final response = await _dio.post('/notifications/token', data: {
    'token': fcmToken,
    'provider': Platform.isIOS ? 'apns' : 'fcm',
    'platform': platform,
    if (deviceId != null) 'deviceId': deviceId,
    if (deviceName != null) 'deviceName': deviceName,
    if (packageInfo.version != null) 'appVersion': packageInfo.version,
  });
  
  if (response.data['success']) {
    return PushToken.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr'] ?? response.data['message']);
}
```

---

## 🧩 NotificationsService الكامل

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NotificationsService {
  final Dio _dio;
  
  NotificationsService(this._dio);
  
  /// جلب إشعاراتي
  Future<NotificationsResponse> getMyNotifications({
    int limit = 50,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    final response = await _dio.get('/notifications/my', queryParameters: {
      'limit': limit,
      if (category != null) 'category': category.name,
      if (isRead != null) 'isRead': isRead,
    });
    
    if (response.data['success']) {
      return NotificationsResponse(
        notifications: (response.data['data'] as List)
            .map((n) => AppNotification.fromJson(n))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
        unreadCount: response.data['meta']?['unreadCount'] ?? 0,
      );
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
  
  /// تعليم إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    final response = await _dio.put('/notifications/$notificationId/read');
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    }
  }
  
  /// تعليم الكل كمقروء
  Future<void> markAllAsRead() async {
    final response = await _dio.put('/notifications/read-all');
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    }
  }
  
  /// تسجيل Push Token
  Future<PushToken> registerPushToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) throw Exception('Failed to get FCM token');
    
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    String platform;
    String? deviceId;
    String? deviceName;
    String? deviceModel;
    String? osVersion;
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      platform = 'android';
      deviceId = androidInfo.id;
      deviceName = androidInfo.model;
      deviceModel = androidInfo.device;
      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      platform = 'ios';
      deviceId = iosInfo.identifierForVendor;
      deviceName = iosInfo.name;
      deviceModel = iosInfo.model;
      osVersion = iosInfo.systemVersion;
    } else {
      platform = 'web';
    }
    
    final response = await _dio.post('/notifications/token', data: {
      'token': fcmToken,
      'provider': Platform.isIOS ? 'apns' : 'fcm',
      'platform': platform,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
      if (packageInfo.version != null) 'appVersion': packageInfo.version,
    });
    
    if (response.data['success']) {
      return PushToken.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
  
  /// جلب عدد الإشعارات غير المقروءة فقط
  Future<int> getUnreadCount() async {
    final response = await getMyNotifications(page: 1, limit: 1);
    return response.unreadCount;
  }
}
```

---

## 🎯 أمثلة الاستخدام

### إعداد Firebase Messaging

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationManager {
  final NotificationsService _notificationsService;
  
  PushNotificationManager(this._notificationsService);
  
  Future<void> initialize() async {
    // طلب الإذن
    await _requestPermission();
    
    // تسجيل الـ token
    await _registerToken();
    
    // الاستماع لتحديث الـ token
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _registerToken();
    });
    
    // معالجة الإشعارات في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // معالجة النقر على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }
  
  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Push notifications not authorized');
    }
  }
  
  Future<void> _registerToken() async {
    try {
      await _notificationsService.registerPushToken();
      print('Push token registered successfully');
    } catch (e) {
      print('Failed to register push token: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    // عرض إشعار محلي أو snackbar
    print('Received foreground message: ${message.notification?.title}');
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // التنقل للصفحة المناسبة بناءً على الـ data
    final actionType = message.data['actionType'];
    final actionId = message.data['actionId'];
    
    if (actionType == 'order' && actionId != null) {
      // انتقل لصفحة تفاصيل الطلب
      Navigator.pushNamed(context, '/orders/$actionId');
    }
  }
}
```

### شاشة الإشعارات

```dart
class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await notificationsService.getMyNotifications();
      setState(() {
        _notifications = response.notifications;
        _unreadCount = response.unreadCount;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('تعليم الكل كمقروء'),
            ),
        ],
      ),
      body: _isLoading
          ? LoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(notification),
                  );
                },
              ),
            ),
    );
  }
  
  Future<void> _markAllAsRead() async {
    await notificationsService.markAllAsRead();
    _loadNotifications();
  }
  
  Future<void> _handleNotificationTap(AppNotification notification) async {
    // تعليم كمقروء
    if (!notification.isRead) {
      await notificationsService.markAsRead(notification.id);
    }
    
    // التنقل للإجراء
    if (notification.hasAction) {
      switch (notification.actionType) {
        case NotificationActionType.order:
          Navigator.pushNamed(context, '/orders/${notification.actionId}');
          break;
        case NotificationActionType.product:
          Navigator.pushNamed(context, '/products/${notification.actionId}');
          break;
        case NotificationActionType.url:
          launchUrl(Uri.parse(notification.actionUrl!));
          break;
        default:
          break;
      }
    }
  }
}
```

### عرض Badge لعدد الإشعارات

```dart
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// الاستخدام في AppBar
AppBar(
  actions: [
    FutureBuilder<int>(
      future: notificationsService.getUnreadCount(),
      builder: (context, snapshot) {
        return NotificationBadge(
          count: snapshot.data ?? 0,
          child: IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        );
      },
    ),
  ],
)
```

---

## 📝 ملخص الـ Endpoints

### Customer Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/notifications/my` | ✅ | جلب إشعاراتي |
| PUT | `/notifications/:id/read` | ✅ | تعليم كمقروء |
| PUT | `/notifications/read-all` | ✅ | تعليم الكل كمقروء |
| POST | `/notifications/token` | ✅ | تسجيل Push Token |

### Admin Endpoints (للتوثيق فقط)

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| POST | `/notifications/send` | Admin | إرسال إشعار مخصص |
| GET | `/notifications/templates` | Admin | جلب قوالب الإشعارات |
| POST | `/notifications/templates` | Super Admin | إنشاء قالب إشعار |
| PUT | `/notifications/templates/:id` | Super Admin | تحديث قالب إشعار |
| GET | `/notifications/campaigns` | Admin | جلب حملات الإشعارات |
| POST | `/notifications/campaigns` | Admin | إنشاء حملة إشعارات |
| POST | `/notifications/campaigns/:id/launch` | Admin | إطلاق حملة إشعارات |

---

## 📱 إعداد Firebase في Flutter

### 1. أضف الـ dependencies

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1
```

### 2. أضف إعداد Android

في `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. أضف إعداد iOS

في `ios/Runner/AppDelegate.swift`:
```swift
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    // ...
  }
}
```

---

> 🔗 **السابق:** [orders.md](./orders.md) - دليل الطلبات  
> 🔗 **التالي:** [products.md](./products.md) - دليل المنتجات (قريباً)
