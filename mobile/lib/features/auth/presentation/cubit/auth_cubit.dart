/// Auth Cubit - State management for authentication
library;

import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
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
  }) : _repository = repository,
       _biometricService = biometricService,
       _lifecycleCoordinator = lifecycleCoordinator,
       _notificationNavigationService = notificationNavigationService,
       super(const AuthInitial());

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

    final cachedUser = _repository.getCachedUser();
    developer.log('cachedUser: ${cachedUser?.phone}', name: 'AuthCubit');
    if (cachedUser != null) {
      developer.log(
        'Using cached user, going to AuthAuthenticated',
        name: 'AuthCubit',
      );
      emit(AuthAuthenticated(cachedUser));
      _lifecycleCoordinator.connectSocket();
      _initializePushNotifications();
      _refreshProfileInBackground();
      return;
    }

    developer.log('No cached user, fetching from API', name: 'AuthCubit');
    final result = await _repository.getProfile();
    result.fold(
      (failure) {
        developer.log(
          'getProfile failed: ${failure.message}',
          name: 'AuthCubit',
        );
        emit(const AuthUnauthenticated(isFirstLaunch: false));
      },
      (user) {
        developer.log('getProfile success: ${user.phone}', name: 'AuthCubit');
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        _initializePushNotifications();
      },
    );
  }

  Future<void> _refreshProfileInBackground() async {
    final result = await _repository.getProfile();
    result.fold(
      (_) {},
      (user) {
        if (state is AuthAuthenticated) {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> completeOnboarding() async {
    await _repository.setFirstLaunchComplete();
    emit(const AuthUnauthenticated(isFirstLaunch: false));
  }

  Future<void> login({required String phone, required String password}) async {
    emit(const AuthLoading(message: 'جاري تسجيل الدخول...'));

    final result = await _repository.login(phone: phone, password: password);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) async {
        await _clearProductCachesOnAuthChange();
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        if (await _biometricService.isEnabled()) {
          await _repository.saveBiometricCredentials(
            phone: phone,
            password: password,
          );
        }
        _initializePushNotifications();
        _updateFcmTokenAfterAuth();
        _syncCartAfterLogin();
      },
    );
  }

  Future<void> loginWithBiometric() async {
    final isAvailable = await _biometricService.isAvailable();
    if (!isAvailable) {
      emit(
        const AuthError(
          AuthFailure(message: 'البصمة غير متاحة على هذا الجهاز'),
        ),
      );
      return;
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'يرجى التحقق من هويتك لتسجيل الدخول',
    );
    if (!authenticated) {
      emit(
        const AuthError(
          AuthFailure(
            message:
                'تعذّر التحقق من البصمة، يرجى المحاولة مجدداً أو تسجيل الدخول يدوياً',
          ),
        ),
      );
      return;
    }

    final credentials = await _repository.getStoredBiometricCredentials();
    if (credentials == null) {
      emit(
        const AuthError(
          AuthFailure(message: 'لا توجد بيانات محفوظة للتسجيل بالبصمة'),
        ),
      );
      return;
    }

    await login(phone: credentials.phone, password: credentials.password);
  }

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
      (failure) => emit(AuthError(failure)),
      (user) async {
        await _clearProductCachesOnAuthChange();
        emit(AuthAuthenticated(user));
        _lifecycleCoordinator.connectSocket();
        _initializePushNotifications();
        _updateFcmTokenAfterAuth();
        _syncCartAfterLogin();
      },
    );
  }

  Future<void> _clearProductCachesOnAuthChange() async {
    await _lifecycleCoordinator.clearCachesOnAuthChange();
  }

  Future<void> _initializePushNotifications() async {
    await _lifecycleCoordinator.initializePushNotifications(
      onNotificationTap: _handleNotificationTap,
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    _notificationNavigationService.handleNotificationTap(data);
  }

  Future<void> _updateFcmTokenAfterAuth() async {
    await _lifecycleCoordinator.updateFcmTokenAfterAuth(
      updater: ({
        required String fcmToken,
        Map<String, dynamic>? deviceInfo,
      }) {
        return updateFcmToken(fcmToken: fcmToken, deviceInfo: deviceInfo);
      },
    );
  }

  Future<void> _syncCartAfterLogin() async {
    await _lifecycleCoordinator.syncCartAfterLogin();
  }

  Future<void> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    emit(const AuthLoading(message: 'جاري إرسال رمز التحقق...'));

    final result = await _repository.sendOtp(phone: phone, purpose: purpose);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(AuthOtpSent(phone: phone, purpose: purpose)),
    );
  }

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
      (failure) => emit(AuthError(failure)),
      (_) => emit(AuthOtpVerified(phone: phone)),
    );
  }

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
      (failure) => emit(AuthError(failure)),
      (requestNumber) => emit(
        AuthPasswordResetRequestSubmitted(requestNumber: requestNumber),
      ),
    );
  }

  Future<void> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading(message: 'جاري التحقق...'));

    final result = await _repository.verifyResetOtp(phone: phone, otp: otp);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (resetToken) =>
          emit(AuthOtpVerified(phone: phone, resetToken: resetToken)),
    );
  }

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
      (failure) => emit(AuthError(failure)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

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
      (failure) => emit(AuthError(failure)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading(message: 'جاري تسجيل الخروج...'));

    final result = await _repository.logout();

    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) async {
        _lifecycleCoordinator.disconnectSocket();
        await _clearProductCachesOnAuthChange();
        emit(const AuthUnauthenticated(isFirstLaunch: false));
      },
    );
  }

  UserEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return _repository.getCachedUser();
  }

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
        developer.log(
          'Failed to update FCM token: ${failure.message}',
          name: 'AuthCubit',
        );
      },
      (_) {
        developer.log('FCM token updated successfully', name: 'AuthCubit');
      },
    );
  }

  Future<void> getSessions() async {
    emit(const AuthLoading(message: 'جاري تحميل الجلسات...'));

    final result = await _repository.getSessions();

    result.fold(
      (failure) => emit(AuthError(failure)),
      (sessions) => emit(AuthSessionsLoaded(sessions)),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    emit(const AuthLoading(message: 'جاري حذف الجلسة...'));

    final result = await _repository.deleteSession(sessionId);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) {
        emit(AuthSessionDeleted(sessionId));
        getSessions();
      },
    );
  }
}
