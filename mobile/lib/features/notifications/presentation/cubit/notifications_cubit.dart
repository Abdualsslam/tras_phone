/// Notifications Cubit - State management for notifications
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../domain/enums/notification_enums.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  static const int _pageSize = 20;

  NotificationsCubit({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsInitial());

  /// Load notifications
  Future<void> loadNotifications({
    NotificationCategory? category,
    bool? isRead,
    bool refresh = false,
  }) async {
    if (state is NotificationsLoading && !refresh) return;

    if (refresh || state is NotificationsInitial || state is NotificationsError) {
      emit(const NotificationsLoading());
    }

    developer.log(
      'Loading notifications (category: $category, isRead: $isRead)',
      name: 'NotificationsCubit',
    );

    final result = await _repository.getMyNotifications(
      page: 1,
      limit: _pageSize,
      category: category,
      isRead: isRead,
    );

    result.fold(
      (failure) {
        developer.log(
          'Failed to load notifications: ${failure.message}',
          name: 'NotificationsCubit',
        );
        emit(NotificationsError(message: failure.message));
      },
      (response) {
        emit(NotificationsLoaded(
          notifications: response.notifications,
          total: response.total,
          unreadCount: response.unreadCount,
          currentPage: 1,
          hasMore: response.notifications.length >= _pageSize,
          filterCategory: category,
          filterIsRead: isRead,
        ));
      },
    );
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    developer.log('Loading more notifications (page: $nextPage)', name: 'NotificationsCubit');

    final result = await _repository.getMyNotifications(
      page: nextPage,
      limit: _pageSize,
      category: currentState.filterCategory,
      isRead: currentState.filterIsRead,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        final allNotifications = [
          ...currentState.notifications,
          ...response.notifications,
        ];
        emit(currentState.copyWith(
          notifications: allNotifications,
          total: response.total,
          unreadCount: response.unreadCount,
          currentPage: nextPage,
          hasMore: response.notifications.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    developer.log('Marking notification as read: $notificationId', name: 'NotificationsCubit');

    final result = await _repository.markAsRead(notificationId);

    result.fold(
      (failure) {
        developer.log('Failed to mark as read: ${failure.message}', name: 'NotificationsCubit');
      },
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notificationId) {
              // Create updated notification with isRead = true
              return NotificationModel(
                id: n.id,
                customerId: n.customerId,
                category: n.category,
                title: n.title,
                titleAr: n.titleAr,
                body: n.body,
                bodyAr: n.bodyAr,
                image: n.image,
                actionType: n.actionType,
                actionId: n.actionId,
                actionUrl: n.actionUrl,
                referenceType: n.referenceType,
                referenceId: n.referenceId,
                isRead: true,
                readAt: DateTime.now(),
                isSent: n.isSent,
                sentAt: n.sentAt,
                createdAt: n.createdAt,
                updatedAt: n.updatedAt,
                data: n.data,
              );
            }
            return n;
          }).toList();

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: currentState.unreadCount > 0 
                ? currentState.unreadCount - 1 
                : 0,
          ));
        }
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    developer.log('Marking all notifications as read', name: 'NotificationsCubit');

    final result = await _repository.markAllAsRead();

    result.fold(
      (failure) {
        developer.log('Failed to mark all as read: ${failure.message}', name: 'NotificationsCubit');
      },
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            return NotificationModel(
              id: n.id,
              customerId: n.customerId,
              category: n.category,
              title: n.title,
              titleAr: n.titleAr,
              body: n.body,
              bodyAr: n.bodyAr,
              image: n.image,
              actionType: n.actionType,
              actionId: n.actionId,
              actionUrl: n.actionUrl,
              referenceType: n.referenceType,
              referenceId: n.referenceId,
              isRead: true,
              readAt: n.readAt ?? DateTime.now(),
              isSent: n.isSent,
              sentAt: n.sentAt,
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
              data: n.data,
            );
          }).toList();

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));
        }
      },
    );
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    developer.log('Deleting notification: $notificationId', name: 'NotificationsCubit');

    final result = await _repository.deleteNotification(notificationId);

    result.fold(
      (failure) {
        developer.log('Failed to delete: ${failure.message}', name: 'NotificationsCubit');
      },
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final notification = currentState.notifications.firstWhere(
            (n) => n.id == notificationId,
            orElse: () => currentState.notifications.first,
          );
          final wasUnread = !notification.isRead;

          final updatedNotifications = currentState.notifications
              .where((n) => n.id != notificationId)
              .toList();

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            total: currentState.total - 1,
            unreadCount: wasUnread && currentState.unreadCount > 0
                ? currentState.unreadCount - 1
                : currentState.unreadCount,
          ));
        }
      },
    );
  }

  /// Refresh notifications
  Future<void> refresh() async {
    final currentState = state;
    NotificationCategory? category;
    bool? isRead;

    if (currentState is NotificationsLoaded) {
      category = currentState.filterCategory;
      isRead = currentState.filterIsRead;
    }

    await loadNotifications(category: category, isRead: isRead, refresh: true);
  }

  /// Get unread count only
  Future<int> getUnreadCount() async {
    final result = await _repository.getUnreadCount();
    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  }
}
