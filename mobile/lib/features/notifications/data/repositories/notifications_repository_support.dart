part of 'notifications_repository.dart';

class _NotificationsRepositorySupport {
  final RepositoryGuard repositoryGuard;

  const _NotificationsRepositorySupport({required this.repositoryGuard});

  Future<Either<Failure, T>> guard<T>(
    Future<T> Function() operation, {
    required String source,
  }) => repositoryGuard.guardEither(operation, source: source);
}
