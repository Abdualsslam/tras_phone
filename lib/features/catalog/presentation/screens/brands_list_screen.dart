/// Brands List Screen - Displays all product brands
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/brand_entity.dart';
import '../../data/datasources/catalog_mock_datasource.dart';

class BrandsListScreen extends StatefulWidget {
  const BrandsListScreen({super.key});

  @override
  State<BrandsListScreen> createState() => _BrandsListScreenState();
}

class _BrandsListScreenState extends State<BrandsListScreen> {
  final _dataSource = CatalogMockDataSource();
  List<BrandEntity> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final brands = await _dataSource.getBrands();
    setState(() {
      _brands = brands;
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
        title: const Text('العلامات التجارية'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBrands,
              child: GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: _brands.length,
                itemBuilder: (context, index) {
                  final brand = _brands[index];
                  return _BrandCard(
                    brand: brand,
                    isDark: isDark,
                    onTap: () {
                      // Navigate to products by brand
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isDark;
  final VoidCallback onTap;

  const _BrandCard({
    required this.brand,
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
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo
            Container(
              width: 60.w,
              height: 60.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.dividerLight, width: 1),
              ),
              child: brand.logo != null
                  ? Image.network(
                      brand.logo!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.tag,
                        size: 30.sp,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(Iconsax.tag, size: 30.sp, color: AppColors.primary),
            ),
            SizedBox(height: 12.h),

            // Brand Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                brand.nameAr ?? brand.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
