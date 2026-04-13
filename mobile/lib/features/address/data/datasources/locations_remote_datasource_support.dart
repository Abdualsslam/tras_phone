part of 'locations_remote_datasource.dart';

class _LocationsRemoteSupport {
  final ApiClient apiClient;

  const _LocationsRemoteSupport({required this.apiClient});

  void log(String message) {
    developer.log(message, name: 'LocationsDataSource');
  }

  Map<String, dynamic> extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> extractList(dynamic value) => value is List ? value : const [];

  dynamic extractPayload(dynamic raw) {
    final map = extractMap(raw);
    return map['data'] ?? map;
  }

  String errorMessage(dynamic raw, String fallback) {
    final map = extractMap(raw);
    return map['messageAr']?.toString() ??
        map['message']?.toString() ??
        fallback;
  }

  void ensureSuccess(
    dynamic raw, {
    required String fallbackMessage,
    bool allowStatusError = false,
  }) {
    final map = extractMap(raw);
    final failed =
        map['success'] == false ||
        (allowStatusError && map['status'] == 'error');
    if (!failed) return;
    throw ServerException(message: errorMessage(raw, fallbackMessage));
  }
}
