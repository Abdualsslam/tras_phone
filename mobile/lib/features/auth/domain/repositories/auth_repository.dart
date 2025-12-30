/// Auth Repository Interface - Domain layer contract
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';

abstract class AuthRepository {
  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Check if first launch
  Future<bool> isFirstLaunch();

  /// Set first launch complete
  Future<void> setFirstLaunchComplete();

  /// Login with phone and password
  Future<Either<Failure, CustomerEntity>> login({
    required String phone,
    required String password,
  });

  /// Register new customer
  Future<Either<Failure, CustomerEntity>> register({
    required String phone,
    required String password,
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
  });

  /// Send OTP to phone
  Future<Either<Failure, bool>> sendOtp({
    required String phone,
    required String purpose,
  });

  /// Verify OTP
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  });

  /// Forgot password - request reset
  Future<Either<Failure, bool>> forgotPassword({required String phone});

  /// Reset password with OTP
  Future<Either<Failure, bool>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  });

  /// Get current user
  Future<Either<Failure, CustomerEntity>> getCurrentUser();

  /// Update profile
  Future<Either<Failure, CustomerEntity>> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
  });

  /// Change password
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Logout
  Future<Either<Failure, bool>> logout();

  /// Get cached user
  CustomerEntity? getCachedUser();
}
