part of 'auth_repository_impl.dart';

class _AuthRepositoryAuthDelegate {
  final _AuthRepositorySupport _support;

  const _AuthRepositoryAuthDelegate({required _AuthRepositorySupport support})
    : _support = support;

  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final authResponse = await _support.dataSource.login(
        phone: phone,
        password: password,
      );
      await _support.persistLogin(authResponse);

      final savedToken = await _support.secureStorage.read(
        StorageKeys.accessToken,
      );
      _support.log(
        'Login: Token saved verification: ${savedToken != null && savedToken.isNotEmpty}',
      );
      return Right(authResponse.user.toEntity());
    } catch (error) {
      _support.log('Login error: $error', error: error);
      return Left(_support.authFailure(error));
    }
  }

  Future<Either<Failure, UserEntity>> register({
    required String phone,
    required String password,
    String? email,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? cityId,
    String? businessType,
  }) async {
    try {
      final authResponse = await _support.dataSource.register(
        phone: phone,
        password: password,
        email: email,
        responsiblePersonName: responsiblePersonName,
        shopName: shopName,
        shopNameAr: shopNameAr,
        cityId: cityId,
        businessType: businessType,
      );
      await _support.persistLogin(authResponse);
      return Right(authResponse.user.toEntity());
    } catch (error) {
      return Left(_support.authFailure(error));
    }
  }

  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    try {
      await _support.dataSource.sendOtp(phone: phone, purpose: purpose);
      return const Right(null);
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }

  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    try {
      final result = await _support.dataSource.verifyOtp(
        phone: phone,
        otp: otp,
        purpose: purpose,
      );
      return Right(result);
    } catch (error) {
      return Left(_support.validationFailure(error));
    }
  }

  Future<Either<Failure, String>> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    try {
      final requestNumber = await _support.dataSource.forgotPassword(
        phone: phone,
        customerNotes: customerNotes,
      );
      return Right(requestNumber);
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }

  Future<Either<Failure, String>> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final resetToken = await _support.dataSource.verifyResetOtp(
        phone: phone,
        otp: otp,
      );
      return Right(resetToken);
    } catch (error) {
      return Left(_support.validationFailure(error));
    }
  }

  Future<Either<Failure, bool>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final result = await _support.dataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }

  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = await _support.dataSource.getProfile();
      await _support.saveUserToStorage(user);
      return Right(user.toEntity());
    } catch (error) {
      return Left(_support.authFailure(error));
    }
  }

  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final result = await _support.dataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (error) {
      return Left(_support.validationFailure(error));
    }
  }

  Future<Either<Failure, void>> logout() async {
    try {
      await _support.dataSource.logout();
      await _support.clearAllUserData();
      return const Right(null);
    } catch (_) {
      await _support.clearAllUserData();
      return const Right(null);
    }
  }
}
