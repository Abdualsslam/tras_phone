part of 'order_model.dart';

Object? _orderItemReadId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['\$oid']?.toString() ?? value.toString();
  }
  return value.toString();
}

Object? _orderItemReadProductId(Map<dynamic, dynamic> json, String key) {
  final value = json['productId'];
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value?.toString();
}

Object? _orderReadId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value is Map) {
    return value['\$oid'] ?? value.toString();
  }
  return value?.toString();
}

Object? _orderReadCustomerId(Map<dynamic, dynamic> json, String key) {
  final value = json['customerId'];
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value?.toString();
}

Object? _orderReadShippingAddressId(Map<dynamic, dynamic> json, String key) {
  final value = json['shippingAddressId'];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value.toString();
}

Object? _orderReadPriceLevelId(Map<dynamic, dynamic> json, String key) {
  final value = json['priceLevelId'];
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value.toString();
}
