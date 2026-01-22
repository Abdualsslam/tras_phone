import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

/// Notification button widget that displays unread count badge
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if NotificationsCubit provider is available
    try {
      // Try to access the provider to see if it exists
      final cubit = context.read<NotificationsCubit>();

      return BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          int unreadCount = 0;
          if (state is NotificationsLoaded) {
            unreadCount = state.unreadCount;
          } else {
            // Load unread count if not already loaded
            Future.microtask(() {
              try {
                cubit.getUnreadCount();
              } catch (e) {
                debugPrint('Error loading unread count: $e');
              }
            });
          }

          return NotificationBadge(
            count: unreadCount,
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(Iconsax.notification, size: 24.sp),
            ),
          );
        },
      );
    } catch (e) {
      // Provider not available - show button without badge
      debugPrint('NotificationsCubit provider not available: $e');
      debugPrint(
        'This usually means the app needs a full restart (not hot reload)',
      );
      return IconButton(
        onPressed: () => context.push('/notifications'),
        icon: Icon(Iconsax.notification, size: 24.sp),
      );
    }
  }
}
