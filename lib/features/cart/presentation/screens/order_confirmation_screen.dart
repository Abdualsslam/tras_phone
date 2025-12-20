/// Order Confirmation Screen - Success screen after placing order
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String? orderNumber;

  const OrderConfirmationScreen({super.key, this.orderNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              const Spacer(),
              // Success Animation
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.tick_circle5,
                  size: 60.sp,
                  color: AppColors.success,
                ),
              ),
              SizedBox(height: 32.h),

              Text(
                'تم تأكيد طلبك بنجاح!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Text(
                'شكراً لك على ثقتك بنا',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Order Number Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'رقم الطلب',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      orderNumber ?? 'ORD-2024-005',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: AppColors.dividerLight),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoItem(theme, 'الإجمالي', '1,242.5 ر.س'),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: AppColors.dividerLight,
                        ),
                        _buildInfoItem(theme, 'التوصيل المتوقع', '3-5 أيام'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Info Message
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.blue, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'سيتم إرسال تفاصيل الطلب إلى رقم جوالك',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('متابعة التسوق'),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('تتبع الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
