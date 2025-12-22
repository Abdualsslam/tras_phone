/// Order Tracking Screen - Track shipment progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackingEvents = [
      _TrackingEvent(
        status: 'تم التسليم',
        description: 'تم تسليم الطلب بنجاح',
        location: 'الرياض - حي الملز',
        timestamp: DateTime.now(),
        isCompleted: false,
      ),
      _TrackingEvent(
        status: 'في الطريق للتوصيل',
        description: 'الطلب مع مندوب التوصيل',
        location: 'الرياض',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isCompleted: true,
      ),
      _TrackingEvent(
        status: 'وصل إلى المستودع',
        description: 'الطلب في مستودع التوزيع',
        location: 'الرياض - المنطقة الصناعية',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isCompleted: true,
      ),
      _TrackingEvent(
        status: 'تم الشحن',
        description: 'الطلب في الطريق إلى مدينتك',
        location: 'جدة',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: true,
      ),
      _TrackingEvent(
        status: 'قيد التجهيز',
        description: 'جاري تجهيز طلبك',
        location: 'المستودع الرئيسي',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تتبع الشحنة'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Order Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.truck_fast, size: 48.sp, color: Colors.white),
                  SizedBox(height: 12.h),
                  Text(
                    'في الطريق إليك',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    orderNumber,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'التوصيل المتوقع: اليوم',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Tracking Timeline
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الشحنة',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...trackingEvents.asMap().entries.map((entry) {
                    final isLast = entry.key == trackingEvents.length - 1;
                    return _buildTrackingItem(theme, entry.value, isLast);
                  }),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Contact Delivery
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.call),
                label: const Text('اتصل بمندوب التوصيل'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingItem(
    ThemeData theme,
    _TrackingEvent event,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: event.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: event.isCompleted
                  ? Icon(Iconsax.tick_circle5, size: 16.sp, color: Colors.white)
                  : Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                color: event.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  event.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 12.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Iconsax.clock,
                      size: 12.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTime(event.timestamp),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _TrackingEvent {
  final String status;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isCompleted;

  _TrackingEvent({
    required this.status,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.isCompleted,
  });
}
