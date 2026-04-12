import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/products_list_sections.dart';

String getProductsListSortLabel({
  required String sortBy,
  required String sortOrder,
}) {
  switch (sortBy) {
    case 'createdAt':
      return sortOrder == 'desc' ? 'الأحدث' : 'الأقدم';
    case 'price':
      return sortOrder == 'asc' ? 'السعر: الأقل' : 'السعر: الأعلى';
    case 'name':
      return 'الاسم';
    case 'salesCount':
      return 'الأكثر مبيعاً';
    default:
      return 'ترتيب';
  }
}

void showProductsListSortSheet({
  required BuildContext context,
  required String sortBy,
  required String sortOrder,
  required void Function(String sortBy, String sortOrder) onSortSelected,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) => ProductsSortSheet(
      activeSortBy: sortBy,
      activeSortOrder: sortOrder,
      onSortSelected: (nextSortBy, nextSortOrder) {
        onSortSelected(nextSortBy, nextSortOrder);
        Navigator.pop(sheetContext);
      },
    ),
  );
}

void showProductsListFilterSheet({
  required BuildContext context,
  required bool hasCategoryFilter,
  required String activeCategoryName,
  required String activeSortLabel,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: ProductsFilterSheet(
          hasCategoryFilter: hasCategoryFilter,
          activeCategoryName: activeCategoryName,
          activeSortLabel: activeSortLabel,
          onClose: () => Navigator.pop(sheetContext),
        ),
      ),
    ),
  );
}

class ProductsListBody extends StatelessWidget {
  final bool isLoading;
  final bool hasLoadedOnce;
  final String? errorMessage;
  final List<ProductEntity> products;
  final bool isStrictCategoryDeviceFlow;
  final bool isGridView;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool Function(String productId) isProductFavorite;
  final void Function(ProductEntity product) onProductTap;
  final void Function(ProductEntity product) onToggleFavorite;
  final Future<void> Function() onRetry;

  const ProductsListBody({
    super.key,
    required this.isLoading,
    required this.hasLoadedOnce,
    required this.errorMessage,
    required this.products,
    required this.isStrictCategoryDeviceFlow,
    required this.isGridView,
    required this.scrollController,
    required this.isLoadingMore,
    required this.isProductFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasLoadedOnce) {
      return const ProductsGridShimmer();
    }

    if (errorMessage != null && products.isEmpty) {
      return ProductsErrorState(onRetry: onRetry);
    }

    if (products.isEmpty) {
      return ProductsEmptyState(
        isStrictCategoryDeviceFlow: isStrictCategoryDeviceFlow,
      );
    }

    if (isGridView) {
      return ProductsGridSection(
        scrollController: scrollController,
        products: products,
        isLoadingMore: isLoadingMore,
        isProductFavorite: isProductFavorite,
        onProductTap: onProductTap,
        onToggleFavorite: onToggleFavorite,
      );
    }

    return ProductsListSection(
      scrollController: scrollController,
      products: products,
      isLoadingMore: isLoadingMore,
      isProductFavorite: isProductFavorite,
      onProductTap: onProductTap,
      onToggleFavorite: onToggleFavorite,
    );
  }
}
