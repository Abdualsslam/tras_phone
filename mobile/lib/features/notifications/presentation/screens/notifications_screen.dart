/// Notifications Screen - User notifications list with real API
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/enums/notification_enums.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load notifications on init
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationsCubit>().markAllAsRead();
                  },
                  child: Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return _buildErrorState(context, theme, state.message);
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState(context, theme);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NotificationsCubit>().refresh(),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 72.w,
                  color: AppColors.dividerLight,
                ),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return Padding(
                      padding: EdgeInsets.all(16.w),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    locale: locale,
                    onTap: () => _handleNotificationTap(context, notification),
                    onDismiss: () {
                      context.read<NotificationsCubit>().deleteNotification(notification.id);
                    },
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
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
            AppLocalizations.of(context)!.noNotifications,
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

  Widget _buildErrorState(BuildContext context, ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 80.sp,
            color: Colors.red,
          ),
          SizedBox(height: 24.h),
          Text(
            'حدث خطأ',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationsCubit>().refresh();
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, notification) {
    // Mark as read if not already
    if (!notification.isRead) {
      context.read<NotificationsCubit>().markAsRead(notification.id);
    }

    // Navigate based on action type
    if (notification.hasAction) {
      switch (notification.actionTypeEnum) {
        case NotificationActionType.order:
          if (notification.actionId != null) {
            context.push('/orders/${notification.actionId}');
          }
          break;
        case NotificationActionType.product:
          if (notification.actionId != null) {
            context.push('/products/${notification.actionId}');
          }
          break;
        case NotificationActionType.promotion:
          if (notification.actionId != null) {
            context.push('/promotions/${notification.actionId}');
          }
          break;
        case NotificationActionType.url:
          // Handle URL action - could use url_launcher
          break;
        case null:
          break;
      }
    }
  }
}
