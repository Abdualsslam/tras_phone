part of 'catalog_repository_impl.dart';

class _CatalogRepositorySupport {
  final ProductCacheService? cacheService;
  final RepositoryGuard repositoryGuard;

  const _CatalogRepositorySupport({
    required this.cacheService,
    required this.repositoryGuard,
  });

  Future<Either<Failure, T>> guard<T>(
    Future<T> Function() operation, {
    String source = 'CatalogRepository',
  }) => repositoryGuard.guardEither(operation, source: source);

  Either<Failure, T> notFound<T>(String message) {
    return Left(NotFoundFailure(message: message));
  }

  Future<Map<String, dynamic>?> getValidProductsMapCache({
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    final service = cacheService;
    if (service == null) return null;

    final cachedData = await service.getProductsList(
      categoryId: categoryId,
      brandId: brandId,
      deviceId: deviceId,
      page: page,
      filter: filter,
    );
    if (cachedData == null) return null;

    final isValid = await service.isProductsListCacheValid(
      categoryId: categoryId,
      brandId: brandId,
      deviceId: deviceId,
      page: page,
      filter: filter,
    );
    if (!isValid) return null;

    return {
      'products': cachedData.products,
      'pagination': cachedData.pagination,
    };
  }

  Future<void> saveProductsMapCache(
    Map<String, dynamic> result, {
    String? categoryId,
    String? brandId,
    String? deviceId,
    int? page,
    ProductFilterQuery? filter,
  }) async {
    final service = cacheService;
    if (service == null) return;

    await service.saveProductsList(
      products: result['products'] as List<ProductEntity>,
      pagination: result['pagination'] as Map<String, dynamic>?,
      categoryId: categoryId,
      brandId: brandId,
      deviceId: deviceId,
      page: page,
      filter: filter,
    );
  }

  Future<ProductsResponse?> getValidProductsResponseCache(
    ProductFilterQuery filter,
  ) async {
    final cachedMap = await getValidProductsMapCache(
      page: filter.page,
      filter: filter,
    );
    if (cachedMap == null) return null;

    final products = cachedMap['products'] as List<ProductEntity>;
    final pagination = cachedMap['pagination'] as Map<String, dynamic>?;
    return ProductsResponse.fromEntities(
      products,
      page: pagination?['page'] as int? ?? filter.page,
      pages: pagination?['pages'] as int? ?? 1,
      total: pagination?['total'] as int? ?? products.length,
    );
  }

  Future<void> saveProductsResponseCache(
    ProductsResponse response,
    ProductFilterQuery filter,
  ) async {
    final service = cacheService;
    if (service == null) return;

    await service.saveProductsList(
      products: response.toEntities(),
      pagination: {
        'total': response.total,
        'page': response.page,
        'pages': response.pages,
      },
      page: filter.page,
      filter: filter,
    );
  }

  Future<ProductEntity?> getValidProductCache(String identifier) async {
    final service = cacheService;
    if (service == null) return null;

    final cachedProduct = await service.getProduct(identifier);
    if (cachedProduct == null) return null;

    final isValid = await service.isProductCacheValid(identifier);
    return isValid ? cachedProduct : null;
  }

  Future<void> saveProductCache(
    String identifier,
    ProductEntity product,
  ) async {
    final service = cacheService;
    if (service == null) return;
    await service.saveProduct(identifier, product);
  }
}
