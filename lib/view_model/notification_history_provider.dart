// view_model/notification_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fcm_service.dart';

// Stream provider for real-time notification updates
final notificationStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FCMService.getNotificationStream();
});

// Provider for notification history - now uses stream for real-time updates
final notificationHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Watch the stream to trigger rebuilds when notifications change
  ref.watch(notificationStreamProvider);
  return await FCMService.getStoredNotifications();
});

// Provider for unread notification count - also real-time
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  // Watch the stream to trigger rebuilds when notifications change
  ref.watch(notificationStreamProvider);
  return await FCMService.getUnreadCount();
});

// State notifier for managing notification actions
class NotificationHistoryNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;
  
  NotificationHistoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadNotifications();
    
    // Listen to FCM stream for real-time updates
    FCMService.getNotificationStream().listen((notifications) {
      state = AsyncValue.data(notifications);
    });
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await FCMService.getStoredNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await FCMService.markAsRead(notificationId);
      // Trigger refresh of providers
      ref.refresh(unreadNotificationCountProvider);
      await loadNotifications();
    } catch (error) {
      print('Error marking notification as read: $error');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final notifications = await FCMService.getStoredNotifications();
      for (var notification in notifications) {
        if (!(notification['isRead'] ?? false)) {
          await FCMService.markAsRead(notification['id']);
        }
      }
      // Trigger refresh of providers
      ref.refresh(unreadNotificationCountProvider);
      await loadNotifications();
    } catch (error) {
      print('Error marking all notifications as read: $error');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await FCMService.clearAllNotifications();
      // Trigger refresh of providers
      ref.refresh(unreadNotificationCountProvider);
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('Error clearing notifications: $error');
    }
  }

  void refresh() {
    loadNotifications();
    ref.refresh(unreadNotificationCountProvider);
  }
}

// Provider for notification history notifier
final notificationHistoryNotifierProvider =
    StateNotifierProvider<NotificationHistoryNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return NotificationHistoryNotifier(ref);
});

// Provider to trigger refresh when app becomes active
final appStateProvider = StateProvider<bool>((ref) => true);

// Provider that refreshes notifications when app state changes
final notificationRefreshProvider = Provider((ref) {
  ref.watch(appStateProvider);
  
  // Refresh all notification-related providers
  Future.microtask(() {
    ref.refresh(notificationHistoryProvider);
    ref.refresh(unreadNotificationCountProvider);
    ref.refresh(notificationHistoryNotifierProvider);
  });
  
  return null;
});