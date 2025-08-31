import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/prayer_times_model.dart';
import '../view_model/notification_settings_provider.dart';

class HomeScreenUtils {
  // Responsive font size calculation
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) {
      return baseFontSize * 0.85;
    } else if (screenHeight < 750) {
      return baseFontSize * 0.95;
    } else {
      return baseFontSize;
    }
  }

  // Responsive icon size calculation
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) {
      return baseSize * 0.8;
    } else if (screenHeight < 750) {
      return baseSize * 0.9;
    } else {
      return baseSize;
    }
  }

  // Bottom container height calculation
  static double getBottomContainerHeight(
    double screenHeight,
    bool showBannerAd,
  ) {
    double baseHeight;

    if (screenHeight < 600) {
      baseHeight = screenHeight * 0.50;
    } else if (screenHeight < 750) {
      baseHeight = screenHeight * 0.53;
    } else {
      baseHeight = screenHeight * 0.55;
    }

    final minHeight = showBannerAd ? 200.0 : 150.0;
    return baseHeight < minHeight ? minHeight : baseHeight;
  }

  // Wait for settings to load properly
  static Future<void> waitForSettingsToLoad() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Schedule notifications with proper settings check
  static Future<bool> scheduleNotifications({
    required WidgetRef ref,
    required PrayerTimesModel prayerTimes,
    required bool settingsLoaded,
  }) async {
    if (!settingsLoaded) {
      print('Settings not loaded yet, skipping notification scheduling');
      return false;
    }

    try {
      // Get current notification settings
      final notificationSettings = ref.read(notificationSettingsProvider);

      print('📱 Current notification settings:');
      print('   Prayer: ${notificationSettings.prayerNotificationsEnabled}');
      print('   Dua: ${notificationSettings.duaNotificationsEnabled}');

      // Handle prayer notifications
      if (notificationSettings.prayerNotificationsEnabled) {
        final prayerTimesMap = {
          'fajr': prayerTimes.fajr,
          'dhuhr': prayerTimes.dhuhr,
          'asr': prayerTimes.asr,
          'maghrib': prayerTimes.maghrib,
          'isha': prayerTimes.isha,
        };

        await NotificationService.schedulePrayerNotifications(prayerTimesMap);
        print('Prayer notifications scheduled successfully');
      } else {
        await NotificationService.cancelPrayerNotifications();
        print('Prayer notifications are disabled - cancelled existing ones');
      }

      // Handle dua notifications
      if (notificationSettings.duaNotificationsEnabled) {
        await NotificationService.scheduleDailyDuas();
        print('Dua notifications scheduled successfully');
      } else {
        await NotificationService.cancelDuaNotifications();
        print('Dua notifications are disabled - cancelled existing ones');
      }

      await NotificationService.getPendingNotifications();
      return true;
    } catch (e) {
      print('Error scheduling notifications: $e');
      return false;
    }
  }

  // Get localized Hijri date
  static String getLocalizedHijriDate(String hijriDate) {
    // Add your hijri date localization logic here
    return hijriDate;
  }
}
