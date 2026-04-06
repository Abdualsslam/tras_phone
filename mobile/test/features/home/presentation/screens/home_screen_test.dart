import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tras_phone/core/di/injection.dart';
import 'package:tras_phone/features/banners/presentation/cubit/banners_cubit.dart';
import 'package:tras_phone/features/banners/presentation/cubit/banners_state.dart';
import 'package:tras_phone/features/catalog/domain/entities/brand_entity.dart';
import 'package:tras_phone/features/catalog/domain/entities/category_entity.dart';
import 'package:tras_phone/features/catalog/domain/entities/product_entity.dart';
import 'package:tras_phone/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:tras_phone/features/home/presentation/cubit/home_cubit.dart';
import 'package:tras_phone/features/home/presentation/cubit/home_state.dart';
import 'package:tras_phone/features/home/presentation/screens/home_screen.dart';
import 'package:tras_phone/l10n/app_localizations.dart';
import 'package:tras_phone/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:tras_phone/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:tras_phone/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:tras_phone/features/promotions/presentation/cubit/promotions_state.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class _MockBannersCubit extends MockCubit<BannersState> implements BannersCubit {}

class _MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class _MockPromotionsCubit extends MockCubit<PromotionsState>
    implements PromotionsCubit {}

class _MockFavoriteRemoteDataSource extends Mock
    implements FavoriteRemoteDataSource {}

void main() {
  late _MockHomeCubit homeCubit;
  late _MockBannersCubit bannersCubit;
  late _MockNotificationsCubit notificationsCubit;
  late _MockPromotionsCubit promotionsCubit;
  late _MockFavoriteRemoteDataSource favoriteDataSource;

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final now = DateTime(2026, 1, 1);

  CategoryEntity buildCategory() => CategoryEntity(
    id: 'cat-1',
    name: 'Screens',
    nameAr: 'شاشات',
    slug: 'screens',
    level: 0,
    isActive: true,
    isFeatured: true,
    displayOrder: 1,
    productsCount: 1,
    childrenCount: 0,
    createdAt: now,
    updatedAt: now,
  );

  BrandEntity buildBrand() => BrandEntity(
    id: 'brand-1',
    name: 'Apple',
    nameAr: 'أبل',
    slug: 'apple',
    isActive: true,
    isFeatured: true,
    displayOrder: 1,
    productsCount: 1,
    createdAt: now,
    updatedAt: now,
  );

  ProductEntity buildProduct() => ProductEntity(
    id: 'prod-1',
    sku: 'SKU-1',
    name: 'Screen',
    nameAr: 'شاشة ايفون',
    slug: 'screen',
    brandId: 'brand-1',
    categoryId: 'cat-1',
    qualityTypeId: 'quality-1',
    basePrice: 100,
    stockQuantity: 3,
    createdAt: now,
    updatedAt: now,
  );

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>.value(value: homeCubit),
            BlocProvider<BannersCubit>.value(value: bannersCubit),
            BlocProvider<NotificationsCubit>.value(value: notificationsCubit),
            BlocProvider<PromotionsCubit>.value(value: promotionsCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      ),
    );
  }

  setUp(() {
    homeCubit = _MockHomeCubit();
    bannersCubit = _MockBannersCubit();
    notificationsCubit = _MockNotificationsCubit();
    promotionsCubit = _MockPromotionsCubit();
    favoriteDataSource = _MockFavoriteRemoteDataSource();

    getIt.reset();
    getIt.registerLazySingleton<FavoriteRemoteDataSource>(
      () => favoriteDataSource,
    );

    when(() => favoriteDataSource.getFavoriteProductIds()).thenAnswer(
      (_) async => <String>{},
    );
    when(() => homeCubit.loadHomeData()).thenAnswer((_) async {});
    when(() => notificationsCubit.getUnreadCount()).thenAnswer((_) async {});
    when(() => promotionsCubit.loadActivePromotions()).thenAnswer((_) async {});
    when(
      () => bannersCubit.loadBanners(
        placement: any(named: 'placement'),
        refresh: any(named: 'refresh'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});
    when(() => notificationsCubit.state).thenReturn(const NotificationsInitial());
    whenListen(
      notificationsCubit,
      Stream<NotificationsState>.fromIterable(const [NotificationsInitial()]),
    );
    when(() => promotionsCubit.state).thenReturn(PromotionsInitial());
    whenListen(
      promotionsCubit,
      Stream<PromotionsState>.fromIterable([PromotionsInitial()]),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders home content from loaded state', (tester) async {
    setPhoneViewport(tester);

    final loadedState = HomeLoaded(
      categories: [buildCategory()],
      brands: [buildBrand()],
      featuredProducts: [buildProduct()],
      newArrivals: [buildProduct()],
      bestSellers: [buildProduct()],
    );

    when(() => homeCubit.state).thenReturn(loadedState);
    whenListen(homeCubit, Stream<HomeState>.fromIterable([loadedState]));
    when(() => bannersCubit.state).thenReturn(const BannersLoaded([]));
    whenListen(bannersCubit, Stream<BannersState>.fromIterable(const [
      BannersLoaded([]),
    ]));

    await pumpHomeScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('شاشات'), findsOneWidget);
    expect(find.text('أبل'), findsOneWidget);
    expect(find.text('شاشة ايفون'), findsWidgets);
  });

  testWidgets('renders error state when home fails', (tester) async {
    setPhoneViewport(tester);

    const errorState = HomeError('failure');

    when(() => homeCubit.state).thenReturn(errorState);
    whenListen(homeCubit, Stream<HomeState>.fromIterable([errorState]));
    when(() => bannersCubit.state).thenReturn(const BannersInitial());
    whenListen(
      bannersCubit,
      Stream<BannersState>.fromIterable(const [BannersInitial()]),
    );

    await pumpHomeScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('failure'), findsOneWidget);
  });
}
