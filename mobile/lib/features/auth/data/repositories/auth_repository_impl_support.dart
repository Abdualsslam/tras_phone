part of 'auth_repository_impl.dart';

class _AuthRepositorySupport {
  final AuthRemoteDataSource dataSource;
  final LocalStorage localStorage;
  final SecureStorage secureStorage;
  final RepositoryGuard repositoryGuard;
  UserModel? _cachedUser;

  _AuthRepositorySupport({
    required this.dataSource,
    required this.localStorage,
    required this.secureStorage,
    required this.repositoryGuard,
  });

  void log(String message, {Object? error}) {
    developer.log(message, name: 'AuthRepo', error: error);
  }

  Future<void> saveUserToStorage(UserModel user) async {
    _cachedUser = user;
    await localStorage.setString(
      StorageKeys.userData,
      jsonEncode(user.toJson()),
    );
  }

  Future<void> persistLogin(AuthResponse authResponse) async {
    log('Login/Register: Saving accessToken...');
    await secureStorage.write(
      StorageKeys.accessToken,
      authResponse.accessToken,
    );
    await secureStorage.write(
      StorageKeys.refreshToken,
      authResponse.refreshToken,
    );
    await localStorage.setBool(StorageKeys.isLoggedIn, true);
    await saveUserToStorage(authResponse.user);
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await secureStorage.read(StorageKeys.accessToken);
      log(
        'isLoggedIn check - token exists: ${token != null && token.isNotEmpty}',
      );
      if (token != null) {
        final preview = token.substring(
          0,
          token.length > 20 ? 20 : token.length,
        );
        log('Token first 20 chars: $preview...');
      }
      return token != null && token.isNotEmpty;
    } catch (error) {
      log('isLoggedIn error: $error', error: error);
      return false;
    }
  }

  Future<bool> isFirstLaunch() async {
    try {
      return localStorage.getBool(StorageKeys.isFirstLaunch) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setFirstLaunchComplete() async {
    await localStorage.setBool(StorageKeys.isFirstLaunch, false);
  }

  Future<void> clearAllUserData() async {
    await secureStorage.delete(StorageKeys.accessToken);
    await secureStorage.delete(StorageKeys.refreshToken);
    await localStorage.setBool(StorageKeys.isLoggedIn, false);
    await localStorage.remove(StorageKeys.userData);

    final biometricEnabled =
        localStorage.getBool(StorageKeys.biometricEnabled) ?? false;
    if (!biometricEnabled) {
      await clearBiometricCredentials();
    }

    _cachedUser = null;
  }

  Future<({String phone, String password})?>
  getStoredBiometricCredentials() async {
    try {
      final phone = await secureStorage.read(StorageKeys.biometricPhone);
      final password = await secureStorage.read(StorageKeys.biometricPassword);
      if (phone != null &&
          phone.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        return (phone: phone, password: password);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBiometricCredentials({
    required String phone,
    required String password,
  }) async {
    await secureStorage.write(StorageKeys.biometricPhone, phone);
    await secureStorage.write(StorageKeys.biometricPassword, password);
  }

  Future<void> clearBiometricCredentials() async {
    await secureStorage.delete(StorageKeys.biometricPhone);
    await secureStorage.delete(StorageKeys.biometricPassword);
  }

  UserEntity? getCachedUser() {
    if (_cachedUser == null) {
      final userData = localStorage.getString(StorageKeys.userData);
      if (userData != null && userData.isNotEmpty) {
        try {
          _cachedUser = UserModel.fromJson(
            jsonDecode(userData) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
    }
    return _cachedUser?.toEntity();
  }

  Future<Either<Failure, T>> guardEither<T>(
    Future<T> Function() operation, {
    required String source,
  }) => repositoryGuard.guardEither(operation, source: source);

  Failure authFailure(Failure failure) =>
      failure is AuthFailure
          ? failure
          : AuthFailure(message: failure.message, code: failure.code);

  Failure serverFailure(Failure failure) =>
      failure is ServerFailure
          ? failure
          : ServerFailure(message: failure.message, code: failure.code);

  Failure validationFailure(Failure failure) =>
      failure is ValidationFailure
          ? failure
          : ValidationFailure(message: failure.message, code: failure.code);
}
