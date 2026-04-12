part of 'customer_model.dart';

Object? _customerReadId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value is Map) {
    return value['\$oid'] ?? value.toString();
  }
  return value?.toString();
}

Object? _customerReadUserId(Map<dynamic, dynamic> json, String key) {
  final value = json['userId'];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value.toString();
}

Object? _customerReadNestedId(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value.toString();
}

Object? _customerReadOptionalNestedId(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value.toString();
}
