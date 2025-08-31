// widgets/notification_card_widget.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/notification_type_utils.dart';

// Reusable Notification Card Widget
class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRead = notification['isRead'] ?? false;
    DateTime timestamp = DateTime.parse(notification['timestamp']);
    String formattedTime = DateFormat('h:mm a').format(timestamp);

    // Use the utility function to get notification type data
    NotificationTypeData typeData =
        NotificationTypeUtils.getNotificationTypeData(notification);

    Color cardColor =
        isRead ? Colors.white : typeData.accentColor.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isRead
                  ? Colors.grey.shade200
                  : typeData.accentColor.withOpacity(0.3),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isRead
                    ? Colors.grey.withOpacity(0.1)
                    : typeData.accentColor.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: isRead ? 2 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeData.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: typeData.accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child:
              typeData.assetIcon != null
                  ? Image.asset(
                    typeData.assetIcon!,
                    width: 24,
                    height: 24,
                    color: typeData.accentColor,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.star_outline,
                          color: typeData.accentColor,
                          size: 24,
                        ),
                  )
                  : Icon(
                    typeData.leadingIcon,
                    color: typeData.accentColor,
                    size: 24,
                  ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'] ?? 'Notification',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: typeData.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: typeData.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                typeData.typeLabel,
                style: TextStyle(
                  color: typeData.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['body'] ?? '',
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.3,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (!isRead)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: typeData.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "New".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
