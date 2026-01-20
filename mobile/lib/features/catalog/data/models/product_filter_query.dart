/// Product Filter Query - Query parameters for product filtering
library;

import '../../domain/enums/product_enums.dart';

/// Filter query for products API
class ProductFilterQuery {
  final String? search;
  final String? brandId;
  final String? categoryId;
  final String? qualityTypeId;
  final String? deviceId;
  final double? minPrice;
  final double? maxPrice;
  final String? status;
  final bool? isActive;
  final bool? isFeatured;
  final bool? isNewArrival;
  final bool? isBestSeller;
  final ProductSortBy? sortBy;
  final SortOrder? sortOrder;
  final int page;
  final int limit;

  const ProductFilterQuery({
    this.search,
    this.brandId,
    this.categoryId,
    this.qualityTypeId,
    this.deviceId,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.isActive,
    this.isFeatured,
    this.isNewArrival,
    this.isBestSeller,
    this.sortBy,
    this.sortOrder,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (brandId != null) 'brandId': brandId,
      if (categoryId != null) 'categoryId': categoryId,
      if (qualityTypeId != null) 'qualityTypeId': qualityTypeId,
      if (deviceId != null) 'deviceId': deviceId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (status != null) 'status': status,
      if (isActive != null) 'isActive': isActive,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (isNewArrival != null) 'isNewArrival': isNewArrival,
      if (isBestSeller != null) 'isBestSeller': isBestSeller,
      if (sortBy != null) 'sortBy': sortBy!.value,
      if (sortOrder != null) 'sortOrder': sortOrder!.name,
      'page': page,
      'limit': limit,
    };
  }

  ProductFilterQuery copyWith({
    String? search,
    String? brandId,
    String? categoryId,
    String? qualityTypeId,
    String? deviceId,
    double? minPrice,
    double? maxPrice,
    String? status,
    bool? isActive,
    bool? isFeatured,
    bool? isNewArrival,
    bool? isBestSeller,
    ProductSortBy? sortBy,
    SortOrder? sortOrder,
    int? page,
    int? limit,
  }) {
    return ProductFilterQuery(
      search: search ?? this.search,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      qualityTypeId: qualityTypeId ?? this.qualityTypeId,
      deviceId: deviceId ?? this.deviceId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  /// Reset filters but keep pagination
  ProductFilterQuery resetFilters() {
    return ProductFilterQuery(page: 1, limit: limit);
  }

  /// Go to next page
  ProductFilterQuery nextPage() {
    return copyWith(page: page + 1);
  }

  /// Check if any filter is applied
  bool get hasFilters =>
      search != null ||
      brandId != null ||
      categoryId != null ||
      qualityTypeId != null ||
      deviceId != null ||
      minPrice != null ||
      maxPrice != null ||
      status != null ||
      isActive != null ||
      isFeatured != null ||
      isNewArrival != null ||
      isBestSeller != null;
}
