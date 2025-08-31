// views/notification_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../view_model/notification_history_provider.dart';
import '../services/fcm_service.dart';
import '../widgets/notification_card_widget.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_error_widget.dart';
import '../utils/notification_handlers.dart';
import '../utils/notification_date_utils.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Set FCM context for popup handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService.setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationHistoryNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(62, 180, 137, 1),
                    Color.fromRGBO(81, 187, 149, 1),
                  ],
                ),
              ),
            ),
            title:  Text(
              "Notifications".tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'clear_all') {
                      _showClearAllDialog();
                    } else if (value == 'mark_all_read') {
                      _markAllAsRead();
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.done_all,
                                size: 20,
                                color: Color.fromRGBO(62, 180, 137, 1),
                              ),
                              const SizedBox(width: 8),
                              Text("Mark All Read".tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(
                                Icons.clear_all,
                                size: 20,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text("Clear All".tr()),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) => _buildNotificationsList(notifications),
        loading:
            () => const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(62, 180, 137, 1),
              ),
            ),
        error:
            (error, stack) => NotificationErrorWidget(
              onRetry: () => ref.refresh(notificationHistoryNotifierProvider),
            ),
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return NotificationEmptyState();
    }

    // Use the utility function to group notifications by date
    Map<String, List<Map<String, dynamic>>> groupedNotifications =
        NotificationDateUtils.groupNotificationsByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        String dateKey = groupedNotifications.keys.elementAt(index);
        List<Map<String, dynamic>> dayNotifications =
            groupedNotifications[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(62, 180, 137, 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromRGBO(62, 180, 137, 0.3),
                      ),
                    ),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(62, 180, 137, 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            // Notifications for this date - Using reusable widget
            ...dayNotifications
                .map(
                  (notification) => NotificationCardWidget(
                    notification: notification,
                    onTap: () => _handleNotificationTap(notification),
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    NotificationHandlers.handleNotificationTap(
      context: context,
      notification: notification,
      onMarkAsRead: () {
        ref
            .read(notificationHistoryNotifierProvider.notifier)
            .markAsRead(notification['id']);
        ref.refresh(unreadNotificationCountProvider);
      },
    );
  }

  void _markAllAsRead() async {
    final notifications =
        ref.read(notificationHistoryNotifierProvider).value ?? [];
    for (var notification in notifications) {
      if (!(notification['isRead'] ?? false)) {
        await ref
            .read(notificationHistoryNotifierProvider.notifier)
            .markAsRead(notification['id']);
      }
    }
    ref.refresh(unreadNotificationCountProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All notifications marked as read".tr()),
        backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("Clear All Notifications".tr()),
            content: Text(
              "Are you sure you want to clear all notifications? This action cannot be undone."
                  .tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel".tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(notificationHistoryNotifierProvider.notifier)
                      .clearAllNotifications();
                  ref.refresh(unreadNotificationCountProvider);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("All notifications cleared".tr()),
                      backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Clear All".tr()),
              ),
            ],
          ),
    );
  }
}
