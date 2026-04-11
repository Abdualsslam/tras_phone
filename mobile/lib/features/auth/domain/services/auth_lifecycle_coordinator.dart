library;

import 'dart:developer' as developer;

import '../../../../core/config/app_config.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/services/socket_service.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../catalog/data/services/product_cache_service.dart';
import '../../../favorite/data/services/favorite_cache_service.dart';
import '../../../home/data/services/home_cache_service.dart';
import '../../../notifications/services/push_notification_manager.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import 'auth_device_info_service.dart';

class AuthLifecycleCoordinator {
  final BiometriclessCacheCleanup _cacheCleanup;
  final PushNotificationManager _pushNotificationManager;
  final CartCubit _cartCubit;
  final TokenManager _tokenManager;
  final AuthDeviceInfoService _deviceInfoService;

  AuthLifecycleCoordinator({
    required ProductCacheService productCacheService,
    required HomeCacheService homeCacheService,
    required FavoriteCacheService favoriteCacheService,
    required ProfileCubit profileCubit,
    required AddressesCubit addressesCubit,
    required PushNotificationManager pushNotificationManager,
    required CartCubit cartCubit,
    required TokenManager tokenManager,
    required AuthDeviceInfoService deviceInfoService,
  }) : _cacheCleanup = BiometriclessCacheCleanup(
         productCacheService: productCacheService,
         homeCacheService: homeCacheService,
         favoriteCacheService: favoriteCacheService,
         profileCubit: profileCubit,
         addressesCubit: addressesCubit,
       ),
       _pushNotificationManager = pushNotificationManager,
       _cartCubit = cartCubit,
       _tokenManager = tokenManager,
       _deviceInfoService = deviceInfoService;

  Future<void> clearCachesOnAuthChange() async {
    await _cacheCleanup.clear();
  }

  Future<void> initializePushNotifications({
    required void Function(Map<String, dynamic>) onNotificationTap,
  }) async {
    try {
      await _pushNotificationManager.initialize(
        onNotificationTap: onNotificationTap,
      );
      developer.log('Push notifications initialized', name: 'AuthLifecycleCoordinator');
    } catch (e) {
      developer.log('Failed to initialize push notifications: $e', name: 'AuthLifecycleCoordinator');
    }
  }

  Future<void> updateFcmTokenAfterAuth({
    required Future<void> Function({
      required String fcmToken,
      Map<String, dynamic>? deviceInfo,
    })
    updater,
  }) async {
    try {
      final fcmToken = await _pushNotificationManager.getToken();
      if (fcmToken == null) {
        return;
      }

      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      await updater(fcmToken: fcmToken, deviceInfo: deviceInfo);
    } catch (e) {
      developer.log('Failed to update FCM token after auth: $e', name: 'AuthLifecycleCoordinator');
    }
  }

  Future<void> syncCartAfterLogin() async {
    try {
      await _cartCubit.syncCart(silent: true);
      developer.log('Cart synced after login', name: 'AuthLifecycleCoordinator');
    } catch (e) {
      developer.log('Failed to sync cart after login: $e', name: 'AuthLifecycleCoordinator');
    }
  }

  Future<void> connectSocket() async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        SocketService().connect(token, AppConfig.baseUrl);
        developer.log('WebSocket connected', name: 'AuthLifecycleCoordinator');
      }
    } catch (e) {
      developer.log('Failed to connect WebSocket: $e', name: 'AuthLifecycleCoordinator');
    }
  }

  void disconnectSocket() {
    SocketService().disconnect();
  }
}

class BiometriclessCacheCleanup {
  final ProductCacheService _productCacheService;
  final HomeCacheService _homeCacheService;
  final FavoriteCacheService _favoriteCacheService;
  final ProfileCubit _profileCubit;
  final AddressesCubit _addressesCubit;

  BiometriclessCacheCleanup({
    required ProductCacheService productCacheService,
    required HomeCacheService homeCacheService,
    required FavoriteCacheService favoriteCacheService,
    required ProfileCubit profileCubit,
    required AddressesCubit addressesCubit,
  }) : _productCacheService = productCacheService,
       _homeCacheService = homeCacheService,
       _favoriteCacheService = favoriteCacheService,
       _profileCubit = profileCubit,
       _addressesCubit = addressesCubit;

  Future<void> clear() async {
    try {
      await _productCacheService.clearAll();
      await _homeCacheService.clearHomeData();
      await _favoriteCacheService.clearAll();
      _profileCubit.clearCache();
      _addressesCubit.clearCache();
      developer.log('Cleared caches on auth change', name: 'BiometriclessCacheCleanup');
    } catch (e) {
      developer.log('Failed to clear caches on auth change: $e', name: 'BiometriclessCacheCleanup');
    }
  }
}
