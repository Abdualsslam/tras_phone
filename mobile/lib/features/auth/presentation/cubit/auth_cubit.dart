/// Auth Cubit - State management for authentication
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/biometric_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_lifecycle_coordinator.dart';
import '../../domain/services/auth_notification_navigation_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final BiometricService _biometricService;
  final AuthLifecycleCoordinator _lifecycleCoordinator;
  final AuthNotificationNavigationService _notificationNavigationService;

  AuthCubit({
    required AuthRepository repository,
    required BiometricService biometricService,
    required AuthLifecycleCoordinator lifecycleCoordinator,
    required AuthNotificationNavigationService notificationNavigationService,
  })
    : _repository = repository,
      _biometricService = biometricService,
      _lifecycleCoordinator = lifecycleCoordinator,
      _notificationNavigationService = notificationNavigationService,
      super(const AuthInitial());

  /// Check auth status on app start
  Future<void> checkAuthStatus() async {
    developer.log('checkAuthStatus started', name: 'AuthCubit');
    emit(const AuthLoading());

    final isFirstLaunch = await _repository.isFirstLaunch();
    developer.log('isFirstLaunch: $isFirstLaunch', name: 'AuthCubit');
    if (isFirstLaunch) {
      emit(const AuthUnauthenticated(isFirstLaunch: true));
      return;
    }

    final isLoggedIn = await _repository.isLoggedIn();
    developer.log('isLoggedIn: $isLoggedIn', name: 'AuthCubit');
    if (!isLoggedIn) {
      emit(const AuthUnauthenticated(isFirstLaunch: false));
      return;
    }

    // Try to use cached user first to avoid unnecessary API calls
    final cachedUser = _repository.getCachedUser();
    developer.log('cachedUser: ${cachedUser?.phone}', name: 'AuthCubit');
    if (cachedUser != null) {
      developer.log('Using cached user, going to AuthAuthenticated', name: 'AuthCubit');
      emit(AuthAuthenticated(cachedUser));
      _lifecycleCoordinator.connectSocket();
      // Initialize push notifications for already logged in user
      _initializePushNotifications();
      // Optionally refresh profile in background
      _refreshProfileInBackground();
      return;
    }

    // If no cached user, fetch from API
    developer.log('No cached user, fetching from API', name: 'AuthCubit');
    final result = await _repository.getProfile();
    result.fold(
      (failure) {
        developer.log('getProfile failed: ${failure.message}', name: 'AuthCubit');
        emit(const AuthUnauthenticated(isFirstLaunch: false));
      },
      (user) {
        developer.log('getProfile success: ${user.phone}', name: 'AuthCubit');
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        // Initialize push notifications for already logged in user
        _initializePushNotifications();
      },
    );
  }

  /// Refresh profile in background without affecting UI
  Future<void> _refreshProfileInBackground() async {
    final result = await _repository.getProfile();
    result.fold(
      (failure) {
        // If profile fetch fails, don't logout - just log the error
        // The user can continue using cached data
      },
      (user) {
        // Update state with fresh data if still authenticated
        if (state is AuthAuthenticated) {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _repository.setFirstLaunchComplete();
    emit(const AuthUnauthenticated(isFirstLaunch: false));
  }

  /// Login
  Future<void> login({required String phone, required String password}) async {
    emit(const AuthLoading(message: 'جاري تسجيل الدخول...'));

    final result = await _repository.login(phone: phone, password: password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        // Clear product/home cache so fresh data with tier prices is fetched
        await _clearProductCachesOnAuthChange();
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        // Save credentials for biometric login if enabled
        if (await _biometricService.isEnabled()) {
          await _repository.saveBiometricCredentials(
            phone: phone,
            password: password,
          );
        }
        // Initialize push notifications after successful login
        _initializePushNotifications();
        // Update FCM token after successful login
        _updateFcmTokenAfterAuth();
        // Sync local cart with server (silent - no UI feedback)
        _syncCartAfterLogin();
      },
    );
  }

  /// Login with biometric - authenticate then use stored credentials
  Future<void> loginWithBiometric() async {
    final isAvailable = await _biometricService.isAvailable();
    if (!isAvailable) {
      emit(const AuthError('البصمة غير متاحة على هذا الجهاز'));
      return;
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'يرجى التحقق من هويتك لتسجيل الدخول',
    );
    if (!authenticated) {
      emit(const AuthError('تعذّر التحقق من البصمة، يرجى المحاولة مجدداً أو تسجيل الدخول يدوياً'));
      return;
    }

    final credentials = await _repository.getStoredBiometricCredentials();
    if (credentials == null) {
      emit(const AuthError('لا توجد بيانات محفوظة للتسجيل بالبصمة'));
      return;
    }

    await login(phone: credentials.phone, password: credentials.password);
  }

  /// Register
  Future<void> register({
    required String phone,
    required String password,
    String? email,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? cityId,
    String? businessType,
  }) async {
    emit(const AuthLoading(message: 'جاري إنشاء الحساب...'));

    final result = await _repository.register(
      phone: phone,
      password: password,
      email: email,
      responsiblePersonName: responsiblePersonName,
      shopName: shopName,
      shopNameAr: shopNameAr,
      cityId: cityId,
      businessType: businessType,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        // Clear product/home cache so fresh data with tier prices is fetched
        await _clearProductCachesOnAuthChange();
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        // Initialize push notifications after successful registration
        _initializePushNotifications();
        // Update FCM token after successful registration
        _updateFcmTokenAfterAuth();
        // Sync local cart with server (silent - no UI feedback)
        _syncCartAfterLogin();
      },
    );
  }

  /// Clear product, home, and profile caches when auth state changes (login/logout)
  /// Prices differ by customer tier - cached data becomes stale
  Future<void> _clearProductCachesOnAuthChange() async {
    await _lifecycleCoordinator.clearCachesOnAuthChange();
  }

  /// Initialize push notifications with navigation handler
  Future<void> _initializePushNotifications() async {
    await _lifecycleCoordinator.initializePushNotifications(
      onNotificationTap: _handleNotificationTap,
    );
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(Map<String, dynamic> data) {
    _notificationNavigationService.handleNotificationTap(data);
  }

  /// Update FCM token after authentication (login/register)
  Future<void> _updateFcmTokenAfterAuth() async {
    await _lifecycleCoordinator.updateFcmTokenAfterAuth(
      updater: ({
        required String fcmToken,
        Map<String, dynamic>? deviceInfo,
      }) {
        return updateFcmToken(
          fcmToken: fcmToken,
          deviceInfo: deviceInfo,
        );
      },
    );
  }

  /// Sync local cart with server after successful login/register
  /// This is done silently (no UI feedback) to merge local and server carts
  Future<void> _syncCartAfterLogin() async {
    await _lifecycleCoordinator.syncCartAfterLogin();
  }

  /// Send OTP
  Future<void> sendOtp({required String phone, required String purpose}) async {
    emit(const AuthLoading(message: 'جاري إرسال رمز التحقق...'));

    final result = await _repository.sendOtp(phone: phone, purpose: purpose);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent(phone: phone, purpose: purpose)),
    );
  }

  /// Verify OTP
  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    emit(const AuthLoading(message: 'جاري التحقق...'));

    final result = await _repository.verifyOtp(
      phone: phone,
      otp: otp,
      purpose: purpose,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpVerified(phone: phone)),
    );
  }

  /// Forgot password - request password reset
  Future<void> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    emit(const AuthLoading(message: 'جاري تقديم الطلب...'));

    final result = await _repository.forgotPassword(
      phone: phone,
      customerNotes: customerNotes,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (requestNumber) => emit(AuthPasswordResetRequestSubmitted(requestNumber: requestNumber)),
    );
  }

  /// Verify reset OTP and get resetToken
  Future<void> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading(message: 'جاري التحقق...'));

    final result = await _repository.verifyResetOtp(phone: phone, otp: otp);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (resetToken) =>
          emit(AuthOtpVerified(phone: phone, resetToken: resetToken)),
    );
  }

  /// Reset password with resetToken
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    emit(const AuthLoading(message: 'جاري تغيير كلمة المرور...'));

    final result = await _repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  /// Change password (for logged in users)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const AuthLoading(message: 'جاري تغيير كلمة المرور...'));

    final result = await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  /// Logout
  Future<void> logout() async {
    emit(const AuthLoading(message: 'جاري تسجيل الخروج...'));

    final result = await _repository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) async {
        _lifecycleCoordinator.disconnectSocket();
        // Clear product/home cache so fresh data with base prices is fetched
        await _clearProductCachesOnAuthChange();
        emit(const AuthUnauthenticated(isFirstLaunch: false));
      },
    );
  }

  /// Get current user
  UserEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return _repository.getCachedUser();
  }

  /// Update FCM token
  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final result = await _repository.updateFcmToken(
      fcmToken: fcmToken,
      deviceInfo: deviceInfo,
    );

    result.fold(
      (failure) {
        developer.log('Failed to update FCM token: ${failure.message}', name: 'AuthCubit');
        // Don't emit error state for FCM token updates - fail silently
      },
      (_) {
        developer.log('FCM token updated successfully', name: 'AuthCubit');
      },
    );
  }

  /// Get all active sessions
  Future<void> getSessions() async {
    emit(const AuthLoading(message: 'جاري تحميل الجلسات...'));

    final result = await _repository.getSessions();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (sessions) => emit(AuthSessionsLoaded(sessions)),
    );
  }

  /// Delete a specific session
  Future<void> deleteSession(String sessionId) async {
    emit(const AuthLoading(message: 'جاري حذف الجلسة...'));

    final result = await _repository.deleteSession(sessionId);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        emit(AuthSessionDeleted(sessionId));
        // Reload sessions after deletion
        getSessions();
      },
    );
  }
}
