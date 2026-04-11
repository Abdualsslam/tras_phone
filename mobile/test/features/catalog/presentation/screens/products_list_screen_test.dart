import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tras_phone/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:tras_phone/features/catalog/data/models/product_filter_query.dart';
import 'package:tras_phone/features/catalog/data/models/product_model.dart';
import 'package:tras_phone/features/catalog/presentation/screens/products_list_screen.dart';
import 'package:tras_phone/features/favorite/domain/repositories/favorite_repository.dart';

class _MockCatalogRemoteDataSource extends Mock
    implements CatalogRemoteDataSource {}

class _MockFavoriteRepository extends Mock implements FavoriteRepository {}

class _FakeProductFilterQuery extends Fake implements ProductFilterQuery {}

void main() {
  late _MockCatalogRemoteDataSource dataSource;
  late _MockFavoriteRepository favoriteRepository;

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUpAll(() {
    registerFallbackValue(_FakeProductFilterQuery());
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<CatalogRemoteDataSource>.value(
              value: dataSource,
            ),
            RepositoryProvider<FavoriteRepository>.value(
              value: favoriteRepository,
            ),
          ],
          child: const MaterialApp(
            home: ProductsListScreen(title: 'اختبار المنتجات'),
          ),
        ),
      ),
    );
  }

  setUp(() {
    dataSource = _MockCatalogRemoteDataSource();
    favoriteRepository = _MockFavoriteRepository();

    when(
      () => favoriteRepository.getFavoriteProductIds(),
    ).thenAnswer((_) async => <String>{});
  });

  testWidgets('shows error state when request fails', (tester) async {
    setPhoneViewport(tester);

    when(
      () => dataSource.getProductsWithFilter(any()),
    ).thenThrow(Exception('network'));

    await pumpScreen(tester);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('products-error-state')), findsOneWidget);
    expect(find.text('تعذر تحميل المنتجات'), findsOneWidget);
  });

  testWidgets('shows products when request succeeds', (tester) async {
    setPhoneViewport(tester);

    when(() => dataSource.getProductsWithFilter(any())).thenAnswer(
      (_) async => ProductsResponse(
        products: [
          ProductModel(
            id: 'prod-1',
            sku: 'SKU-1',
            name: 'Screen',
            nameAr: 'شاشة ايفون',
            slug: 'screen',
            brandId: 'brand-1',
            categoryId: 'cat-1',
            qualityTypeId: 'quality-1',
            basePrice: 100,
            stockQuantity: 5,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
        total: 1,
        page: 1,
        pages: 1,
      ),
    );

    await pumpScreen(tester);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('شاشة ايفون'), findsOneWidget);
    expect(find.byKey(const ValueKey('products-grid')), findsOneWidget);
  });
}
