part of 'auth_remote_datasource.dart';

class _AuthRemoteSupport {
  final ApiClient apiClient;
  final AppSecurityService appSecurityService;

  const _AuthRemoteSupport({
    required this.apiClient,
    required this.appSecurityService,
  });

  void log(String message) {
    developer.log(message, name: 'AuthDataSource');
  }

  String formatPhone(String phone) => Formatters.phoneToInternational(phone);

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

  List<dynamic> extractList(dynamic value) => value is List ? value : const [];

  Future<Map<String, dynamic>> buildIntegrityPayload({
    required String requestType,
  }) async {
    final payload = await appSecurityService.buildAuthIntegrityPayload(
      requestType: requestType,
    );
    return payload.toJson();
  }

  void ensureSuccess(
    Map<String, dynamic> responseBody, {
    required String fallbackMessage,
  }) {
    if (responseBody['success'] == true) return;
    throw ServerException(
      message:
          responseBody['messageAr']?.toString() ??
          responseBody['message']?.toString() ??
          fallbackMessage,
    );
  }

  Never rethrowRegistrationError(Object error) {
    if (error is ServerException) {
      log('Registration failed: ${error.message}');
      throw ServerException(
        message: error.message,
        code: error.code,
        originalError: error.originalError,
        statusCode: error.statusCode,
      );
    }
    log('Registration error: $error');
    throw error;
  }
}
