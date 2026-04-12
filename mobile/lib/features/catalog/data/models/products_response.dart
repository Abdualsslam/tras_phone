part of 'product_model.dart';

/// Response for paginated products
class ProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int pages;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.pages,
  });

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final metaRaw = json['meta'] ?? json['pagination'];
    final meta = metaRaw is Map<String, dynamic>
        ? metaRaw
        : metaRaw is Map
        ? Map<String, dynamic>.from(metaRaw)
        : <String, dynamic>{};

    final data = json['data'];
    final dataList = data is List ? data : const [];

    return ProductsResponse(
      products: dataList
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      total: _asInt(meta['total'], fallback: dataList.length),
      page: _asInt(meta['page'], fallback: 1),
      pages: _asInt(meta['pages'] ?? meta['totalPages'], fallback: 1),
    );
  }

  factory ProductsResponse.fromEntities(
    List<ProductEntity> entities, {
    int page = 1,
    int pages = 1,
    int? total,
  }) {
    return ProductsResponse(
      products: entities
          .map(
            (entity) => ProductModel(
              id: entity.id,
              sku: entity.sku,
              name: entity.name,
              nameAr: entity.nameAr,
              slug: entity.slug,
              description: entity.description,
              descriptionAr: entity.descriptionAr,
              shortDescription: entity.shortDescription,
              shortDescriptionAr: entity.shortDescriptionAr,
              brandId: entity.brandId,
              categoryId: entity.categoryId,
              additionalCategories: entity.additionalCategories,
              qualityTypeId: entity.qualityTypeId,
              compatibleDevices: entity.compatibleDevices,
              compatibleDeviceNames: entity.compatibleDeviceNames,
              compatibleDeviceNamesAr: entity.compatibleDeviceNamesAr,
              relatedProducts: entity.relatedProducts,
              relatedEducationalContent: entity.relatedEducationalContent,
              mainImage: entity.mainImage,
              images: entity.images,
              video: entity.video,
              basePrice: entity.basePrice,
              compareAtPrice: entity.compareAtPrice,
              price: entity.tierPrice,
              stockQuantity: entity.stockQuantity,
              lowStockThreshold: entity.lowStockThreshold,
              trackInventory: entity.trackInventory,
              allowBackorder: entity.allowBackorder,
              minOrderQuantity: entity.minOrderQuantity,
              maxOrderQuantity: entity.maxOrderQuantity,
              quantityStep: entity.quantityStep,
              status: entity.status.value,
              isActive: entity.isActive,
              isFeatured: entity.isFeatured,
              isNewArrival: entity.isNewArrival,
              isBestSeller: entity.isBestSeller,
              specifications: entity.specifications,
              weight: entity.weight,
              dimensions: entity.dimensions,
              color: entity.color,
              warrantyDays: entity.warrantyDays,
              warrantyDescription: entity.warrantyDescription,
              viewsCount: entity.viewsCount,
              ordersCount: entity.ordersCount,
              salesCount: entity.salesCount,
              reviewsCount: entity.reviewsCount,
              averageRating: entity.averageRating,
              favoriteCount: entity.favoriteCount,
              tags: entity.tags,
              publishedAt: entity.publishedAt,
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
              brandName: entity.brandName,
              brandNameAr: entity.brandNameAr,
              categoryName: entity.categoryName,
              categoryNameAr: entity.categoryNameAr,
              qualityTypeName: entity.qualityTypeName,
              qualityTypeNameAr: entity.qualityTypeNameAr,
            ),
          )
          .toList(),
      total: total ?? entities.length,
      page: page,
      pages: pages,
    );
  }

  List<ProductEntity> toEntities() =>
      products.map((product) => product.toEntity()).toList();

  bool get hasNextPage => page < pages;
}
