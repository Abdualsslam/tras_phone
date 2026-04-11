library;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/failures.dart';
import '../../features/catalog/domain/entities/product_entity.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/screens/advanced_search_screen.dart';
import '../../features/catalog/presentation/screens/brand_details_screen.dart';
import '../../features/catalog/presentation/screens/category_products_screen.dart';
import '../../features/catalog/presentation/screens/device_products_screen.dart';
import '../../features/catalog/presentation/screens/devices_list_screen.dart';
import '../../features/catalog/presentation/screens/product_search_results_screen.dart';
import '../../features/catalog/presentation/screens/screens.dart';
import '../../features/catalog/presentation/screens/search_history_screen.dart';
import '../../features/education/presentation/screens/product_education_list_screen.dart';
import '../app_route_paths.dart';
import '../route_args.dart';

List<RouteBase> buildCatalogRoutes() {
  return [
    GoRoute(path: AppRoutePaths.product, builder: _buildProductRoute),
    GoRoute(path: AppRoutePaths.productAlias, builder: _buildProductRoute),
    GoRoute(
      path: AppRoutePaths.productEducation,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = ProductEducationRouteArgs.fromNavigation(
          extra: state.extra,
          queryParameters: state.uri.queryParameters,
        );

        return ProductEducationListScreen(
          productId: id,
          productName: args.productName,
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.categories,
      builder: (context, state) => const CategoriesListScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.brands,
      builder: (context, state) {
        final flowParam = state.uri.queryParameters['flow'];
        final flow =
            flowParam == null || flowParam == '1' || flowParam == 'true';

        return BrandsListScreen(
          flowMode: flow,
          categoryId: state.uri.queryParameters['categoryId'],
          categoryName: state.uri.queryParameters['categoryName'],
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.products,
      builder: (context, state) {
        final query = state.uri.queryParameters;
        final isFeatured = query['isFeatured'] ?? query['featured'];

        return ProductsListScreen(
          isFeatured: isFeatured == 'true' ? true : null,
          sortBy: query['sort'],
          categoryId: query['categoryId'],
          categoryName: query['categoryName'],
          brandId: query['brandId'],
          brandName: query['brandName'],
          deviceId: query['deviceId'],
          deviceName: query['deviceName'],
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.category,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CategoryProductsScreen(
          categoryId: id,
          categoryName: state.uri.queryParameters['name'],
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.brand,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return BrandDetailsScreen(brandSlug: slug);
      },
    ),
    GoRoute(
      path: AppRoutePaths.devices,
      builder: (context, state) {
        final query = state.uri.queryParameters;
        final flow = query['flow'] == '1' || query['flow'] == 'true';

        return DevicesListScreen(
          flowMode: flow,
          categoryId: query['categoryId'],
          categoryName: query['categoryName'],
          initialBrandId: query['brandId'],
          initialBrandName: query['brandName'],
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.device,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DeviceProductsScreen(
          deviceId: id,
          deviceName: state.uri.queryParameters['name'],
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.searchHistory,
      builder: (context, state) => const SearchHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.advancedSearch,
      builder: (context, state) => const AdvancedSearchScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.searchResults,
      builder: (context, state) {
        final args = SearchResultsRouteArgs.fromExtra(state.extra);
        return ProductSearchResultsScreen(filters: args.filters);
      },
    ),
  ];
}

Widget _buildProductRoute(BuildContext context, GoRouterState state) {
  final productId = state.pathParameters['id'] ?? '';
  final product = state.extra as ProductEntity?;

  if (product != null) {
    return ProductDetailsScreen(product: product);
  }

  if (productId.isEmpty) {
    return const _CatalogFallbackScreen(
      title: 'المنتج',
      message: 'المنتج غير موجود',
    );
  }

  return _ProductDetailsLoader(productId: productId);
}

class _ProductDetailsLoader extends StatelessWidget {
  final String productId;

  const _ProductDetailsLoader({required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, ProductEntity>>(
      future: context.read<CatalogRepository>().getProduct(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;
        if (result == null) {
          return const _CatalogFallbackScreen(
            title: 'المنتج',
            message: 'تعذر تحميل المنتج',
          );
        }

        return result.fold(
          (failure) =>
              _CatalogFallbackScreen(title: 'المنتج', message: failure.message),
          (product) => ProductDetailsScreen(product: product),
        );
      },
    );
  }
}

class _CatalogFallbackScreen extends StatelessWidget {
  final String title;
  final String message;

  const _CatalogFallbackScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}
