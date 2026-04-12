part of 'education_remote_datasource.dart';

class _EducationInteractionsRemote {
  final _EducationRemoteSupport _support;

  const _EducationInteractionsRemote(this._support);

  Future<void> likeContent(String id) async {
    _support.log('Liking educational content: $id');
    await _support.apiClient.post('${ApiEndpoints.educationContent}/$id/like');
  }

  Future<void> shareContent(String id) async {
    _support.log('Sharing educational content: $id');
    await _support.apiClient.post('${ApiEndpoints.educationContent}/$id/share');
  }
}
