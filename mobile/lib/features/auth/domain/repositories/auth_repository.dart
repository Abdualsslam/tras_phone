/// Auth Repository Interface - Domain layer contract
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Check if first launch
  Future<bool> isFirstLaunch();

  /// Set first launch complete
  Future<void> setFirstLaunchComplete();

  /// Login with phone and password
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  });

  /// Register new customer
  Future<Either<Failure, UserEntity>> register({
    required String phone,
    required String password,
    String? email,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? cityId,
    String? businessType,
  });

  /// Send OTP to phone
  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String purpose,
  });

  /// Verify OTP
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  });

  /// Forgot password - request reset OTP
  Future<Either<Failure, void>> forgotPassword({required String phone});

  /// Verify OTP for password reset - returns resetToken
  Future<Either<Failure, String>> verifyResetOtp({
    required String phone,
    required String otp,
  });

  /// Reset password with resetToken
  Future<Either<Failure, bool>> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Get current user profile
  Future<Either<Failure, UserEntity>> getProfile();

  /// Change password
  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Get cached user
  UserEntity? getCachedUser();
}
