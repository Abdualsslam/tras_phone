/// Pending Reviews Screen - Products awaiting review
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class PendingReviewsScreen extends StatelessWidget {
  const PendingReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock pending reviews
    final pendingProducts = [
      {'id': '1', 'name': 'شاشة آيفون 15 برو ماكس', 'image': 'assets/images/products/screen_1.jpg', 'orderDate': '15 ديسمبر 2024'},
      {'id': '2', 'name': 'بطارية آيفون 13', 'image': 'assets/images/products/bettary_1.jpg', 'orderDate': '10 ديسمبر 2024'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('بانتظار التقييم')),
      body: pendingProducts.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: pendingProducts.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final product = pendingProducts[index];
                return _buildProductCard(context, product, isDark);
              },
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
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
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              product['image']!,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80.w,
                height: 80.w,
                color: AppColors.backgroundLight,
                child: Icon(Iconsax.image, size: 30.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'تم الشراء: ${product['orderDate']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/write-review/${product['id']}'),
                    icon: Icon(Iconsax.star, size: 18.sp),
                    label: Text('كتابة تقييم', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.star,
            size: 80.sp,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد منتجات بانتظار التقييم',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر المنتجات هنا بعد استلام طلباتك',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
