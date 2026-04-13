part of 'support_remote_datasource.dart';

class _SupportRemoteSupport {
  final ApiClient apiClient;

  const _SupportRemoteSupport({required this.apiClient});

  void log(String message) {
    developer.log(message, name: 'SupportDataSource');
  }

  Map<String, dynamic> extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> extractList(dynamic value) => value is List ? value : const [];

  Map<String, dynamic> unwrapResponse(dynamic raw) {
    final map = extractMap(raw);
    final inner = map['data'];
    if (inner is Map<String, dynamic> && inner.containsKey('success')) {
      return inner;
    }
    if (inner is Map && inner.containsKey('success')) {
      return Map<String, dynamic>.from(inner);
    }
    return map;
  }

  Map<String, dynamic> requireSuccess(
    dynamic raw, {
    required String fallbackMessage,
  }) {
    final payload = unwrapResponse(raw);
    if (payload['success'] == true) return payload;

    final outer = extractMap(raw);
    throw ServerException(
      message:
          payload['messageAr']?.toString() ??
          payload['message']?.toString() ??
          outer['messageAr']?.toString() ??
          outer['message']?.toString() ??
          fallbackMessage,
    );
  }

  List<FileUploadData> mapFilesToUploadDataSync(List<File> files) {
    return files.map((file) {
      final bytes = file.readAsBytesSync();
      final extension = file.path.split('.').last;
      return FileUploadData(
        base64: base64Encode(bytes),
        filename: file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : file.path.split(Platform.pathSeparator).last,
        mimeType: mimeTypeFromExtension(extension),
      );
    }).toList();
  }

  String mimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
