import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// Error Widget
class NotificationErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NotificationErrorWidget({Key? key, required this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Error loading notifications".tr(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
              foregroundColor: Colors.white,
            ),
            child: Text("Retry".tr()),
          ),
        ],
      ),
    );
  }
}
