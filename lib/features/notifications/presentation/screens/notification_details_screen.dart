/// Notification Details Screen - View single notification
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final String notificationId;

  const NotificationDetailsScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock notification
    final notification = {
      'id': notificationId,
      'type': 'order',
      'title': 'تحديث حالة الطلب',
      'body':
          'تم تأكيد طلبك #ORD-2024-0018 وجاري تجهيزه للشحن. سيتم إعلامك عند شحن الطلب.',
      'createdAt': '2024-12-20 10:30',
      'actionType': 'order_details',
      'actionData': {'orderId': 'ORD-2024-0018'},
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإشعار'),
        actions: [
          IconButton(
            onPressed: () => _deleteNotification(context),
            icon: Icon(Iconsax.trash, size: 22.sp, color: AppColors.error),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Type
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type'] as String),
                    size: 28.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(notification['type'] as String),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification['createdAt'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              notification['title'] as String,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),

            // Body
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                notification['body'] as String,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.8,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),

            const Spacer(),

            // Action Button
            if (notification['actionType'] != null)
              ElevatedButton(
                onPressed: () => _handleAction(context, notification),
                child: Text('عرض الطلب', style: TextStyle(fontSize: 16.sp)),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Iconsax.box;
      case 'promo':
        return Iconsax.discount_shape;
      case 'wallet':
        return Iconsax.wallet_3;
      case 'system':
        return Iconsax.notification;
      default:
        return Iconsax.notification;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'order':
        return 'طلبات';
      case 'promo':
        return 'عروض';
      case 'wallet':
        return 'محفظة';
      case 'system':
        return 'نظام';
      default:
        return 'إشعار';
    }
  }

  void _handleAction(BuildContext context, Map<String, dynamic> notification) {
    final actionType = notification['actionType'];
    if (actionType == 'order_details') {
      context.push('/order/${(notification['actionData'] as Map)['orderId']}');
    }
  }

  void _deleteNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإشعار'),
        content: const Text('هل تريد حذف هذا الإشعار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم حذف الإشعار')));
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
