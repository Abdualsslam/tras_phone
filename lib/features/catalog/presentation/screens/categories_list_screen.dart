/// Categories List Screen - Displays all product categories
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/datasources/catalog_mock_datasource.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final _dataSource = CatalogMockDataSource();
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dataSource.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الفئات'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryCard(
                    category: category,
                    isDark: isDark,
                    onTap: () {
                      // Navigate to products by category
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Icon/Image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: category.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        category.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Iconsax.category,
                          size: 40.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Iconsax.category,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
            ),
            SizedBox(height: 16.h),

            // Category Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category.nameAr ?? category.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Products Count
            if (category.productsCount != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  '${category.productsCount} منتج',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
