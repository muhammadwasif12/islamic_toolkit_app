import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            "qibla_direction".tr(),
            "update_qibla_direction".tr(),
          ),
          const SizedBox(height: 16),
          _notificationTile("tasbeeh".tr(), "complete_tasbeeh".tr()),
        ],
      ),
    );
  }

  Widget _notificationTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
