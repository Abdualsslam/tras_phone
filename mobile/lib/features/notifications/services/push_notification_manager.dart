/// Push Notification Manager - Handles FCM/APNS push notifications
library;

import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/models/push_token_model.dart';
import '../data/repositories/notifications_repository.dart';

/// Callback type for notification tap handling
typedef NotificationTapCallback = void Function(Map<String, dynamic> data);

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Handling background message: ${message.messageId}',
    name: 'PushNotificationManager',
  );
}

class PushNotificationManager {
  final NotificationsRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotifications;
  
  NotificationTapCallback? _onNotificationTap;
  
  /// Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tras_phone_channel',
    'TRAS Phone Notifications',
    description: 'Notifications for TRAS Phone app',
    importance: Importance.high,
  );

  PushNotificationManager({
    required NotificationsRepository repository,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _repository = repository,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Initialize push notifications
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap;
    
    developer.log('Initializing push notifications', name: 'PushNotificationManager');

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Register FCM token
    await _registerToken();

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      developer.log('FCM token refreshed', name: 'PushNotificationManager');
      _registerToken();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    developer.log('Push notifications initialized', name: 'PushNotificationManager');
  }

  /// Request notification permission
  Future<bool> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final authorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    developer.log(
      'Notification permission: ${settings.authorizationStatus}',
      name: 'PushNotificationManager',
    );

    return authorized;
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Register FCM token with backend
  Future<void> _registerToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        developer.log('Failed to get FCM token', name: 'PushNotificationManager');
        return;
      }

      developer.log('FCM token obtained', name: 'PushNotificationManager');

      // Get device info
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String platform;
      String provider;
      String? deviceId;
      String? deviceName;
      String? deviceModel;
      String? osVersion;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        platform = 'android';
        provider = 'fcm';
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
        deviceModel = androidInfo.device;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        platform = 'ios';
        provider = 'apns';
        deviceId = iosInfo.identifierForVendor;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        osVersion = iosInfo.systemVersion;
      } else {
        platform = 'web';
        provider = 'fcm';
      }

      final request = PushTokenRequest(
        token: fcmToken,
        provider: provider,
        platform: platform,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceModel: deviceModel,
        appVersion: packageInfo.version,
        osVersion: osVersion,
      );

      final result = await _repository.registerPushToken(request);

      result.fold(
        (failure) {
          developer.log(
            'Failed to register push token: ${failure.message}',
            name: 'PushNotificationManager',
          );
          // Retry after a delay if registration fails
          Future.delayed(const Duration(seconds: 5), () {
            developer.log(
              'Retrying push token registration',
              name: 'PushNotificationManager',
            );
            _registerToken();
          });
        },
        (token) {
          developer.log(
            'Push token registered successfully',
            name: 'PushNotificationManager',
          );
        },
      );
    } catch (e) {
      developer.log(
        'Error registering push token: $e',
        name: 'PushNotificationManager',
      );
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      developer.log(
        'Received foreground message: ${message.notification?.title}',
        name: 'PushNotificationManager',
      );

      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          title: notification.title ?? 'إشعار جديد',
          body: notification.body ?? '',
          payload: message.data,
        );
      } else if (message.data.isNotEmpty) {
        // Handle data-only messages
        final title = message.data['title'] as String? ?? 'إشعار جديد';
        final body = message.data['body'] as String? ?? '';
        _showLocalNotification(
          title: title,
          body: body,
          payload: message.data,
        );
      }
    } catch (e) {
      developer.log(
        'Error handling foreground message: $e',
        name: 'PushNotificationManager',
      );
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert payload to string for storage
    // Store notificationId or actionType/actionId for navigation
    String? payloadString;
    if (payload != null) {
      // Prefer notificationId if available, otherwise use actionType and actionId
      if (payload.containsKey('notificationId')) {
        payloadString = payload['notificationId'].toString();
      } else if (payload.containsKey('actionType') && payload.containsKey('actionId')) {
        payloadString = '${payload['actionType']}:${payload['actionId']}';
      } else {
        // Fallback: convert entire payload to string (simplified)
        payloadString = payload.toString();
      }
    }

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payloadString,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    developer.log(
      'Notification tapped: ${message.data}',
      name: 'PushNotificationManager',
    );

    // Extract notification data from message
    final data = Map<String, dynamic>.from(message.data);
    
    // Add notification data from message if available
    if (message.notification != null) {
      data['title'] = message.notification!.title;
      data['body'] = message.notification!.body;
    }

    // Call the callback with the data
    _onNotificationTap?.call(data);
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    developer.log(
      'Local notification tapped: ${response.payload}',
      name: 'PushNotificationManager',
    );

    if (response.payload != null) {
      try {
        // Try to parse payload as JSON string
        // Note: Payload is stored as string, so we need to extract the data
        // The payload should contain the notification data
        final payload = response.payload!;
        
        // If payload contains JSON-like data, parse it
        // Otherwise, treat it as a simple notification ID
        Map<String, dynamic> data;
        if (payload.startsWith('{') && payload.endsWith('}')) {
          // This is a simplified approach - in production, use proper JSON parsing
          // For now, we'll extract key fields from the payload string
          data = {'payload': payload};
        } else {
          // Assume it's a notification ID
          data = {'notificationId': payload};
        }
        
        _onNotificationTap?.call(data);
      } catch (e) {
        developer.log(
          'Error parsing notification payload: $e',
          name: 'PushNotificationManager',
        );
        // Fallback: call with payload as notification ID
        _onNotificationTap?.call({'notificationId': response.payload});
      }
    }
  }

  /// Unregister push token (e.g., on logout)
  Future<void> unregisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.unregisterPushToken(token);
        developer.log('Push token unregistered', name: 'PushNotificationManager');
      }
    } catch (e) {
      developer.log(
        'Error unregistering push token: $e',
        name: 'PushNotificationManager',
      );
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    developer.log('Subscribed to topic: $topic', name: 'PushNotificationManager');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    developer.log('Unsubscribed from topic: $topic', name: 'PushNotificationManager');
  }
}
