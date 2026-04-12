part of 'wallet_remote_datasource.dart';

class _WalletRemoteSupport {
  final ApiClient apiClient;

  const _WalletRemoteSupport({required this.apiClient});

  Map<String, dynamic> asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const <String, dynamic>{};
  }

  bool isSuccessResponse(Map<String, dynamic> body) {
    final success = body['success'];
    if (success is bool) return success;

    final status = body['status']?.toString().toLowerCase();
    if (status != null && status.isNotEmpty) {
      return status == 'success' || status == 'ok';
    }

    final statusCode = body['statusCode'];
    if (statusCode is num) {
      return statusCode >= 200 && statusCode < 300;
    }

    return false;
  }

  String extractMessage(Map<String, dynamic> body, String fallback) {
    final messageAr = body['messageAr'];
    if (messageAr is String && messageAr.trim().isNotEmpty) return messageAr;

    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    return fallback;
  }

  Exception wrapError(
    Object error, {
    required String fallback,
    required String fallbackWithDetails,
  }) {
    if (error is Exception) return error;
    return Exception('$fallbackWithDetails: ${error.toString()}');
  }
}
