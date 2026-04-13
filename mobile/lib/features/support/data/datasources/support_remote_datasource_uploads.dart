part of 'support_remote_datasource.dart';

class _SupportRemoteUploadsDelegate {
  final _SupportRemoteSupport _support;

  const _SupportRemoteUploadsDelegate({required _SupportRemoteSupport support})
    : _support = support;

  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    _support.log('Uploading attachments');

    final files = <File>[];
    for (final path in filePaths) {
      final file = File(path);
      if (!await file.exists()) {
        throw NotFoundException(message: 'File does not exist: $path');
      }
      files.add(file);
    }

    final uploadData = _support.mapFilesToUploadDataSync(files);
    final response = await _support.apiClient.post(
      ApiEndpoints.ticketUpload,
      data: {'files': uploadData.map((file) => file.toJson()).toList()},
    );

    final payload = _support.extractMap(response.data['data'] ?? response.data);
    final urls = payload['urls'] as List<dynamic>?;
    if (urls != null) {
      return urls.map((url) => url.toString()).toList();
    }

    throw ServerException(
      message:
          _support.extractMap(response.data)['messageAr'] ??
          _support.extractMap(response.data)['message'] ??
          'Failed to upload files',
    );
  }
}
