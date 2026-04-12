part of 'catalog_repository_impl.dart';

class _CatalogTaxonomyRepositoryDelegate {
  final CatalogRemoteDataSource remoteDataSource;
  final _CatalogRepositorySupport support;

  const _CatalogTaxonomyRepositoryDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, List<BrandEntity>>> getBrands({bool? featured}) {
    return support.guard(() => remoteDataSource.getBrands(featured: featured));
  }

  Future<Either<Failure, BrandEntity>> getBrandBySlug(String slug) async {
    final result = await support.guard(
      () => remoteDataSource.getBrandBySlug(slug),
    );
    return result.fold((failure) => Left(failure), (brand) {
      if (brand == null) {
        return support.notFound('العلامة التجارية غير موجودة');
      }
      return Right(brand);
    });
  }

  Future<Either<Failure, BrandEntity>> getBrandById(String id) async {
    final result = await support.guard(() => remoteDataSource.getBrandById(id));
    return result.fold((failure) => Left(failure), (brand) {
      if (brand == null) {
        return support.notFound('العلامة التجارية غير موجودة');
      }
      return Right(brand);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> getBrandProducts(
    String brandId, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) {
    return support.guard(() async {
      final cached = await support.getValidProductsMapCache(
        brandId: brandId,
        page: page,
      );
      if (cached != null) {
        unawaited(
          _refreshBrandProducts(
            brandId,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
        return cached;
      }

      final result = await remoteDataSource.getBrandProducts(
        brandId,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      await support.saveProductsMapCache(result, brandId: brandId, page: page);
      return result;
    });
  }

  Future<void> _refreshBrandProducts(
    String brandId, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final result = await remoteDataSource.getBrandProducts(
        brandId,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      await support.saveProductsMapCache(result, brandId: brandId, page: page);
    } catch (_) {}
  }

  Future<Either<Failure, List<CategoryEntity>>> getRootCategories() {
    return support.guard(remoteDataSource.getCategories);
  }

  Future<Either<Failure, List<CategoryEntity>>> getCategoryTree() {
    return support.guard(remoteDataSource.getCategoriesTree);
  }

  Future<Either<Failure, CategoryWithBreadcrumb>> getCategoryById(
    String id,
  ) async {
    final result = await support.guard(
      () => remoteDataSource.getCategoryById(id),
    );
    return result.fold((failure) => Left(failure), (category) {
      if (category == null) {
        return support.notFound('القسم غير موجود');
      }
      return Right(category);
    });
  }

  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren(
    String parentId,
  ) {
    return support.guard(() => remoteDataSource.getCategoryChildren(parentId));
  }

  Future<Either<Failure, Map<String, dynamic>>> getCategoryProducts(
    String categoryIdentifier, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) {
    return support.guard(() async {
      final cached = await support.getValidProductsMapCache(
        categoryId: categoryIdentifier,
        page: page,
      );
      if (cached != null) {
        unawaited(
          _refreshCategoryProducts(
            categoryIdentifier,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
            brandId: brandId,
            qualityTypeId: qualityTypeId,
          ),
        );
        return cached;
      }

      final result = await remoteDataSource.getCategoryProducts(
        categoryIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      await support.saveProductsMapCache(
        result,
        categoryId: categoryIdentifier,
        page: page,
      );
      return result;
    });
  }

  Future<void> _refreshCategoryProducts(
    String categoryIdentifier, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    try {
      final result = await remoteDataSource.getCategoryProducts(
        categoryIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      await support.saveProductsMapCache(
        result,
        categoryId: categoryIdentifier,
        page: page,
      );
    } catch (_) {}
  }

  Future<Either<Failure, List<DeviceEntity>>> getPopularDevices({int? limit}) {
    return support.guard(
      () => remoteDataSource.getDevices(limit: limit, popular: true),
    );
  }

  Future<Either<Failure, List<DeviceEntity>>> getDevicesByBrand(
    String brandId,
  ) {
    return support.guard(() => remoteDataSource.getDevicesByBrand(brandId));
  }

  Future<Either<Failure, DeviceEntity>> getDeviceBySlug(String slug) async {
    final result = await support.guard(
      () => remoteDataSource.getDeviceBySlug(slug),
    );
    return result.fold((failure) => Left(failure), (device) {
      if (device == null) {
        return support.notFound('الجهاز غير موجود');
      }
      return Right(device);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> getDeviceProducts(
    String deviceIdentifier, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) {
    return support.guard(() async {
      final cached = await support.getValidProductsMapCache(
        deviceId: deviceIdentifier,
        page: page,
      );
      if (cached != null) {
        unawaited(
          _refreshDeviceProducts(
            deviceIdentifier,
            page: page,
            limit: limit,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy,
            sortOrder: sortOrder,
            brandId: brandId,
            qualityTypeId: qualityTypeId,
          ),
        );
        return cached;
      }

      final result = await remoteDataSource.getDeviceProducts(
        deviceIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      await support.saveProductsMapCache(
        result,
        deviceId: deviceIdentifier,
        page: page,
      );
      return result;
    });
  }

  Future<void> _refreshDeviceProducts(
    String deviceIdentifier, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    try {
      final result = await remoteDataSource.getDeviceProducts(
        deviceIdentifier,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        brandId: brandId,
        qualityTypeId: qualityTypeId,
      );
      await support.saveProductsMapCache(
        result,
        deviceId: deviceIdentifier,
        page: page,
      );
    } catch (_) {}
  }

  Future<Either<Failure, List<QualityTypeEntity>>> getQualityTypes() {
    return support.guard(remoteDataSource.getQualityTypes);
  }
}
