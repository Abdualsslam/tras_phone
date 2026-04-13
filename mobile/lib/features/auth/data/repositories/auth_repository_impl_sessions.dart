part of 'auth_repository_impl.dart';

class _AuthRepositorySessionsDelegate {
  final _AuthRepositorySupport _support;

  const _AuthRepositorySessionsDelegate({
    required _AuthRepositorySupport support,
  }) : _support = support;

  Future<Either<Failure, void>> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final result = await _support.guardEither(
      () => _support.dataSource.updateFcmToken(
        fcmToken: fcmToken,
        deviceInfo: deviceInfo,
      ),
      source: 'AuthRepository.updateFcmToken',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      (_) => const Right(null),
    );
  }

  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    final result = await _support.guardEither(
      _support.dataSource.getSessions,
      source: 'AuthRepository.getSessions',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      (sessions) => Right(sessions.map((session) => session.toEntity()).toList()),
    );
  }

  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    final result = await _support.guardEither(
      () => _support.dataSource.deleteSession(sessionId),
      source: 'AuthRepository.deleteSession',
    );
    return result.fold(
      (failure) => Left(_support.serverFailure(failure)),
      (_) => const Right(null),
    );
  }
}
