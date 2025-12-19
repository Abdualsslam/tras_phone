/// Catalog Mock DataSource - Provides mock data for products, categories, brands
library;

import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

class CatalogMockDataSource {
  static const _delay = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK BANNERS
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<BannerEntity> _mockBanners = [
    const BannerEntity(
      id: 1,
      title: 'عروض خاصة',
      titleAr: 'عروض خاصة',
      subtitle: 'خصم حتى 30%',
      subtitleAr: 'خصم حتى 30%',
      imageUrl:
          'https://via.placeholder.com/800x400/007AFF/FFFFFF?text=Special+Offers',
      placement: 'home_slider',
    ),
    const BannerEntity(
      id: 2,
      title: 'شاشات iPhone',
      titleAr: 'شاشات iPhone',
      subtitle: 'أعلى جودة',
      subtitleAr: 'أعلى جودة',
      imageUrl:
          'https://via.placeholder.com/800x400/5856D6/FFFFFF?text=iPhone+Screens',
      placement: 'home_slider',
    ),
    const BannerEntity(
      id: 3,
      title: 'بطاريات Samsung',
      titleAr: 'بطاريات Samsung',
      subtitle: 'ضمان سنة كاملة',
      subtitleAr: 'ضمان سنة كاملة',
      imageUrl:
          'https://via.placeholder.com/800x400/FF9500/FFFFFF?text=Samsung+Batteries',
      placement: 'home_slider',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<CategoryEntity> _mockCategories = [
    const CategoryEntity(
      id: 1,
      name: 'Screens',
      nameAr: 'شاشات',
      slug: 'screens',
      icon: 'mobile',
      productsCount: 156,
    ),
    const CategoryEntity(
      id: 2,
      name: 'Batteries',
      nameAr: 'بطاريات',
      slug: 'batteries',
      icon: 'battery-full',
      productsCount: 89,
    ),
    const CategoryEntity(
      id: 3,
      name: 'Charging Ports',
      nameAr: 'منافذ الشحن',
      slug: 'charging-ports',
      icon: 'charging-station',
      productsCount: 124,
    ),
    const CategoryEntity(
      id: 4,
      name: 'Back Covers',
      nameAr: 'أغطية خلفية',
      slug: 'back-covers',
      icon: 'mobile-alt',
      productsCount: 78,
    ),
    const CategoryEntity(
      id: 5,
      name: 'Cameras',
      nameAr: 'كاميرات',
      slug: 'cameras',
      icon: 'camera',
      productsCount: 67,
    ),
    const CategoryEntity(
      id: 6,
      name: 'Speakers',
      nameAr: 'سماعات',
      slug: 'speakers',
      icon: 'volume-up',
      productsCount: 45,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK BRANDS
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<BrandEntity> _mockBrands = [
    const BrandEntity(
      id: 1,
      name: 'Apple',
      nameAr: 'آبل',
      slug: 'apple',
      productsCount: 234,
      isFeatured: true,
    ),
    const BrandEntity(
      id: 2,
      name: 'Samsung',
      nameAr: 'سامسونج',
      slug: 'samsung',
      productsCount: 189,
      isFeatured: true,
    ),
    const BrandEntity(
      id: 3,
      name: 'Huawei',
      nameAr: 'هواوي',
      slug: 'huawei',
      productsCount: 145,
      isFeatured: true,
    ),
    const BrandEntity(
      id: 4,
      name: 'Xiaomi',
      nameAr: 'شاومي',
      slug: 'xiaomi',
      productsCount: 120,
      isFeatured: true,
    ),
    const BrandEntity(
      id: 5,
      name: 'Oppo',
      nameAr: 'أوبو',
      slug: 'oppo',
      productsCount: 78,
    ),
    const BrandEntity(
      id: 6,
      name: 'Vivo',
      nameAr: 'فيفو',
      slug: 'vivo',
      productsCount: 65,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<ProductEntity> _mockProducts = [
    const ProductEntity(
      id: 1,
      sku: 'SCR-IP15PM-001',
      name: 'iPhone 15 Pro Max Screen',
      nameAr: 'شاشة آيفون 15 برو ماكس',
      slug: 'iphone-15-pro-max-screen',
      description: 'Original quality OLED screen for iPhone 15 Pro Max',
      descriptionAr: 'شاشة OLED أصلية لآيفون 15 برو ماكس',
      price: 950.00,
      originalPrice: 1100.00,
      categoryId: 1,
      brandId: 1,
      stockQuantity: 15,
      isFeatured: true,
      rating: 4.8,
      reviewsCount: 23,
    ),
    const ProductEntity(
      id: 2,
      sku: 'SCR-IP14P-001',
      name: 'iPhone 14 Pro Screen',
      nameAr: 'شاشة آيفون 14 برو',
      slug: 'iphone-14-pro-screen',
      price: 850.00,
      categoryId: 1,
      brandId: 1,
      stockQuantity: 25,
      isFeatured: true,
      rating: 4.7,
      reviewsCount: 45,
    ),
    const ProductEntity(
      id: 3,
      sku: 'BAT-IP13-001',
      name: 'iPhone 13 Battery',
      nameAr: 'بطارية آيفون 13',
      slug: 'iphone-13-battery',
      price: 120.00,
      originalPrice: 150.00,
      categoryId: 2,
      brandId: 1,
      stockQuantity: 50,
      rating: 4.5,
      reviewsCount: 67,
    ),
    const ProductEntity(
      id: 4,
      sku: 'SCR-S24U-001',
      name: 'Samsung S24 Ultra Screen',
      nameAr: 'شاشة سامسونج S24 الترا',
      slug: 'samsung-s24-ultra-screen',
      price: 1200.00,
      categoryId: 1,
      brandId: 2,
      stockQuantity: 8,
      isFeatured: true,
      rating: 4.9,
      reviewsCount: 12,
    ),
    const ProductEntity(
      id: 5,
      sku: 'SCR-S23-001',
      name: 'Samsung S23 Screen',
      nameAr: 'شاشة سامسونج S23',
      slug: 'samsung-s23-screen',
      price: 780.00,
      originalPrice: 900.00,
      categoryId: 1,
      brandId: 2,
      stockQuantity: 18,
      rating: 4.6,
      reviewsCount: 34,
    ),
    const ProductEntity(
      id: 6,
      sku: 'BAT-S23-001',
      name: 'Samsung S23 Battery',
      nameAr: 'بطارية سامسونج S23',
      slug: 'samsung-s23-battery',
      price: 95.00,
      categoryId: 2,
      brandId: 2,
      stockQuantity: 65,
      rating: 4.4,
      reviewsCount: 28,
    ),
    const ProductEntity(
      id: 7,
      sku: 'CHG-IP-001',
      name: 'iPhone Charging Port',
      nameAr: 'منفذ شحن آيفون',
      slug: 'iphone-charging-port',
      price: 45.00,
      categoryId: 3,
      brandId: 1,
      stockQuantity: 100,
      rating: 4.3,
      reviewsCount: 89,
    ),
    const ProductEntity(
      id: 8,
      sku: 'CAM-IP15P-001',
      name: 'iPhone 15 Pro Camera Module',
      nameAr: 'كاميرا آيفون 15 برو',
      slug: 'iphone-15-pro-camera',
      price: 450.00,
      categoryId: 5,
      brandId: 1,
      stockQuantity: 12,
      isFeatured: true,
      rating: 4.7,
      reviewsCount: 8,
    ),
    const ProductEntity(
      id: 9,
      sku: 'SCR-HW-P60-001',
      name: 'Huawei P60 Pro Screen',
      nameAr: 'شاشة هواوي P60 برو',
      slug: 'huawei-p60-pro-screen',
      price: 650.00,
      categoryId: 1,
      brandId: 3,
      stockQuantity: 20,
      rating: 4.5,
      reviewsCount: 15,
    ),
    const ProductEntity(
      id: 10,
      sku: 'SCR-XM-14-001',
      name: 'Xiaomi 14 Pro Screen',
      nameAr: 'شاشة شاومي 14 برو',
      slug: 'xiaomi-14-pro-screen',
      price: 520.00,
      originalPrice: 600.00,
      categoryId: 1,
      brandId: 4,
      stockQuantity: 30,
      rating: 4.4,
      reviewsCount: 22,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<BannerEntity>> getBanners({String? placement}) async {
    await Future.delayed(_delay);
    if (placement != null) {
      return _mockBanners.where((b) => b.placement == placement).toList();
    }
    return _mockBanners;
  }

  Future<List<CategoryEntity>> getCategories({int? parentId}) async {
    await Future.delayed(_delay);
    if (parentId != null) {
      return _mockCategories.where((c) => c.parentId == parentId).toList();
    }
    return _mockCategories;
  }

  Future<CategoryEntity?> getCategoryById(int id) async {
    await Future.delayed(_delay);
    try {
      return _mockCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<BrandEntity>> getBrands({bool? featured}) async {
    await Future.delayed(_delay);
    if (featured == true) {
      return _mockBrands.where((b) => b.isFeatured).toList();
    }
    return _mockBrands;
  }

  Future<BrandEntity?> getBrandById(int id) async {
    await Future.delayed(_delay);
    try {
      return _mockBrands.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductEntity>> getProducts({
    int? categoryId,
    int? brandId,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(_delay);

    var products = _mockProducts.where((p) {
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (brandId != null && p.brandId != brandId) return false;
      if (featured == true && !p.isFeatured) return false;
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            (p.nameAr?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();

    // Pagination
    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= products.length) return [];
    return products.sublist(
      start,
      end > products.length ? products.length : end,
    );
  }

  Future<ProductEntity?> getProductById(int id) async {
    await Future.delayed(_delay);
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductEntity>> getFeaturedProducts() async {
    await Future.delayed(_delay);
    return _mockProducts.where((p) => p.isFeatured).toList();
  }

  Future<List<ProductEntity>> getNewArrivals() async {
    await Future.delayed(_delay);
    // Return last 6 products as "new arrivals"
    return _mockProducts.reversed.take(6).toList();
  }

  Future<List<ProductEntity>> getBestSellers() async {
    await Future.delayed(_delay);
    // Return products sorted by reviews count
    final sorted = [..._mockProducts]
      ..sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
    return sorted.take(6).toList();
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _mockProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              (p.nameAr?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .map((p) => p.nameAr ?? p.name)
        .take(5)
        .toList();
  }
}
