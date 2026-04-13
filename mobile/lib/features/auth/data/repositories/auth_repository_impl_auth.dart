part of 'auth_repository_impl.dart';

class _AuthRepositoryAuthDelegate {
  final _AuthRepositorySupport _support;

  const _AuthRepositoryAuthDelegate({required _AuthRepositorySupport support})
    : _support = support;

  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.login(phone: phone, password: password),
      source: 'AuthRepository.login',
    );
    Failure? failure;
    AuthResponse? authResponse;
    result.fold((left) => failure = left, (right) => authResponse = right);
    if (failure != null) {
      return Left(_support.authFailure(failure!));
    }

    await _support.persistLogin(authResponse!);
    final savedToken = await _support.secureStorage.read(
      StorageKeys.accessToken,
    );
    _support.log(
      'Login: Token saved verification: ${savedToken != null && savedToken.isNotEmpty}',
    );
    return Right(authResponse!.user.toEntity());
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
    final result = await _support.guardEither(
      () => _support.dataSource.register(
        phone: phone,
        password: password,
        email: email,
        responsiblePersonName: responsiblePersonName,
        shopName: shopName,
        shopNameAr: shopNameAr,
        cityId: cityId,
        businessType: businessType,
      ),
      source: 'AuthRepository.register',
    );
    Failure? failure;
    AuthResponse? authResponse;
    result.fold((left) => failure = left, (right) => authResponse = right);
    if (failure != null) {
      return Left(_support.authFailure(failure!));
    }

    await _support.persistLogin(authResponse!);
    return Right(authResponse!.user.toEntity());
  }

  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.sendOtp(phone: phone, purpose: purpose),
      source: 'AuthRepository.sendOtp',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      (_) => const Right(null),
    );
  }

  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.verifyOtp(
        phone: phone,
        otp: otp,
        purpose: purpose,
      ),
      source: 'AuthRepository.verifyOtp',
    );
    return result.fold(
      (failure) => Left(_support.validationFailure(failure)),
      Right.new,
    );
  }

  Future<Either<Failure, String>> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.forgotPassword(
        phone: phone,
        customerNotes: customerNotes,
      ),
      source: 'AuthRepository.forgotPassword',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      Right.new,
    );
  }

  Future<Either<Failure, String>> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.verifyResetOtp(
        phone: phone,
        otp: otp,
      ),
      source: 'AuthRepository.verifyResetOtp',
    );
    return result.fold(
      (failure) => Left(_support.validationFailure(failure)),
      Right.new,
    );
  }

  Future<Either<Failure, bool>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      ),
      source: 'AuthRepository.resetPassword',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      Right.new,
    );
  }

  Future<Either<Failure, UserEntity>> getProfile() async {
    final result = await _support.guardEither(
      _support.dataSource.getProfile,
      source: 'AuthRepository.getProfile',
    );
    Failure? failure;
    UserModel? user;
    result.fold((left) => failure = left, (right) => user = right);
    if (failure != null) {
      return Left(_support.authFailure(failure!));
    }

    await _support.saveUserToStorage(user!);
    return Right(user!.toEntity());
  }

  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
      source: 'AuthRepository.changePassword',
    );
    return result.fold(
      (failure) => Left(_support.validationFailure(failure)),
      Right.new,
    );
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
