import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/core/errors/failures.dart';
import 'package:tras_phone/features/catalog/data/models/product_model.dart';
import 'package:tras_phone/features/catalog/data/models/product_review_model.dart';
import 'package:tras_phone/features/catalog/domain/entities/product_entity.dart';
import 'package:tras_phone/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:tras_phone/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:tras_phone/features/education/domain/entities/educational_content_entity.dart';
import 'package:tras_phone/features/education/domain/repositories/education_repository.dart';
import 'package:tras_phone/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:tras_phone/l10n/app_localizations.dart';

import '../../../../fixtures/product_detail_payload_fixture.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockEducationRepository extends Mock implements EducationRepository {}

void main() {
  late MockFavoriteRepository favoriteRepository;
  late MockCatalogRepository catalogRepository;
  late MockEducationRepository educationRepository;
  late ProductEntity product;
  late ProductEntity initialProduct;
  late ProductEntity inStockProduct;

  setUp(() {
    favoriteRepository = MockFavoriteRepository();
    catalogRepository = MockCatalogRepository();
    educationRepository = MockEducationRepository();
    product = ProductModel.fromJson(productDetailPayloadData()).toEntity();
    inStockProduct = ProductModel.fromJson({
      ...productDetailPayloadData(),
      'stockQuantity': 4,
    }).toEntity();
    initialProduct = ProductModel.fromJson({
      ...productDetailPayloadData(),
      'compatibleDevices': const [
        '69cfda3b570af0e74bb7d672',
        '69cfda3b570af0e74bb7d66f',
      ],
    }).toEntity();

    when(
      () => favoriteRepository.isFavorite(any()),
    ).thenAnswer((_) async => false);
    when(
      () => catalogRepository.getProduct(any()),
    ).thenAnswer((_) async => Right<Failure, ProductEntity>(product));
    when(() => catalogRepository.getProductReviews(any())).thenAnswer(
      (_) async => const Right<Failure, List<ProductReviewModel>>(
        <ProductReviewModel>[],
      ),
    );
    when(
      () => catalogRepository.getMyReview(any()),
    ).thenAnswer((_) async => const Right<Failure, ProductReviewModel?>(null));
    when(
      () => educationRepository.getProductEducationalContent(
        productId: any(named: 'productId'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'content': <EducationalContentEntity>[],
        'pagination': <String, dynamic>{'pages': 1, 'total': 0},
      },
    );
  });

  Widget buildTestApp(ProductEntity product) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<FavoriteRepository>.value(
              value: favoriteRepository,
            ),
            RepositoryProvider<CatalogRepository>.value(
              value: catalogRepository,
            ),
            RepositoryProvider<EducationRepository>.value(
              value: educationRepository,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: child,
          ),
        );
      },
      child: ProductDetailsScreen(product: product),
    );
  }

  testWidgets(
    'renders compatible devices after loading full product details and keeps add-to-cart disabled when out of stock',
    (tester) async {
      await tester.pumpWidget(buildTestApp(initialProduct));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.text(product.nameAr), findsOneWidget);
      expect(find.byType(Scrollable), findsWidgets);
      expect(find.textContaining('0 ر.س'), findsWidgets);

      final context = tester.element(find.byType(ProductDetailsScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.outOfStock), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.byType(Scrollable), findsWidgets);
      expect(find.text('الأجهزة المتوافقة'), findsOneWidget);
      expect(find.text('IPHONE 11 PRO MAX'), findsOneWidget);
      expect(find.text('IPHONE 11'), findsOneWidget);

      final addToCartText = find.text(l10n.addToCart);
      expect(addToCartText, findsOneWidget);

      final addToCartInkWell = tester.widget<InkWell>(
        find.ancestor(of: addToCartText, matching: find.byType(InkWell)).first,
      );
      expect(addToCartInkWell.onTap, isNull);

      verify(() => catalogRepository.getProduct(initialProduct.id)).called(1);
      verify(() => favoriteRepository.isFavorite(product.id)).called(1);
      verify(() => catalogRepository.getProductReviews(product.id)).called(1);
      verify(() => catalogRepository.getMyReview(product.id)).called(1);
      verify(
        () => educationRepository.getProductEducationalContent(
          productId: product.id,
          page: 1,
          limit: 3,
        ),
      ).called(1);
    },
  );

  testWidgets('shows in-stock state without revealing stock count', (
    tester,
  ) async {
    when(
      () => catalogRepository.getProduct(any()),
    ).thenAnswer((_) async => Right<Failure, ProductEntity>(inStockProduct));

    await tester.pumpWidget(buildTestApp(inStockProduct));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final context = tester.element(find.byType(ProductDetailsScreen));
    final l10n = AppLocalizations.of(context)!;

    expect(find.text(l10n.inStock), findsOneWidget);
    expect(find.textContaining('قطعة متاحة'), findsNothing);
  });
}
