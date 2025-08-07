// lib/views/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/views/settings_language_screen.dart';
import 'package:islamic_toolkit_app/views/settings_notification_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/build_setting_items.dart';
import '../view_model/time_format_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final is24Hour = ref.watch(use24HourFormatProvider);

    return Scaffold(
      appBar: CustomAppBar(title: 'settings'.tr()),
      backgroundColor: const Color(0xffFDFCF7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Language Setting
            SettingItem(
              title: 'choose_language'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Notifications Setting
            SettingItem(
              title: 'notifications'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Purchase App Setting
            SettingItem(
              title: 'purchase_app'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('purchase_feature_coming_soon'.tr()),
                    backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Time Format Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(62, 180, 137, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: const Color.fromRGBO(62, 180, 137, 1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          is24Hour
                              ? 'hour_format_24'.tr()
                              : 'hour_format_12'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: is24Hour,
                    onChanged: (val) {
                      ref.read(use24HourFormatProvider.notifier).toggleFormat();
                    },
                    activeColor: const Color.fromRGBO(62, 180, 137, 1),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
