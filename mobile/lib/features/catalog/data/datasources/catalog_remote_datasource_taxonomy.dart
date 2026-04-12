part of 'catalog_remote_datasource.dart';

class _CatalogTaxonomyRemote {
  final _CatalogRemoteSupport _support;

  const _CatalogTaxonomyRemote(this._support);

  Future<List<CategoryEntity>> getCategories() async {
    _support.log('Fetching root categories');
    final response = await _support.apiClient.get(ApiEndpoints.categories);
    return _support.parseEntityList(
      response.data,
      (json) => CategoryModel.fromJson(json).toEntity(),
    );
  }

  Future<CategoryWithBreadcrumb?> getCategoryById(String id) async {
    _support.log('Fetching category: $id');

    try {
      final response = await _support.apiClient.get(
        '${ApiEndpoints.categories}/$id',
      );
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return CategoryWithBreadcrumbModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Category not found: $id');
      return null;
    }
  }

  Future<List<CategoryEntity>> getCategoryChildren(String parentId) async {
    _support.log('Fetching category children: $parentId');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.categories}/$parentId/children',
    );
    return _support.parseEntityList(
      response.data,
      (json) => CategoryModel.fromJson(json).toEntity(),
    );
  }

  Future<List<CategoryEntity>> getCategoriesTree() async {
    _support.log('Fetching categories tree');
    final response = await _support.apiClient.get(ApiEndpoints.categoriesTree);
    return _support.parseEntityList(
      response.data,
      (json) => CategoryModel.fromJson(json).toEntity(),
    );
  }

  Future<Map<String, dynamic>> getCategoryProducts(
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
    _support.log(
      'Fetching products for category: $categoryIdentifier (page: $page)',
    );

    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (brandId != null) queryParams['brandId'] = brandId;
    if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;

    final endpoint = ApiEndpoints.categoryProducts(categoryIdentifier);
    _support.printApiUrl(endpoint, queryParams: queryParams);

    final response = await _support.apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final products = _support.parseProductsList(
      responseData['data'],
      source: 'categoryProducts',
    );
    final pagination = _support.extractPagination(
      responseData,
      page: page,
      limit: limit,
      fallbackTotal: products.length,
    );

    return {'products': products, 'pagination': pagination};
  }

  Future<List<BrandEntity>> getBrands({bool? featured}) async {
    _support.log('Fetching brands');
    final queryParams = <String, dynamic>{
      if (featured != null) 'featured': featured,
    };
    _support.printApiUrl(
      ApiEndpoints.brands,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final response = await _support.apiClient.get(
      ApiEndpoints.brands,
      queryParameters: queryParams,
    );
    return _support.parseEntityList(
      response.data,
      (json) => BrandModel.fromJson(json).toEntity(),
    );
  }

  Future<BrandEntity?> getBrandBySlug(String slug) async {
    _support.log('Fetching brand: $slug');

    try {
      final endpoint = '${ApiEndpoints.brands}/$slug';
      _support.printApiUrl(endpoint);
      final response = await _support.apiClient.get(endpoint);
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return BrandModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Brand not found: $slug');
      return null;
    }
  }

  Future<BrandEntity?> getBrandById(String id) async {
    _support.log('Fetching brand by ID: $id');

    try {
      final endpoint = '${ApiEndpoints.brands}/$id';
      _support.printApiUrl(endpoint);
      final response = await _support.apiClient.get(endpoint);
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return BrandModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Brand not found by ID as slug, searching in brands list');
      try {
        final brands = await getBrands();
        return brands.firstWhere((brand) => brand.id == id);
      } catch (_) {
        _support.log('Brand not found by ID: $id');
        return null;
      }
    }
  }

  Future<Map<String, dynamic>> getBrandProducts(
    String brandId, {
    required int page,
    required int limit,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    _support.log('Fetching products for brand ID: $brandId (page: $page)');

    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final endpoint = ApiEndpoints.brandProducts(brandId);
    _support.printApiUrl(endpoint, queryParams: queryParams);

    final response = await _support.apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final products = _support.parseProductsList(
      responseData['data'],
      source: 'brandProducts',
    );
    final pagination = _support.extractPagination(
      responseData,
      page: page,
      limit: limit,
      fallbackTotal: products.length,
    );

    return {'products': products, 'pagination': pagination};
  }

  Future<List<DeviceEntity>> getDevices({int? limit, bool? popular}) async {
    _support.log('Fetching devices');
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (popular != null) queryParams['popular'] = popular;
    _support.printApiUrl(
      ApiEndpoints.devices,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await _support.apiClient.get(
      ApiEndpoints.devices,
      queryParameters: queryParams,
    );
    return _support.parseEntityList(
      response.data,
      (json) => DeviceModel.fromJson(json).toEntity(),
    );
  }

  Future<List<DeviceEntity>> getDevicesByBrand(String brandId) async {
    _support.log('Fetching devices for brand: $brandId');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.devices}/brand/$brandId',
    );
    return _support.parseEntityList(
      response.data,
      (json) => DeviceModel.fromJson(json).toEntity(),
    );
  }

  Future<DeviceEntity?> getDeviceBySlug(String slug) async {
    _support.log('Fetching device: $slug');

    try {
      final endpoint = '${ApiEndpoints.devices}/$slug';
      _support.printApiUrl(endpoint);
      final response = await _support.apiClient.get(endpoint);
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return DeviceModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Device not found: $slug');
      return null;
    }
  }

  Future<Map<String, dynamic>> getDeviceProducts(
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
    _support.log(
      'Fetching products for device: $deviceIdentifier (page: $page)',
    );

    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (brandId != null) queryParams['brandId'] = brandId;
    if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;

    final endpoint = ApiEndpoints.deviceProducts(deviceIdentifier);
    _support.printApiUrl(endpoint, queryParams: queryParams);

    final response = await _support.apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final products = _support.parseProductsList(
      responseData['data'],
      source: 'deviceProducts',
    );
    final pagination = _support.extractPagination(
      responseData,
      page: page,
      limit: limit,
      fallbackTotal: products.length,
    );

    return {'products': products, 'pagination': pagination};
  }

  Future<List<QualityTypeEntity>> getQualityTypes() async {
    _support.log('Fetching quality types');
    final response = await _support.apiClient.get(ApiEndpoints.qualityTypes);
    return _support.parseEntityList(
      response.data,
      (json) => QualityTypeModel.fromJson(json).toEntity(),
    );
  }

  Future<List<BannerEntity>> getBanners({String? placement}) async {
    _support.log('Fetching banners');
    final response = await _support.apiClient.get(
      ApiEndpoints.banners,
      queryParameters: {if (placement != null) 'placement': placement},
    );
    return _support.parseEntityList(
      response.data,
      (json) => BannerModel.fromJson(json).toEntity(),
    );
  }
}
