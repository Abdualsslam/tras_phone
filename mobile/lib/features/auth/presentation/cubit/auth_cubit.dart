/// Auth Cubit - State management for authentication
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({required AuthRepository repository})
    : _repository = repository,
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
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Register
  Future<void> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    emit(const AuthLoading(message: 'جاري إنشاء الحساب...'));

    final result = await _repository.register(
      phone: phone,
      password: password,
      email: email,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
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

  /// Forgot password - send OTP
  Future<void> forgotPassword({required String phone}) async {
    emit(const AuthLoading(message: 'جاري إرسال رمز التحقق...'));

    final result = await _repository.forgotPassword(phone: phone);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent(phone: phone, purpose: 'password_reset')),
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
      (_) => emit(const AuthUnauthenticated(isFirstLaunch: false)),
    );
  }

  /// Get current user
  UserEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return _repository.getCachedUser();
  }
}
