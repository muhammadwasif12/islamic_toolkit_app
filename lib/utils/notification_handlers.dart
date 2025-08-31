// utils/notification_handlers.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/notification_popup_dialog.dart';

class NotificationHandlers {
  static void handleNotificationTap({
    required BuildContext context,
    required Map<String, dynamic> notification,
    required VoidCallback onMarkAsRead,
  }) {
    // Mark as read
    if (!(notification['isRead'] ?? false)) {
      onMarkAsRead();
    }

    // Get notification data
    Map<String, dynamic> data = notification['data'] ?? {};

    // Extract notification details
    String title = notification['title'] ?? 'Notification';
    String body = notification['body'] ?? '';

    // Check for isDua and isHadees flags
    bool isDua = data['isDua'] == 'true' || data['isDua'] == true;
    bool isHadees = data['isHadees'] == 'true' || data['isHadees'] == true;

    if (isDua) {
      _showDuaPopup(context, title, body, data);
    } else if (isHadees) {
      _showHadeesPopup(context, title, body, data);
    } else {
      _showGeneralNotificationPopup(context, title, body);
    }
  }

  static void _showDuaPopup(
    BuildContext context,
    String title,
    String body,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ContentPopupDialog(
            title: title,
            content: body,
            arabicText:
                data['arabic_text'] ?? data['arabic'] ?? data['arabicText'],
            transliteration: data['transliteration'],
            translation: data['translation'],
            type: 'dua',
          ),
    );
  }

  static void _showHadeesPopup(
    BuildContext context,
    String title,
    String body,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ContentPopupDialog(
            title: title,
            content: body,
            arabicText:
                data['arabic_text'] ?? data['arabic'] ?? data['arabicText'],
            transliteration: data['transliteration'],
            translation: data['translation'],
            type: 'hadees',
          ),
    );
  }

  static void _showGeneralNotificationPopup(
    BuildContext context,
    String title,
    String body,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGeneralPopupHeader(context, title),
                  _buildGeneralPopupContent(body),
                  _buildGeneralPopupButton(context),
                ],
              ),
            ),
          ),
    );
  }

  static Widget _buildGeneralPopupHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(62, 180, 137, 1),
            Color.fromRGBO(81, 187, 149, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGeneralPopupContent(String body) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildGeneralPopupButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text("OK".tr(), style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// Dialog utilities
class NotificationDialogs {
  static void showClearAllDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
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
                onPressed: onConfirm,
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

// Feedback utilities
class NotificationFeedback {
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
