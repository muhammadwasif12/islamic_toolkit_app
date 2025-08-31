import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../view_model/notification_settings_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70),
              bottomLeft: Radius.circular(70),
            ),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "notification".tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xffFDFCF7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _notificationTile(
            context: context,
            ref: ref,
            title: "prayer_notifications".tr(),
            subtitle: "receive_notifications_before_prayer_times".tr(),
            isEnabled: notificationSettings.prayerNotificationsEnabled,
            onToggle: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .togglePrayerNotifications(value);
            },
            icon: Icons.mosque,
            iconColor: const Color.fromRGBO(62, 180, 137, 1),
          ),
          const SizedBox(height: 16),
          _notificationTile(
            context: context,
            ref: ref,
            title: "daily_dua_notifications".tr(),
            subtitle: "receive_random_duas_throughout_the_day".tr(),
            isEnabled: notificationSettings.duaNotificationsEnabled,
            onToggle: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleDuaNotifications(value);
            },
            icon: Icons.menu_book,
            iconColor: Colors.amber[700]!,
          ),
        ],
      ),
    );
  }

  Widget _notificationTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Function(bool) onToggle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Toggle Switch
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: const Color.fromRGBO(62, 180, 137, 1),
              activeTrackColor: const Color.fromRGBO(62, 180, 137, 0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
