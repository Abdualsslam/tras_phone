part of 'chat_models.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['_id'] ?? json['id'];

Object? _readSessionId(Map<dynamic, dynamic> json, String key) {
  final session = json['session'];
  if (session is String) return session;
  if (session is Map) return session['_id'] ?? session['id'] ?? '';
  return '';
}
