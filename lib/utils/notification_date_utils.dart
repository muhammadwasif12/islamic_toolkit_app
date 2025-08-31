import 'package:easy_localization/easy_localization.dart';

class NotificationDateUtils {
  static Map<String, List<Map<String, dynamic>>> groupNotificationsByDate(
    List<Map<String, dynamic>> notifications,
  ) {
    Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var notification in notifications) {
      DateTime notificationDate = DateTime.parse(notification['timestamp']);
      DateTime notificationDay = DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
      );

      String dateKey;
      if (notificationDay == today) {
        dateKey = "Today".tr();
      } else if (notificationDay == today.subtract(const Duration(days: 1))) {
        dateKey = "Yesterday".tr();
      } else {
        dateKey = DateFormat('MMM dd, yyyy').format(notificationDate);
      }

      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }

    return groupedNotifications;
  }
}
