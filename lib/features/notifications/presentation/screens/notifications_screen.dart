/// Notifications Screen - User notifications list
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final notifications = [
      _Notification(
        title: 'تم شحن طلبك',
        body: 'طلبك #ORD-2024-002 في الطريق إليك',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: _NotificationType.order,
        isRead: false,
      ),
      _Notification(
        title: 'عرض خاص 🎉',
        body: 'خصم 20% على جميع شاشات الآيفون لمدة 24 ساعة',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        type: _NotificationType.promotion,
        isRead: false,
      ),
      _Notification(
        title: 'تم تسليم طلبك',
        body: 'طلبك #ORD-2024-001 تم تسليمه بنجاح',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: _NotificationType.order,
        isRead: true,
      ),
      _Notification(
        title: 'رصيد جديد',
        body: 'تمت إضافة 500 ر.س إلى محفظتك',
        time: DateTime.now().subtract(const Duration(days: 2)),
        type: _NotificationType.wallet,
        isRead: true,
      ),
      _Notification(
        title: 'نقاط ولاء',
        body: 'حصلت على 25 نقطة من آخر طلب',
        time: DateTime.now().subtract(const Duration(days: 3)),
        type: _NotificationType.loyalty,
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('تحديد الكل كمقروء')),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72.w,
                color: AppColors.dividerLight,
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationItem(
                  notification: notification,
                  isDark: isDark,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification_bing,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد إشعارات',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر إشعاراتك هنا',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final _Notification notification;
  final bool isDark;

  const _NotificationItem({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case _NotificationType.order:
        icon = Iconsax.box;
        iconColor = AppColors.primary;
        break;
      case _NotificationType.promotion:
        icon = Iconsax.discount_shape;
        iconColor = Colors.red;
        break;
      case _NotificationType.wallet:
        icon = Iconsax.wallet;
        iconColor = AppColors.success;
        break;
      case _NotificationType.loyalty:
        icon = Iconsax.medal_star;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24.sp),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              notification.body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(notification.time),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        onTap: () {},
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _Notification {
  final String title;
  final String body;
  final DateTime time;
  final _NotificationType type;
  final bool isRead;

  _Notification({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

enum _NotificationType { order, promotion, wallet, loyalty }
