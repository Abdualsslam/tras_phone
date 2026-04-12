part of 'product_model.dart';

class _ProductModelParser {
  static ProductModel parse(Map<String, dynamic> json) {
    final nowIso = DateTime.now().toIso8601String();
    final normalized = Map<String, dynamic>.from(json);

    normalized['id'] = _productReadId(json, 'id')?.toString() ?? '';
    normalized['sku'] = (json['sku'] ?? '').toString();
    normalized['name'] = (json['name'] ?? '').toString();
    normalized['nameAr'] = (json['nameAr'] ?? json['name'] ?? '').toString();
    normalized['slug'] =
        (json['slug'] ?? normalized['name'] ?? normalized['id'] ?? '')
            .toString();
    normalized['createdAt'] = _normalizeDate(
      json['createdAt'] ?? json['updatedAt'],
      fallback: nowIso,
    );
    normalized['updatedAt'] = _normalizeDate(
      json['updatedAt'] ?? json['createdAt'],
      fallback: nowIso,
    );
    normalized['brandId'] =
        _productReadRelationId(json, 'brandId')?.toString() ?? '';
    normalized['categoryId'] =
        _productReadRelationId(json, 'categoryId')?.toString() ?? '';
    normalized['qualityTypeId'] =
        _productReadRelationId(json, 'qualityTypeId')?.toString() ?? '';
    normalized['compatibleDevices'] = _readIdList(json['compatibleDevices']);
    normalized['additionalCategories'] = _readIdList(
      json['additionalCategories'],
    );
    normalized['images'] = _readStringList(json['images']);
    normalized['tags'] = _readStringList(json['tags']);

    final relations = _readRelationNames(json);
    final compatibleDeviceNames = _readCompatibleDeviceNames(
      json,
      arabic: false,
    );
    final compatibleDeviceNamesAr = _readCompatibleDeviceNames(
      json,
      arabic: true,
    );

    final model = _$ProductModelFromJson(normalized);
    return ProductModel(
      id: model.id,
      sku: model.sku,
      name: model.name,
      nameAr: model.nameAr,
      slug: model.slug,
      description: model.description,
      descriptionAr: model.descriptionAr,
      shortDescription: model.shortDescription,
      shortDescriptionAr: model.shortDescriptionAr,
      brandId: model.brandId,
      categoryId: model.categoryId,
      additionalCategories: model.additionalCategories,
      qualityTypeId: model.qualityTypeId,
      compatibleDevices: model.compatibleDevices,
      compatibleDeviceNames: compatibleDeviceNames,
      compatibleDeviceNamesAr: compatibleDeviceNamesAr,
      relatedProducts: model.relatedProducts,
      relatedEducationalContent: model.relatedEducationalContent,
      mainImage: model.mainImage,
      images: model.images,
      video: model.video,
      basePrice: model.basePrice,
      compareAtPrice: model.compareAtPrice,
      price: model.price,
      stockQuantity: model.stockQuantity,
      lowStockThreshold: model.lowStockThreshold,
      trackInventory: model.trackInventory,
      allowBackorder: model.allowBackorder,
      minOrderQuantity: model.minOrderQuantity,
      maxOrderQuantity: model.maxOrderQuantity,
      quantityStep: model.quantityStep,
      status: model.status,
      isActive: model.isActive,
      isFeatured: model.isFeatured,
      isNewArrival: model.isNewArrival,
      isBestSeller: model.isBestSeller,
      specifications: model.specifications,
      weight: model.weight,
      dimensions: model.dimensions,
      color: model.color,
      warrantyDays: model.warrantyDays,
      warrantyDescription: model.warrantyDescription,
      viewsCount: model.viewsCount,
      ordersCount: model.ordersCount,
      salesCount: model.salesCount,
      reviewsCount: model.reviewsCount,
      averageRating: model.averageRating,
      favoriteCount: model.favoriteCount,
      tags: model.tags,
      publishedAt: model.publishedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      brandName: relations.brandName,
      brandNameAr: relations.brandNameAr,
      categoryName: relations.categoryName,
      categoryNameAr: relations.categoryNameAr,
      qualityTypeName: relations.qualityTypeName,
      qualityTypeNameAr: relations.qualityTypeNameAr,
    );
  }

  static String _normalizeDate(dynamic value, {required String fallback}) {
    if (value is String && value.isNotEmpty) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final nested = map['\$date'] ?? map['date'];
      if (nested is String && nested.isNotEmpty) return nested;
    }
    return fallback;
  }

  static ({
    String? brandName,
    String? brandNameAr,
    String? categoryName,
    String? categoryNameAr,
    String? qualityTypeName,
    String? qualityTypeNameAr,
  })
  _readRelationNames(Map<String, dynamic> json) {
    String? brandName;
    String? brandNameAr;
    String? categoryName;
    String? categoryNameAr;
    String? qualityTypeName;
    String? qualityTypeNameAr;

    final brandData = json['brandId'];
    if (brandData is Map<String, dynamic>) {
      brandName = brandData['name'] as String?;
      brandNameAr = brandData['nameAr'] as String?;
    } else {
      brandName = json['brandName']?.toString();
      brandNameAr = json['brandNameAr']?.toString();
    }

    final categoryData = json['categoryId'];
    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name'] as String?;
      categoryNameAr = categoryData['nameAr'] as String?;
    } else {
      categoryName = json['categoryName']?.toString();
      categoryNameAr = json['categoryNameAr']?.toString();
    }

    final qualityData = json['qualityTypeId'];
    if (qualityData is Map<String, dynamic>) {
      qualityTypeName = qualityData['name'] as String?;
      qualityTypeNameAr = qualityData['nameAr'] as String?;
    } else {
      qualityTypeName = json['qualityTypeName']?.toString();
      qualityTypeNameAr = json['qualityTypeNameAr']?.toString();
    }

    return (
      brandName: brandName,
      brandNameAr: brandNameAr,
      categoryName: categoryName,
      categoryNameAr: categoryNameAr,
      qualityTypeName: qualityTypeName,
      qualityTypeNameAr: qualityTypeNameAr,
    );
  }
}

Object? _productReadId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value is Map) {
    return value['\$oid'] ?? value.toString();
  }
  return value?.toString();
}

Object? _productReadRelationId(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['\$oid']?.toString();
  }
  return value?.toString() ?? '';
}

Object? _productReadRelatedProducts(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is List) {
    return value
        .map((item) {
          if (item is String) return item;
          if (item is Map) {
            return item['_id']?.toString() ??
                item['\$oid']?.toString() ??
                item['id']?.toString();
          }
          return item.toString();
        })
        .toList()
        .cast<String>();
  }
  return null;
}

Object? _productReadRelatedEducationalContent(
  Map<dynamic, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value == null) return null;
  if (value is List) {
    return value
        .map((item) {
          if (item is String) return item;
          if (item is Map) {
            return item['_id']?.toString() ??
                item['\$oid']?.toString() ??
                item['id']?.toString();
          }
          return item.toString();
        })
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
  }
  return null;
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];

  final result = <String>[];
  for (final item in value) {
    if (item is String) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) result.add(trimmed);
      continue;
    }

    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final nested =
          map['url'] ??
          map['secureUrl'] ??
          map['secure_url'] ??
          map['path'] ??
          map['src'] ??
          map['_id'] ??
          map['id'] ??
          map['\$oid'];
      final nestedValue = nested?.toString().trim();
      if (nestedValue != null && nestedValue.isNotEmpty) {
        result.add(nestedValue);
      }
      continue;
    }

    final fallback = item.toString().trim();
    if (fallback.isNotEmpty) result.add(fallback);
  }

  return result;
}

List<String> _readIdList(dynamic value) {
  if (value is! List) return const [];

  final result = <String>[];
  for (final item in value) {
    if (item is String) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) result.add(trimmed);
      continue;
    }

    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final id = map['_id'] ?? map['id'] ?? map['\$oid'];
      final stringValue = id?.toString().trim();
      if (stringValue != null && stringValue.isNotEmpty) {
        result.add(stringValue);
      }
    }
  }

  return result;
}

List<String> _readCompatibleDeviceNames(
  Map<String, dynamic> json, {
  required bool arabic,
}) {
  final directKey = arabic
      ? 'compatibleDeviceNamesAr'
      : 'compatibleDeviceNames';
  final direct = _readStringList(json[directKey]);
  if (direct.isNotEmpty) return direct;

  final value = json['compatibleDevices'];
  if (value is! List) return const [];

  final names = <String>[];
  for (final item in value) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final rawName = arabic
        ? (map['nameAr'] ?? map['name'])
        : (map['name'] ?? map['nameAr']);
    final name = rawName?.toString().trim();
    if (name != null && name.isNotEmpty) {
      names.add(name);
    }
  }
  return names;
}
