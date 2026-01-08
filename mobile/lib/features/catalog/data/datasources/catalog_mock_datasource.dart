/// Catalog Mock DataSource - Provides mock data for products, categories, brands
library;

import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/quality_type_entity.dart';

class CatalogMockDataSource {
  static const _delay = Duration(milliseconds: 500);
  static final _now = DateTime.now();

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
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<CategoryEntity> _mockCategories = [
    CategoryEntity(
      id: '1',
      name: 'Screens',
      nameAr: 'شاشات',
      slug: 'screens',
      icon: 'mobile',
      productsCount: 156,
      level: 0,
      isActive: true,
      isFeatured: true,
      displayOrder: 0,
      childrenCount: 3,
      createdAt: _now,
      updatedAt: _now,
    ),
    CategoryEntity(
      id: '2',
      name: 'Batteries',
      nameAr: 'بطاريات',
      slug: 'batteries',
      icon: 'battery-full',
      productsCount: 89,
      level: 0,
      isActive: true,
      isFeatured: true,
      displayOrder: 1,
      childrenCount: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
    CategoryEntity(
      id: '3',
      name: 'Charging Ports',
      nameAr: 'منافذ الشحن',
      slug: 'charging-ports',
      icon: 'charging-station',
      productsCount: 124,
      level: 0,
      isActive: true,
      isFeatured: false,
      displayOrder: 2,
      childrenCount: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
    CategoryEntity(
      id: '4',
      name: 'Back Covers',
      nameAr: 'أغطية خلفية',
      slug: 'back-covers',
      icon: 'mobile-alt',
      productsCount: 78,
      level: 0,
      isActive: true,
      isFeatured: false,
      displayOrder: 3,
      childrenCount: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
    CategoryEntity(
      id: '5',
      name: 'Cameras',
      nameAr: 'كاميرات',
      slug: 'cameras',
      icon: 'camera',
      productsCount: 67,
      level: 0,
      isActive: true,
      isFeatured: false,
      displayOrder: 4,
      childrenCount: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK BRANDS
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<BrandEntity> _mockBrands = [
    BrandEntity(
      id: '1',
      name: 'Apple',
      nameAr: 'آبل',
      slug: 'apple',
      productsCount: 234,
      isFeatured: true,
      isActive: true,
      displayOrder: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
    BrandEntity(
      id: '2',
      name: 'Samsung',
      nameAr: 'سامسونج',
      slug: 'samsung',
      productsCount: 189,
      isFeatured: true,
      isActive: true,
      displayOrder: 1,
      createdAt: _now,
      updatedAt: _now,
    ),
    BrandEntity(
      id: '3',
      name: 'Huawei',
      nameAr: 'هواوي',
      slug: 'huawei',
      productsCount: 145,
      isFeatured: true,
      isActive: true,
      displayOrder: 2,
      createdAt: _now,
      updatedAt: _now,
    ),
    BrandEntity(
      id: '4',
      name: 'Xiaomi',
      nameAr: 'شاومي',
      slug: 'xiaomi',
      productsCount: 120,
      isFeatured: true,
      isActive: true,
      displayOrder: 3,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK DEVICES
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<DeviceEntity> _mockDevices = [
    DeviceEntity(
      id: '1',
      brandId: '1',
      name: 'iPhone 15 Pro Max',
      nameAr: 'آيفون 15 برو ماكس',
      slug: 'iphone-15-pro-max',
      modelNumber: 'A2849',
      screenSize: '6.7 inch',
      releaseYear: 2023,
      isActive: true,
      isPopular: true,
      displayOrder: 0,
      productsCount: 45,
      createdAt: _now,
      updatedAt: _now,
    ),
    DeviceEntity(
      id: '2',
      brandId: '1',
      name: 'iPhone 14 Pro',
      nameAr: 'آيفون 14 برو',
      slug: 'iphone-14-pro',
      modelNumber: 'A2650',
      screenSize: '6.1 inch',
      releaseYear: 2022,
      isActive: true,
      isPopular: true,
      displayOrder: 1,
      productsCount: 38,
      createdAt: _now,
      updatedAt: _now,
    ),
    DeviceEntity(
      id: '3',
      brandId: '2',
      name: 'Samsung Galaxy S24 Ultra',
      nameAr: 'سامسونج جالاكسي S24 الترا',
      slug: 'samsung-s24-ultra',
      modelNumber: 'SM-S928',
      screenSize: '6.8 inch',
      releaseYear: 2024,
      isActive: true,
      isPopular: true,
      displayOrder: 0,
      productsCount: 32,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK QUALITY TYPES
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<QualityTypeEntity> _mockQualityTypes = [
    QualityTypeEntity(
      id: '1',
      name: 'Original',
      nameAr: 'أصلي',
      code: 'original',
      color: '#00AA00',
      displayOrder: 0,
      isActive: true,
      defaultWarrantyDays: 365,
      createdAt: _now,
      updatedAt: _now,
    ),
    QualityTypeEntity(
      id: '2',
      name: 'OEM',
      nameAr: 'OEM',
      code: 'oem',
      color: '#0066CC',
      displayOrder: 1,
      isActive: true,
      defaultWarrantyDays: 180,
      createdAt: _now,
      updatedAt: _now,
    ),
    QualityTypeEntity(
      id: '3',
      name: 'AAA Copy',
      nameAr: 'نسخة AAA',
      code: 'aaa',
      color: '#FF9900',
      displayOrder: 2,
      isActive: true,
      defaultWarrantyDays: 90,
      createdAt: _now,
      updatedAt: _now,
    ),
    QualityTypeEntity(
      id: '4',
      name: 'Copy',
      nameAr: 'نسخة',
      code: 'copy',
      color: '#999999',
      displayOrder: 3,
      isActive: true,
      defaultWarrantyDays: 30,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<ProductEntity> _mockProducts = [
    ProductEntity(
      id: 'prod_001',
      sku: 'SCR-IP15PM-001',
      name: 'iPhone 15 Pro Max Screen',
      nameAr: 'شاشة آيفون 15 برو ماكس',
      slug: 'iphone-15-pro-max-screen',
      description: 'Original quality OLED screen for iPhone 15 Pro Max',
      descriptionAr: 'شاشة OLED أصلية لآيفون 15 برو ماكس',
      basePrice: 950.00,
      compareAtPrice: 1100.00,
      categoryId: '1',
      brandId: '1',
      qualityTypeId: '1',
      stockQuantity: 15,
      isFeatured: true,
      averageRating: 4.8,
      reviewsCount: 23,
      mainImage: 'assets/images/products/screen_1.jpg',
      images: [
        'assets/images/products/screen_1.jpg',
        'assets/images/products/screen_2.jpg',
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
    ProductEntity(
      id: 'prod_002',
      sku: 'SCR-IP14P-001',
      name: 'iPhone 14 Pro Screen',
      nameAr: 'شاشة آيفون 14 برو',
      slug: 'iphone-14-pro-screen',
      basePrice: 850.00,
      categoryId: '1',
      brandId: '1',
      qualityTypeId: '1',
      stockQuantity: 25,
      isFeatured: true,
      averageRating: 4.7,
      reviewsCount: 45,
      mainImage: 'assets/images/products/screen_2.jpg',
      images: [
        'assets/images/products/screen_2.jpg',
        'assets/images/products/screen_1.jpg',
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
    ProductEntity(
      id: 'prod_003',
      sku: 'BAT-IP13-001',
      name: 'iPhone 13 Battery',
      nameAr: 'بطارية آيفون 13',
      slug: 'iphone-13-battery',
      basePrice: 120.00,
      compareAtPrice: 150.00,
      categoryId: '2',
      brandId: '1',
      qualityTypeId: '2',
      stockQuantity: 50,
      averageRating: 4.5,
      reviewsCount: 67,
      mainImage: 'assets/images/products/bettary_1.jpg',
      images: [
        'assets/images/products/bettary_1.jpg',
        'assets/images/products/bettary_2.jpg',
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
    ProductEntity(
      id: 'prod_004',
      sku: 'SCR-S24U-001',
      name: 'Samsung S24 Ultra Screen',
      nameAr: 'شاشة سامسونج S24 الترا',
      slug: 'samsung-s24-ultra-screen',
      basePrice: 1200.00,
      categoryId: '1',
      brandId: '2',
      qualityTypeId: '1',
      stockQuantity: 8,
      isFeatured: true,
      averageRating: 4.9,
      reviewsCount: 12,
      mainImage: 'assets/images/products/screen_1.jpg',
      images: [
        'assets/images/products/screen_1.jpg',
        'assets/images/products/screen_2.jpg',
      ],
      createdAt: _now,
      updatedAt: _now,
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

  Future<List<CategoryEntity>> getCategories() async {
    await Future.delayed(_delay);
    return _mockCategories;
  }

  Future<CategoryWithBreadcrumb?> getCategoryById(String id) async {
    await Future.delayed(_delay);
    try {
      final category = _mockCategories.firstWhere((c) => c.id == id);
      return CategoryWithBreadcrumb(
        category: category,
        breadcrumb: [
          BreadcrumbItem(
            id: category.id,
            name: category.name,
            nameAr: category.nameAr,
            slug: category.slug,
          ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<CategoryEntity>> getCategoryChildren(String parentId) async {
    await Future.delayed(_delay);
    return _mockCategories.where((c) => c.parentId == parentId).toList();
  }

  Future<List<CategoryEntity>> getCategoriesTree() async {
    await Future.delayed(_delay);
    return _mockCategories;
  }

  Future<List<BrandEntity>> getBrands({bool? featured}) async {
    await Future.delayed(_delay);
    if (featured == true) {
      return _mockBrands.where((b) => b.isFeatured).toList();
    }
    return _mockBrands;
  }

  Future<BrandEntity?> getBrandBySlug(String slug) async {
    await Future.delayed(_delay);
    try {
      return _mockBrands.firstWhere((b) => b.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<List<DeviceEntity>> getDevices({int? limit}) async {
    await Future.delayed(_delay);
    if (limit != null) {
      return _mockDevices.take(limit).toList();
    }
    return _mockDevices;
  }

  Future<List<DeviceEntity>> getDevicesByBrand(String brandId) async {
    await Future.delayed(_delay);
    return _mockDevices.where((d) => d.brandId == brandId).toList();
  }

  Future<DeviceEntity?> getDeviceBySlug(String slug) async {
    await Future.delayed(_delay);
    try {
      return _mockDevices.firstWhere((d) => d.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<List<QualityTypeEntity>> getQualityTypes() async {
    await Future.delayed(_delay);
    return _mockQualityTypes;
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
      if (categoryId != null && p.categoryId != categoryId.toString())
        return false;
      if (brandId != null && p.brandId != brandId.toString()) return false;
      if (featured == true && !p.isFeatured) return false;
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            p.nameAr.toLowerCase().contains(query);
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
    return _mockProducts.reversed.take(6).toList();
  }

  Future<List<ProductEntity>> getBestSellers() async {
    await Future.delayed(_delay);
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
              p.nameAr.toLowerCase().contains(lowerQuery),
        )
        .map((p) => p.nameAr)
        .take(5)
        .toList();
  }

  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    await Future.delayed(_delay);
    return _mockProducts.where((p) => p.categoryId == categoryId).toList();
  }

  Future<List<ProductEntity>> getProductsByBrand(String brandId) async {
    await Future.delayed(_delay);
    return _mockProducts.where((p) => p.brandId == brandId).toList();
  }
}
