part of 'catalog_repository_impl.dart';

class _CatalogProductsRepositoryDelegate {
  final CatalogRemoteDataSource remoteDataSource;
  final _CatalogRepositorySupport support;

  const _CatalogProductsRepositoryDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, ProductsResponse>> getProducts(
    ProductFilterQuery filter,
  ) {
    return support.guard(() async {
      final cachedResponse = await support.getValidProductsResponseCache(
        filter,
      );
      if (cachedResponse != null) {
        unawaited(_refreshProducts(filter));
        return cachedResponse;
      }

      final response = await remoteDataSource.getProductsWithFilter(filter);
      await support.saveProductsResponseCache(response, filter);
      return response;
    });
  }

  Future<void> _refreshProducts(ProductFilterQuery filter) async {
    try {
      final response = await remoteDataSource.getProductsWithFilter(filter);
      await support.saveProductsResponseCache(response, filter);
    } catch (_) {}
  }

  Future<Either<Failure, ProductEntity>> getProduct(String identifier) async {
    try {
      final cachedProduct = await support.getValidProductCache(identifier);
      if (cachedProduct != null) {
        unawaited(_refreshProduct(identifier));
        return Right(cachedProduct);
      }

      final product = await remoteDataSource.getProduct(identifier);
      if (product == null) {
        return support.notFound<ProductEntity>('المنتج غير موجود');
      }

      await support.saveProductCache(identifier, product);
      return Right(product);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }

  Future<void> _refreshProduct(String identifier) async {
    try {
      final product = await remoteDataSource.getProduct(identifier);
      if (product != null) {
        await support.saveProductCache(identifier, product);
      }
    } catch (_) {}
  }

  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int? limit,
  }) {
    return support.guard(
      () => remoteDataSource.getFeaturedProducts(limit: limit),
    );
  }

  Future<Either<Failure, List<ProductEntity>>> getNewArrivals({int? limit}) {
    return support.guard(() => remoteDataSource.getNewArrivals(limit: limit));
  }

  Future<Either<Failure, List<ProductEntity>>> getBestSellers({int? limit}) {
    return support.guard(() => remoteDataSource.getBestSellers(limit: limit));
  }

  Future<Either<Failure, ProductsResponse>> getProductsOnOffer({
    required int page,
    required int limit,
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) {
    return support.guard(
      () => remoteDataSource.getProductsOnOffer(
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
        minDiscount: minDiscount,
        maxDiscount: maxDiscount,
        categoryId: categoryId,
        brandId: brandId,
      ),
    );
  }
}
