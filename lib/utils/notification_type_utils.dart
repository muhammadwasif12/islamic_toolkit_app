import 'package:flutter/material.dart';

class NotificationTypeData {
  final Color accentColor;
  final IconData leadingIcon;
  final String? assetIcon;
  final String typeLabel;

  NotificationTypeData({
    required this.accentColor,
    required this.leadingIcon,
    this.assetIcon,
    required this.typeLabel,
  });
}

class NotificationTypeUtils {
  static NotificationTypeData getNotificationTypeData(
    Map<String, dynamic> notification,
  ) {
    // Check notification type from data
    Map<String, dynamic> data = notification['data'] ?? {};
    bool isDua = data['isDua'] == 'true' || data['isDua'] == true;
    bool isHadees = data['isHadees'] == 'true' || data['isHadees'] == true;

    if (isDua) {
      return NotificationTypeData(
        accentColor: const Color.fromRGBO(76, 175, 80, 1),
        leadingIcon: Icons.star_outline,
        assetIcon: 'assets/bottom_nav_images/dua1.png',
        typeLabel: "Dua",
      );
    } else if (isHadees) {
      return NotificationTypeData(
        accentColor: const Color.fromRGBO(33, 150, 243, 1),
        leadingIcon: Icons.book_outlined,
        assetIcon: null,
        typeLabel: "Hadees",
      );
    } else {
      return NotificationTypeData(
        accentColor: const Color.fromRGBO(62, 180, 137, 1),
        leadingIcon: Icons.notifications,
        assetIcon: null,
        typeLabel: "General",
      );
    }
  }
}
