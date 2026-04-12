part of 'auth_interceptor.dart';

class _AuthEndpointPolicy {
  const _AuthEndpointPolicy();

  bool isAuthEntryEndpoint(String path) {
    final basePath = path.split('?').first;
    const authEntryEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.requestPasswordReset,
      ApiEndpoints.verifyResetOtp,
      ApiEndpoints.resetPassword,
    ];

    return authEntryEndpoints.contains(basePath);
  }

  bool isRefreshEndpoint(String path) {
    return path.contains(ApiEndpoints.refreshToken);
  }

  bool isPublicEndpoint(String path) {
    final basePath = path.split('?').first;

    const exactPublicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refreshToken,
      ApiEndpoints.brands,
      ApiEndpoints.categories,
      ApiEndpoints.products,
      ApiEndpoints.banners,
      ApiEndpoints.faqs,
      ApiEndpoints.settings,
      ApiEndpoints.appVersion,
    ];

    if (exactPublicEndpoints.contains(basePath)) {
      return true;
    }

    if (basePath.startsWith('/products/') &&
        (basePath.endsWith('/reviews') ||
            RegExp(r'^/products/[^/]+$').hasMatch(basePath))) {
      return true;
    }

    if (basePath.contains('/favorite') ||
        basePath.contains('/cart') ||
        basePath.contains('/orders') ||
        basePath.contains('/customer/') ||
        basePath.contains('/tickets') ||
        basePath.contains('/stock-alerts')) {
      return false;
    }

    const prefixPublicEndpoints = [
      '/auth/',
      '/catalog/',
      '/products/featured',
      '/products/new-arrivals',
      '/products/best-sellers',
      '/products/on-offer',
      '/products/search',
    ];

    return prefixPublicEndpoints.any(basePath.startsWith);
  }
}
