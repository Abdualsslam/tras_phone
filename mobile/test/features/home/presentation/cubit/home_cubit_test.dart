import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tras_phone/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:tras_phone/features/catalog/domain/entities/brand_entity.dart';
import 'package:tras_phone/features/catalog/domain/entities/category_entity.dart';
import 'package:tras_phone/features/catalog/domain/entities/product_entity.dart';
import 'package:tras_phone/features/home/data/models/home_cache_data.dart';
import 'package:tras_phone/features/home/data/services/home_cache_service.dart';
import 'package:tras_phone/features/home/presentation/cubit/home_cubit.dart';
import 'package:tras_phone/features/home/presentation/cubit/home_state.dart';

class _MockCatalogRemoteDataSource extends Mock
    implements CatalogRemoteDataSource {}

class _MockHomeCacheService extends Mock implements HomeCacheService {}

void main() {
  late _MockCatalogRemoteDataSource dataSource;
  late _MockHomeCacheService cacheService;
  late HomeCubit cubit;

  final now = DateTime(2026, 1, 1);

  CategoryEntity buildCategory(String id, String nameAr) => CategoryEntity(
    id: id,
    name: nameAr,
    nameAr: nameAr,
    slug: id,
    level: 0,
    isActive: true,
    isFeatured: true,
    displayOrder: 1,
    productsCount: 1,
    childrenCount: 0,
    createdAt: now,
    updatedAt: now,
  );

  BrandEntity buildBrand(String id, String nameAr) => BrandEntity(
    id: id,
    name: nameAr,
    nameAr: nameAr,
    slug: id,
    isActive: true,
    isFeatured: true,
    displayOrder: 1,
    productsCount: 1,
    createdAt: now,
    updatedAt: now,
  );

  ProductEntity buildProduct(String id, String nameAr) => ProductEntity(
    id: id,
    sku: 'SKU-$id',
    name: nameAr,
    nameAr: nameAr,
    slug: id,
    brandId: 'brand-1',
    categoryId: 'cat-1',
    qualityTypeId: 'quality-1',
    basePrice: 100,
    stockQuantity: 5,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    dataSource = _MockCatalogRemoteDataSource();
    cacheService = _MockHomeCacheService();
    cubit = HomeCubit(dataSource: dataSource, cacheService: cacheService);
  });

  test('emits cached data first then fresh data update', () async {
    final cachedCategories = [buildCategory('cat-1', 'شاشات')];
    final cachedBrands = [buildBrand('brand-1', 'Apple')];
    final cachedProducts = [buildProduct('prod-1', 'شاشة ايفون')];
    final freshProducts = [buildProduct('prod-2', 'بطارية ايفون')];

    final cachedData = HomeCacheData.fromEntities(
      categories: cachedCategories,
      brands: cachedBrands,
      featuredProducts: cachedProducts,
      newArrivals: cachedProducts,
      bestSellers: cachedProducts,
    );

    when(() => cacheService.getHomeData()).thenAnswer((_) async => cachedData);
    when(() => cacheService.isCacheValid()).thenAnswer((_) async => true);
    when(
      () => dataSource.getCategories(),
    ).thenAnswer((_) async => cachedCategories);
    when(() => dataSource.getBrands(featured: true)).thenAnswer(
      (_) async => cachedBrands,
    );
    when(
      () => dataSource.getFeaturedProducts(),
    ).thenAnswer((_) async => freshProducts);
    when(
      () => dataSource.getNewArrivals(),
    ).thenAnswer((_) async => freshProducts);
    when(
      () => dataSource.getBestSellers(),
    ).thenAnswer((_) async => freshProducts);
    when(
      () => cacheService.saveHomeData(
        categories: any(named: 'categories'),
        brands: any(named: 'brands'),
        featuredProducts: any(named: 'featuredProducts'),
        newArrivals: any(named: 'newArrivals'),
        bestSellers: any(named: 'bestSellers'),
      ),
    ).thenAnswer((_) async {});

    final states = <HomeState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadHomeData();
    await Future<void>.delayed(Duration.zero);

    expect(states[0], isA<HomeLoading>());
    expect(states[1], isA<HomeLoadedFromCache>());
    expect(states[2], isA<HomeLoaded>());
    expect((states[1] as HomeLoadedFromCache).featuredProducts.first.id, 'prod-1');
    expect((states[2] as HomeLoaded).featuredProducts.first.id, 'prod-2');

    await subscription.cancel();
  });
}
