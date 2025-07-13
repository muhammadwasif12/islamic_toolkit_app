import 'package:flutter/material.dart';
import 'package:islamic_toolkit_app/views/settings_language_screen.dart';
import 'package:islamic_toolkit_app/views/settings_notification_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/build_setting_items.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xffFDFCF7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            SettingItem(
              title: 'Choose Language',
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
              title: 'Notifications',
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
              title: 'Purchase App',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Purchase feature coming soon!"),
                    backgroundColor: Color.fromRGBO(62, 180, 137, 1),
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
