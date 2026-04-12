part of 'notifications_remote_datasource.dart';

class _NotificationsRemoteSupport {
  final ApiClient apiClient;

  const _NotificationsRemoteSupport({required this.apiClient});

  void log(String message) {
    developer.log(message, name: 'NotificationsDataSource');
  }

  dynamic extractPayload(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      return responseBody['data'] ?? responseBody;
    }
    return responseBody;
  }

  Map<String, dynamic> extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
