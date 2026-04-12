part of 'ticket_models.dart';

TicketCategoryModel? _categoryFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return null;
  if (value is Map<String, dynamic>) {
    return TicketCategoryModel.fromJson(value);
  }
  if (value is Map) {
    return TicketCategoryModel.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['_id'] ?? json['id'];

String _extractCategoryId(dynamic category) {
  if (category is String) {
    return category;
  }
  if (category is Map) {
    return category['_id']?.toString() ?? category['id']?.toString() ?? '';
  }
  return '';
}
