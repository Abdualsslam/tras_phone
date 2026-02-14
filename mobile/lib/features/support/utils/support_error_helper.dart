/// Support error helper - extract user-facing message (messageAr) from API errors
library;

import 'package:dio/dio.dart';

/// Returns a user-facing error message, preferring [messageAr] from API response.
String getSupportErrorMessage(Object e) {
  if (e is DioException && e.response?.data != null) {
    final data = e.response!.data;
    if (data is Map) {
      final messageAr = data['messageAr']?.toString();
      final message = data['message']?.toString();
      if (messageAr != null && messageAr.isNotEmpty) return messageAr;
      if (message != null && message.isNotEmpty) return message;
    }
  }
  return e.toString();
}
