/// Notification Details Screen - View single notification
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../domain/enums/notification_enums.dart';
import '../cubit/notifications_cubit.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailsScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  NotificationModel? _notification;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = getIt<NotificationsRepository>();
      final result = await repository.getNotificationById(widget.notificationId);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (notification) {
          setState(() {
            _notification = notification;
            _isLoading = false;
          });

          // Mark as read if not already read
          if (!notification.isRead) {
            context.read<NotificationsCubit>().markAsRead(notification.id);
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإشعار'),
        actions: [
          if (_notification != null)
            IconButton(
              onPressed: () => _deleteNotification(context),
              icon: Icon(Iconsax.trash, size: 22.sp, color: AppColors.error),
            ),
        ],
      ),
      body: _isLoading
          ? const NotificationDetailsShimmer()
          : _errorMessage != null
              ? _buildErrorState(context, isDark)
              : _notification == null
                  ? _buildEmptyState(context, isDark)
                  : _buildNotificationContent(context, isDark, locale),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? 'فشل تحميل الإشعار',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadNotification,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification_bing,
            size: 64.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'الإشعار غير موجود',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context, bool isDark, String locale) {
    final notification = _notification!;
    final category = notification.categoryEnum;
    final iconData = category.icon;
    final iconColor = category.color;

    return Padding(
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
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 28.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayNameAr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDateTime(notification.createdAt),
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
            notification.getTitle(locale),
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),

          // Image if available
          if (notification.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                notification.image!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Body
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              notification.getBody(locale),
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
          if (notification.hasAction)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleAction(context, notification),
                child: Text(
                  _getActionButtonText(notification.actionTypeEnum),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';

    // Format: DD/MM/YYYY HH:MM
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getActionButtonText(NotificationActionType? actionType) {
    switch (actionType) {
      case NotificationActionType.order:
        return 'عرض الطلب';
      case NotificationActionType.product:
        return 'عرض المنتج';
      case NotificationActionType.promotion:
        return 'عرض العرض';
      case NotificationActionType.url:
        return 'فتح الرابط';
      case null:
        return 'عرض التفاصيل';
    }
  }

  void _handleAction(BuildContext context, NotificationModel notification) {
    if (!notification.hasAction) return;

    final actionType = notification.actionTypeEnum;
    final actionId = notification.actionId;
    final actionUrl = notification.actionUrl;

    switch (actionType) {
      case NotificationActionType.order:
        if (actionId != null) {
          context.push('/orders/$actionId');
        }
        break;
      case NotificationActionType.product:
        if (actionId != null) {
          context.push('/products/$actionId');
        }
        break;
      case NotificationActionType.promotion:
        if (actionId != null) {
          context.push('/promotions/$actionId');
        }
        break;
      case NotificationActionType.url:
        if (actionUrl != null) {
          launchUrl(Uri.parse(actionUrl), mode: LaunchMode.externalApplication);
        }
        break;
      case null:
        break;
    }
  }

  void _deleteNotification(BuildContext context) {
    if (_notification == null) return;

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
              context.read<NotificationsCubit>().deleteNotification(_notification!.id);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الإشعار')),
              );
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
