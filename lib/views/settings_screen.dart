import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/views/settings_language_screen.dart';
import 'package:islamic_toolkit_app/views/settings_notification_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/build_setting_items.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'settings'.tr()),
      backgroundColor: const Color(0xffFDFCF7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

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
          ],
        ),
      ),
    );
  }
}
