# إصلاح مشكلة تحديث الـ Token في المفضلة

## المشكلة

عند محاولة إضافة منتج للمفضلة، كان يحدث الخطأ التالي:

```
[API] ✗ 409 /products/695ec6035959a294a35a4b75/wishlist
[API] Error message: Product already in wishlist
[API] ✗ 401 /products/695ec6035959a294a35a4b75/wishlist
[API] Error message: Access token not found
```

### تحليل المشكلة

1. **الطلب الأول**: يحدث 401 (غير مصرح) لأن الـ token منتهي
2. **تحديث الـ Token**: يتم تحديث الـ token بنجاح
3. **إعادة المحاولة**: يتم إعادة المحاولة مع الـ token الجديد
4. **خطأ 409**: المنتج موجود بالفعل في المفضلة (هذا طبيعي)
5. **خطأ 401 مرة أخرى**: الـ token لم يتم تمريره بشكل صحيح في الطلب الثاني

### الأسباب

1. **مشكلة في `_retryRequest`**: 
   - الـ path لم يتم التعامل معه بشكل صحيح
   - الـ headers لم يتم نسخها بشكل كامل
   - عند حدوث 409، لم يتم التعامل معه بشكل صحيح

2. **مشكلة في `onRequest`**:
   - عند وجود `X-Retry-Request`، لم يتم التحقق من وجود الـ token

3. **مشكلة في `addToWishlist`**:
   - لم يتم التعامل مع خطأ 409 بشكل صحيح (المنتج موجود بالفعل)

## الحل

### 1. تحسين `_retryRequest` في `auth_interceptor.dart`

```dart
/// Retry a request with new token
Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
  final token = await _tokenManager.getAccessToken();
  if (token == null || token.isEmpty) {
    throw DioException(
      requestOptions: requestOptions,
      error: 'Access token not found after refresh',
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 401,
        statusMessage: 'Access token not found',
      ),
    );
  }
  
  // Extract relative path (remove base URL if present)
  String relativePath = requestOptions.path;
  final baseUrl = _dio.options.baseUrl;
  if (baseUrl.isNotEmpty && relativePath.startsWith(baseUrl)) {
    relativePath = relativePath.substring(baseUrl.length);
  }
  // Ensure path starts with / (Dio expects it)
  if (!relativePath.startsWith('/')) {
    relativePath = '/$relativePath';
  }
  
  // Create new options with all original headers
  final newOptions = Options(
    method: requestOptions.method,
    headers: {
      ...requestOptions.headers,
      'Authorization': 'Bearer $token',
      'X-Retry-Request': 'true',
    },
    contentType: requestOptions.contentType,
    responseType: requestOptions.responseType,
    followRedirects: requestOptions.followRedirects,
    validateStatus: requestOptions.validateStatus,
  );

  try {
    return await _dio.request(
      relativePath,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: newOptions,
    );
  } on DioException catch (e) {
    // If we get 409 (Conflict) or other non-auth errors, don't retry again
    if (e.response?.statusCode != null && e.response!.statusCode! != 401) {
      rethrow;
    }
    rethrow;
  }
}
```

### 2. تحسين معالجة الأخطاء في `onError`

```dart
if (refreshed) {
  // Retry original request
  try {
    final response = await _retryRequest(requestOptions);
    return handler.resolve(response);
  } on DioException catch (retryError) {
    // If retry returns 401 again, token refresh didn't work properly
    if (retryError.response?.statusCode == 401) {
      await _handleLogout();
      return handler.next(retryError);
    }
    // For other errors (like 409 Conflict), just pass them through
    return handler.next(retryError);
  }
}
```

### 3. تحسين `onRequest` للتحقق من الـ token في الطلبات المعاد محاولتها

```dart
@override
void onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  // Skip if this is a retry request (token already added in _retryRequest)
  if (options.headers['X-Retry-Request'] == 'true') {
    // Ensure token is present
    final authHeader = options.headers['Authorization'];
    if (authHeader == null || !authHeader.toString().startsWith('Bearer ')) {
      // Token missing in retry request - try to add it
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }
  // ... rest of the code
}
```

### 4. تحسين معالجة 409 في `wishlist_remote_datasource.dart`

```dart
@override
Future<void> addToWishlist(String productId) async {
  developer.log('Adding to wishlist: $productId', name: 'WishlistDataSource');

  try {
    final response = await _apiClient.post(
      ApiEndpoints.productWishlist(productId),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to add to wishlist');
    }
  } on DioException catch (e) {
    // Handle 409 Conflict - product already in wishlist
    if (e.response?.statusCode == 409) {
      developer.log(
        'Product already in wishlist: $productId',
        name: 'WishlistDataSource',
      );
      // Don't throw error - product is already in wishlist, which is fine
      return;
    }
    // Re-throw other errors
    rethrow;
  }
}
```

## النتيجة

بعد الإصلاح:

1. ✅ عند انتهاء الـ token، يتم تحديثه تلقائياً
2. ✅ يتم إعادة المحاولة مع الـ token الجديد بشكل صحيح
3. ✅ عند حدوث 409 (المنتج موجود بالفعل)، لا يتم إعادة المحاولة
4. ✅ الـ token يتم تمريره بشكل صحيح في جميع الطلبات

## الملفات المعدلة

1. `mobile/lib/core/network/auth_interceptor.dart`
   - تحسين `_retryRequest`
   - تحسين معالجة الأخطاء في `onError`
   - تحسين `onRequest`

2. `mobile/lib/features/wishlist/data/datasources/wishlist_remote_datasource.dart`
   - تحسين معالجة خطأ 409

## الاختبار

للتحقق من الإصلاح:

1. انتظر حتى ينتهي الـ token (أو احذفه يدوياً)
2. حاول إضافة منتج للمفضلة
3. يجب أن يتم تحديث الـ token تلقائياً وإعادة المحاولة
4. إذا كان المنتج موجود بالفعل، يجب أن لا يحدث خطأ
