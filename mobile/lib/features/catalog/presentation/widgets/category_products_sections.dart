library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';

class CategoryProductsTopBar extends StatelessWidget {
  final int productsCount;
  final String sortLabel;
  final bool isGridView;
  final VoidCallback onSortTap;
  final VoidCallback onLayoutToggle;

  const CategoryProductsTopBar({
    super.key,
    required this.productsCount,
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
          Text(
            '$productsCount منتج',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSortTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.sort, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Text(
                    sortLabel,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                  ),
                ],
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

class CategoryProductsGridView extends StatelessWidget {
  final ScrollController controller;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool Function(String productId) isFavorite;
  final ValueChanged<ProductEntity> onProductTap;
  final ValueChanged<ProductEntity> onToggleFavorite;

  const CategoryProductsGridView({
    super.key,
    required this.controller,
    required this.products,
    required this.isLoadingMore,
    required this.isFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
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
          isFavorite: isFavorite(product.id),
          onTap: () => onProductTap(product),
          onToggleFavorite: () => onToggleFavorite(product),
        );
      },
    );
  }
}

class CategoryProductsListView extends StatelessWidget {
  final ScrollController controller;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final ValueChanged<ProductEntity> onProductTap;

  const CategoryProductsListView({
    super.key,
    required this.controller,
    required this.products,
    required this.isLoadingMore,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.all(16.w),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = products[index];
        return GestureDetector(
          onTap: () => onProductTap(product),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    (product.imageUrl ?? '').startsWith('assets/')
                        ? product.imageUrl ??
                              'assets/images/products/phone_screen.png'
                        : 'assets/images/products/phone_screen.png',
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, url, error) => Container(
                      width: 80.w,
                      height: 80.w,
                      color: AppColors.backgroundLight,
                      child: Icon(Iconsax.image, size: 30.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameAr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (product.originalPrice != null &&
                          product.originalPrice! > product.price) ...[
                        Text(
                          '${product.originalPrice!.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiaryLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      Text(
                        '${product.price.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_left_2,
                  size: 20.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryProductsEmptyState extends StatelessWidget {
  const CategoryProductsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
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
            'لا توجد منتجات في هذا القسم حالياً',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryProductsSortSheet extends StatelessWidget {
  final String currentSortBy;
  final String currentSortOrder;
  final void Function(String sortBy, String sortOrder) onSelect;

  const CategoryProductsSortSheet({
    super.key,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onSelect,
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
          CategoryProductsSortOption(
            label: 'الأحدث',
            isSelected:
                currentSortBy == 'createdAt' && currentSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSelect('createdAt', 'desc'),
          ),
          CategoryProductsSortOption(
            label: 'الأقدم',
            isSelected:
                currentSortBy == 'createdAt' && currentSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSelect('createdAt', 'asc'),
          ),
          CategoryProductsSortOption(
            label: 'السعر: من الأقل للأعلى',
            isSelected: currentSortBy == 'price' && currentSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSelect('price', 'asc'),
          ),
          CategoryProductsSortOption(
            label: 'السعر: من الأعلى للأقل',
            isSelected: currentSortBy == 'price' && currentSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSelect('price', 'desc'),
          ),
          CategoryProductsSortOption(
            label: 'الأكثر مبيعاً',
            isSelected:
                currentSortBy == 'ordersCount' && currentSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSelect('ordersCount', 'desc'),
          ),
          CategoryProductsSortOption(
            label: 'الاسم: أ-ي',
            isSelected: currentSortBy == 'name' && currentSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSelect('name', 'asc'),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class CategoryProductsSortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const CategoryProductsSortOption({
    super.key,
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

class CategoryProductsFilterSheet extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const CategoryProductsFilterSheet({
    super.key,
    required this.onReset,
    required this.onApply,
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
                onPressed: onReset,
                child: const Text(
                  'إعادة ضبط',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'نطاق السعر',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          RangeSlider(
            values: const RangeValues(0, 1000),
            min: 0,
            max: 2000,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (values) {},
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApply,
              child: Text('تطبيق', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
