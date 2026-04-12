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
    try {
      await _support.dataSource.updateFcmToken(
        fcmToken: fcmToken,
        deviceInfo: deviceInfo,
      );
      return const Right(null);
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }

  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    try {
      final sessions = await _support.dataSource.getSessions();
      return Right(sessions.map((session) => session.toEntity()).toList());
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }

  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await _support.dataSource.deleteSession(sessionId);
      return const Right(null);
    } catch (error) {
      return Left(_support.serverFailure(error));
    }
  }
}
