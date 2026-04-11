library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

class ProductsListTopBar extends StatelessWidget {
  final int productsCount;
  final bool isLoading;
  final String sortLabel;
  final bool isGridView;
  final VoidCallback onSortTap;
  final VoidCallback onLayoutToggle;

  const ProductsListTopBar({
    super.key,
    required this.productsCount,
    required this.isLoading,
    required this.sortLabel,
    required this.isGridView,
    required this.onSortTap,
    required this.onLayoutToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '$productsCount منتج',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                if (isLoading) ...[
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: GestureDetector(
              onTap: onSortTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.sort, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        sortLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onLayoutToggle,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isGridView ? Iconsax.menu_1 : Iconsax.element_3,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveCategoryFilterBar extends StatelessWidget {
  final String categoryName;

  const ActiveCategoryFilterBar({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Iconsax.filter, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            'فلتر الفئة:',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.category,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableCategoryFilterBar extends StatelessWidget {
  final bool isLoadingCategories;
  final String? activeCategoryId;
  final List<CategoryEntity> categories;
  final ValueChanged<CategoryEntity?> onCategorySelected;

  const SelectableCategoryFilterBar({
    super.key,
    required this.isLoadingCategories,
    required this.activeCategoryId,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.filter, size: 14.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'اختر الفئة:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (isLoadingCategories) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChoiceChip(
                  label: 'كل الفئات',
                  isSelected: activeCategoryId == null,
                  onTap: () => onCategorySelected(null),
                ),
                for (final category in categories) ...[
                  SizedBox(width: 8.w),
                  _CategoryChoiceChip(
                    label: category.nameAr,
                    isSelected: activeCategoryId == category.id,
                    onTap: () => onCategorySelected(category),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Iconsax.category, size: 12.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsGridSection extends StatelessWidget {
  final ScrollController scrollController;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool Function(String productId) isProductFavorite;
  final void Function(ProductEntity product) onProductTap;
  final void Function(ProductEntity product) onToggleFavorite;

  const ProductsGridSection({
    super.key,
    required this.scrollController,
    required this.products,
    required this.isLoadingMore,
    required this.isProductFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('products-grid'),
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.60,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const ProductsLoadMoreIndicator();
        }

        final product = products[index];
        return ProductCard(
          id: product.id.toString(),
          name: product.name,
          nameAr: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          stockQuantity: product.stockQuantity,
          isFavorite: isProductFavorite(product.id),
          onTap: () => onProductTap(product),
          onToggleFavorite: () => onToggleFavorite(product),
        );
      },
    );
  }
}

class ProductsListSection extends StatelessWidget {
  final ScrollController scrollController;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool Function(String productId) isProductFavorite;
  final void Function(ProductEntity product) onProductTap;
  final void Function(ProductEntity product) onToggleFavorite;

  const ProductsListSection({
    super.key,
    required this.scrollController,
    required this.products,
    required this.isLoadingMore,
    required this.isProductFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('products-list'),
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const ProductsLoadMoreIndicator();
        }

        final product = products[index];
        return ProductListItem(
          id: product.id,
          title: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          isFavorite: isProductFavorite(product.id),
          onTap: () => onProductTap(product),
          onToggleFavorite: () => onToggleFavorite(product),
        );
      },
    );
  }
}

class ProductsEmptyState extends StatelessWidget {
  final bool isStrictCategoryDeviceFlow;

  const ProductsEmptyState({
    super.key,
    required this.isStrictCategoryDeviceFlow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      key: const ValueKey('products-empty-state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_1,
              size: 80.sp,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isStrictCategoryDeviceFlow
                  ? 'لا توجد منتجات لهذا الجهاز ضمن الفئة المختارة'
                  : 'لا توجد منتجات حالياً',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ProductsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      key: const ValueKey('products-error-state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 72.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'تعذر تحميل المنتجات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تحقق من الاتصال ثم أعد المحاولة.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsSortSheet extends StatelessWidget {
  final String activeSortBy;
  final String activeSortOrder;
  final void Function(String sortBy, String sortOrder) onSortSelected;

  const ProductsSortSheet({
    super.key,
    required this.activeSortBy,
    required this.activeSortOrder,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ترتيب حسب',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          _ProductsSortOptionTile(
            label: 'الأحدث',
            isSelected:
                activeSortBy == 'createdAt' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('createdAt', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الأقدم',
            isSelected: activeSortBy == 'createdAt' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('createdAt', 'asc'),
          ),
          _ProductsSortOptionTile(
            label: 'السعر: من الأقل للأعلى',
            isSelected: activeSortBy == 'price' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('price', 'asc'),
          ),
          _ProductsSortOptionTile(
            label: 'السعر: من الأعلى للأقل',
            isSelected: activeSortBy == 'price' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('price', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الأكثر مبيعاً',
            isSelected:
                activeSortBy == 'salesCount' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('salesCount', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الاسم: أ-ي',
            isSelected: activeSortBy == 'name' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('name', 'asc'),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _ProductsSortOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ProductsSortOptionTile({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
        color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}

class ProductsFilterSheet extends StatelessWidget {
  final bool hasCategoryFilter;
  final String activeCategoryName;
  final String activeSortLabel;
  final VoidCallback onClose;

  const ProductsFilterSheet({
    super.key,
    required this.hasCategoryFilter,
    required this.activeCategoryName,
    required this.activeSortLabel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: onClose,
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (hasCategoryFilter) ...[
            Text(
              'الفئة المطبقة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.category, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      activeCategoryName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
          Text(
            'الترتيب الحالي',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              activeSortLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              child: Text('تم', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsLoadMoreIndicator extends StatelessWidget {
  const ProductsLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SizedBox(
            width: 26.w,
            height: 26.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
