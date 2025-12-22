/// Auth Cubit - State management for authentication
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInitial());

  /// Check auth status on app start
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final isFirstLaunch = await _repository.isFirstLaunch();
    if (isFirstLaunch) {
      emit(const AuthUnauthenticated(isFirstLaunch: true));
      return;
    }

    final isLoggedIn = await _repository.isLoggedIn();
    if (!isLoggedIn) {
      emit(const AuthUnauthenticated(isFirstLaunch: false));
      return;
    }

    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated(isFirstLaunch: false)),
      (customer) => emit(AuthAuthenticated(customer)),
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
      (customer) => emit(AuthAuthenticated(customer)),
    );
  }

  /// Register
  Future<void> register({
    required String phone,
    required String password,
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
  }) async {
    emit(const AuthLoading(message: 'جاري إنشاء الحساب...'));

    final result = await _repository.register(
      phone: phone,
      password: password,
      responsiblePersonName: responsiblePersonName,
      shopName: shopName,
      cityId: cityId,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (customer) => emit(AuthAuthenticated(customer)),
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

  /// Forgot password
  Future<void> forgotPassword({required String phone}) async {
    emit(const AuthLoading(message: 'جاري إرسال رمز التحقق...'));

    final result = await _repository.forgotPassword(phone: phone);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent(phone: phone, purpose: 'password_reset')),
    );
  }

  /// Reset password
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    emit(const AuthLoading(message: 'جاري تغيير كلمة المرور...'));

    final result = await _repository.resetPassword(
      phone: phone,
      otp: otp,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  /// Update profile
  Future<void> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
  }) async {
    emit(const AuthLoading(message: 'جاري تحديث البيانات...'));

    final result = await _repository.updateProfile(
      responsiblePersonName: responsiblePersonName,
      shopName: shopName,
      email: email,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (customer) => emit(AuthProfileUpdated(customer)),
    );
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const AuthLoading(message: 'جاري تغيير كلمة المرور...'));

    final result = await _repository.changePassword(
      currentPassword: currentPassword,
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
  CustomerEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).customer;
    }
    return _repository.getCachedUser();
  }
}
