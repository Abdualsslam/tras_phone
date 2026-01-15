/// Notification Tile Widget - Displays a single notification item
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../domain/enums/notification_enums.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String locale;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.locale = 'ar',
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = notification.categoryEnum;
    final iconData = _getIconForCategory(category);
    final iconColor = category.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: onDismiss != null ? (_) => onDismiss!() : null,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        color: Colors.red,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withValues(alpha: 0.05),
        child: ListTile(
          leading: _buildLeadingIcon(iconData, iconColor),
          title: Text(
            notification.getTitle(locale),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                notification.getBody(locale),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                _formatTime(notification.createdAt),
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
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(IconData icon, Color color) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }

  IconData _getIconForCategory(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.order:
        return Iconsax.box;
      case NotificationCategory.payment:
        return Iconsax.wallet;
      case NotificationCategory.promotion:
        return Iconsax.discount_shape;
      case NotificationCategory.system:
        return Iconsax.setting_2;
      case NotificationCategory.account:
        return Iconsax.user;
      case NotificationCategory.support:
        return Iconsax.message_question;
      case NotificationCategory.marketing:
        return Iconsax.speaker;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${time.day}/${time.month}/${time.year}';
  }
}
