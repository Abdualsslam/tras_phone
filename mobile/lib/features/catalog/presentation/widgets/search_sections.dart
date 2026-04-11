import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';

class SearchFieldBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchFieldBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج أو قطعة',
          hintStyle: TextStyle(
            color: AppColors.textTertiaryLight,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: AppColors.textTertiaryLight,
            size: 20.sp,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Iconsax.close_circle5,
                    color: AppColors.textTertiaryLight,
                    size: 20.sp,
                  ),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

class SearchInitialContent extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> popularTags;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onQueryTap;

  const SearchInitialContent({
    super.key,
    required this.recentSearches,
    required this.popularTags,
    required this.onClearRecent,
    required this.onQueryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عمليات البحث الأخيرة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onClearRecent,
                  child: Text(
                    'مسح الكل',
                    style: TextStyle(
                      color: AppColors.textTertiaryLight,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: recentSearches
                  .map(
                    (search) => SearchHistoryChip(
                      query: search,
                      onTap: () => onQueryTap(search),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 32.h),
          ],
          if (popularTags.isNotEmpty) ...[
            Text(
              'التاجات الشائعة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: popularTags
                  .map(
                    (tag) => SearchTagChip(
                      label: tag,
                      icon: Iconsax.tag,
                      highlighted: true,
                      onTap: () => onQueryTap(tag),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 32.h),
          ],
          Text(
            'بحث شائع',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                const [
                      'شاشات آيفون',
                      'بطاريات سامسونج',
                      'كابلات شحن',
                      'سماعات',
                      'حافظات جوال',
                      'قطع غيار هواوي',
                    ]
                    .map(
                      (search) => SearchTagChip(
                        label: search,
                        icon: Iconsax.search_normal,
                        highlighted: false,
                      ),
                    )
                    .toList()
                    .cast<Widget>()
                    .map(
                      (widget) => _WireTapSearchChip(
                        widget: widget,
                        onQueryTap: onQueryTap,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const SearchHistoryChip({
    super.key,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.clock,
              size: 16.sp,
              color: AppColors.textTertiaryLight,
            ),
            SizedBox(width: 8.w),
            Text(query, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class SearchTagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback? onTap;

  const SearchTagChip({
    super.key,
    required this.label,
    required this.icon,
    required this.highlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: highlighted
              ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1))
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: highlighted
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchAutocompleteOverlay extends StatelessWidget {
  final List<String> suggestions;
  final bool isDark;
  final ValueChanged<String> onSuggestionTap;

  const SearchAutocompleteOverlay({
    super.key,
    required this.suggestions,
    required this.isDark,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions
              .map(
                (suggestion) => InkWell(
                  onTap: () => onSuggestionTap(suggestion),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 18.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class SearchResultsView extends StatelessWidget {
  final List<ProductEntity> products;
  final bool Function(String productId) isFavorite;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<ProductEntity> onProductTap;
  final ValueChanged<ProductEntity> onAddToCart;

  const SearchResultsView({
    super.key,
    required this.products,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return const SearchEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            '${products.length} نتيجة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
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
                onToggleFavorite: () => onToggleFavorite(product.id),
                onAddToCart: () => onAddToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نتائج',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جرّب البحث بكلمات مختلفة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _WireTapSearchChip extends StatelessWidget {
  final Widget widget;
  final ValueChanged<String> onQueryTap;

  const _WireTapSearchChip({required this.widget, required this.onQueryTap});

  @override
  Widget build(BuildContext context) {
    final chip = widget as SearchTagChip;
    return SearchTagChip(
      label: chip.label,
      icon: chip.icon,
      highlighted: chip.highlighted,
      onTap: () => onQueryTap(chip.label),
    );
  }
}
