// Notifications States - State classes for NotificationsCubit

import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';
import '../../domain/enums/notification_enums.dart';

/// Base state for notifications
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Loading state
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Loaded state with notifications data
class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final NotificationCategory? filterCategory;
  final bool? filterIsRead;

  const NotificationsLoaded({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.filterCategory,
    this.filterIsRead,
  });

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    int? total,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    NotificationCategory? filterCategory,
    bool? filterIsRead,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterCategory: filterCategory ?? this.filterCategory,
      filterIsRead: filterIsRead ?? this.filterIsRead,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        total,
        unreadCount,
        currentPage,
        hasMore,
        isLoadingMore,
        filterCategory,
        filterIsRead,
      ];
}

/// Error state
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
