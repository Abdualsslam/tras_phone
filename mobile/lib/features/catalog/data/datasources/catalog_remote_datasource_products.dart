part of 'catalog_remote_datasource.dart';

class _CatalogProductsRemote {
  final _CatalogRemoteSupport _support;

  const _CatalogProductsRemote(this._support);

  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? brandId,
    String? deviceId,
    bool? featured,
    String? search,
    String? sortBy,
    String? sortOrder,
    required int page,
    required int limit,
  }) async {
    _support.log('Fetching products (page: $page)');

    final response = await _support.apiClient.get(
      ApiEndpoints.products,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (brandId != null) 'brandId': brandId,
        if (deviceId != null) 'deviceId': deviceId,
        if (featured != null) 'isFeatured': featured,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );

    return _support.parseProductsList(response.data, source: 'products');
  }

  Future<ProductsResponse> getProductsWithFilter(
    ProductFilterQuery filter,
  ) async {
    _support.log('Fetching products with filter (page: ${filter.page})');
    _support.printApiUrl(
      ApiEndpoints.products,
      queryParams: filter.toQueryParameters(),
    );

    final response = await _support.apiClient.get(
      ApiEndpoints.products,
      queryParameters: filter.toQueryParameters(),
    );

    return _support.parseProductsResponse(
      response.data,
      page: filter.page,
      limit: filter.limit,
      failureMessage: 'Failed to fetch products',
    );
  }

  Future<ProductEntity?> getProduct(String identifier) async {
    _support.log('Fetching product: $identifier');

    try {
      final response = await _support.apiClient.get(
        '${ApiEndpoints.products}/$identifier',
      );
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return ProductModel.fromJson(payload).toEntity();
    } catch (error) {
      developer.log(
        'Failed to parse/fetch product $identifier: $error',
        name: 'CatalogDataSource',
        error: error,
      );
      return null;
    }
  }

  Future<ProductEntity?> getProductById(String id) => getProduct(id);

  Future<ProductEntity?> getProductBySku(String sku) async {
    _support.log('Fetching product by SKU: $sku');

    try {
      final response = await _support.apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'sku': sku},
      );
      final list = _support.extractList(response.data);
      if (list.isEmpty || list.first is! Map) return null;
      return ProductModel.fromJson(
        Map<String, dynamic>.from(list.first as Map),
      ).toEntity();
    } catch (_) {
      _support.log('Product not found by SKU: $sku');
      return null;
    }
  }

  Future<List<ProductEntity>> getFeaturedProducts({int? limit}) async {
    _support.log('Fetching featured products');
    final response = await _support.apiClient.get(
      ApiEndpoints.productsFeatured,
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return _support.parseProductsList(
      response.data,
      source: 'featuredProducts',
    );
  }

  Future<List<ProductEntity>> getNewArrivals({int? limit}) async {
    _support.log('Fetching new arrivals');
    final response = await _support.apiClient.get(
      ApiEndpoints.productsNewArrivals,
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return _support.parseProductsList(response.data, source: 'newArrivals');
  }

  Future<List<ProductEntity>> getBestSellers({int? limit}) async {
    _support.log('Fetching best sellers');
    final response = await _support.apiClient.get(
      ApiEndpoints.productsBestSellers,
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return _support.parseProductsList(response.data, source: 'bestSellers');
  }

  Future<ProductsResponse> getProductsOnOffer({
    required int page,
    required int limit,
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) async {
    _support.log('Fetching products on offer (page: $page)');

    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
    if (maxDiscount != null) queryParams['maxDiscount'] = maxDiscount;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (brandId != null) queryParams['brandId'] = brandId;

    final response = await _support.apiClient.get(
      ApiEndpoints.productsOnOffer,
      queryParameters: queryParams,
    );

    return _support.parseProductsResponse(
      response.data,
      page: page,
      limit: limit,
      failureMessage: 'Failed to fetch products on offer',
    );
  }

  Future<List<ProductEntity>> searchProducts(
    String query, {
    required int page,
    required int limit,
  }) async {
    _support.log('Searching products: $query');

    final response = await _support.apiClient.get(
      ApiEndpoints.productsSearch,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
    );

    return _support.parseProductsList(response.data, source: 'searchProducts');
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    _support.log('Getting search suggestions: $query');
    if (query.isEmpty) return [];

    final response = await _support.apiClient.get(
      ApiEndpoints.searchSuggestions,
      queryParameters: {'q': query},
    );

    return _support.extractStringList(response.data);
  }

  Future<List<String>> getPopularSearches() async {
    _support.log('Getting popular searches');
    final response = await _support.apiClient.get(ApiEndpoints.searchPopular);
    return _support.extractStringList(response.data);
  }

  Future<List<ProductEntity>> advancedSearch({
    required String query,
    List<String>? tags,
    String? tagMode,
    bool? fuzzy,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    required int page,
    required int limit,
  }) async {
    _support.log('Advanced search: $query');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.products}/search/advanced',
      queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (tagMode != null) 'tagMode': tagMode,
        if (fuzzy != null) 'fuzzy': fuzzy,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (brandId != null) 'brandId': brandId,
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      },
    );

    return _support.parseProductsList(response.data, source: 'advancedSearch');
  }

  Future<Map<String, dynamic>> getAdvancedSearchSuggestions(
    String query, {
    int? limit,
  }) async {
    _support.log('Getting advanced search suggestions: $query');
    if (query.isEmpty) {
      return {'suggestions': [], 'tags': [], 'products': []};
    }

    final response = await _support.apiClient.get(
      '${ApiEndpoints.products}/search/suggestions',
      queryParameters: {'query': query, if (limit != null) 'limit': limit},
    );

    final payload = _support.extractPayload(response.data);
    return payload is Map<String, dynamic>
        ? payload
        : payload is Map
        ? Map<String, dynamic>.from(payload)
        : {'suggestions': [], 'tags': [], 'products': []};
  }

  Future<List<String>> getAutocompleteSuggestions(
    String query, {
    int? limit,
  }) async {
    _support.log('Getting autocomplete suggestions: $query');
    if (query.isEmpty) return [];

    final response = await _support.apiClient.get(
      '${ApiEndpoints.products}/search/autocomplete',
      queryParameters: {'query': query, if (limit != null) 'limit': limit},
    );

    return _support.extractStringList(response.data);
  }

  Future<List<String>> getAllTags() async {
    _support.log('Getting all tags');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.products}/search/tags',
    );
    return _support.extractStringList(response.data);
  }

  Future<List<Map<String, dynamic>>> getPopularTags({int? limit}) async {
    _support.log('Getting popular tags');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.products}/search/popular-tags',
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return _support.extractMapList(response.data);
  }
}
