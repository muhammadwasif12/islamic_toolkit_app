import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

// State for notification settings
class NotificationSettings {
  final bool prayerNotificationsEnabled;
  final bool duaNotificationsEnabled;

  const NotificationSettings({
    required this.prayerNotificationsEnabled,
    required this.duaNotificationsEnabled,
  });

  NotificationSettings copyWith({
    bool? prayerNotificationsEnabled,
    bool? duaNotificationsEnabled,
  }) {
    return NotificationSettings(
      prayerNotificationsEnabled:
          prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      duaNotificationsEnabled:
          duaNotificationsEnabled ?? this.duaNotificationsEnabled,
    );
  }
}

// Notifier for notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const String _prayerNotificationKey = 'prayer_notifications_enabled';
  static const String _duaNotificationKey = 'dua_notifications_enabled';

  NotificationSettingsNotifier()
    : super(
        const NotificationSettings(
          prayerNotificationsEnabled: true,
          duaNotificationsEnabled: true,
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayerEnabled = prefs.getBool(_prayerNotificationKey) ?? true;
      final duaEnabled = prefs.getBool(_duaNotificationKey) ?? true;

      state = NotificationSettings(
        prayerNotificationsEnabled: prayerEnabled,
        duaNotificationsEnabled: duaEnabled,
      );

      print(
        '📱 Notification settings loaded: Prayer=$prayerEnabled, Dua=$duaEnabled',
      );
    } catch (e) {
      print('❌ Error loading notification settings: $e');
    }
  }

  Future<void> togglePrayerNotifications(bool enabled) async {
    try {
      // First cancel any existing notifications
      await NotificationService.cancelPrayerNotifications();

      // Then update preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prayerNotificationKey, enabled);

      // Update state
      state = state.copyWith(prayerNotificationsEnabled: enabled);

      if (enabled) {
        print(
          '🔔 Prayer notifications enabled - will be scheduled with next prayer times update',
        );
        // Don't schedule here - let HomeScreen handle it with proper prayer times
      } else {
        print('🔕 Prayer notifications disabled and cancelled immediately');
      }

      // Show current pending notifications for debugging
      await NotificationService.getPendingNotifications();
    } catch (e) {
      print('❌ Error toggling prayer notifications: $e');
    }
  }

  Future<void> toggleDuaNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_duaNotificationKey, enabled);

      state = state.copyWith(duaNotificationsEnabled: enabled);

      // 🔥 IMMEDIATELY cancel or schedule notifications
      if (!enabled) {
        await NotificationService.cancelDuaNotifications();
        print('🔕 Dua notifications disabled and cancelled immediately');
      } else {
        await NotificationService.scheduleDailyDuas();
        print('🔔 Dua notifications enabled and scheduled immediately');
      }

      // Show current pending notifications for debugging
      await NotificationService.getPendingNotifications();
    } catch (e) {
      print('❌ Error toggling dua notifications: $e');
    }
  }

  // Check if prayer notifications are enabled
  bool get isPrayerNotificationsEnabled => state.prayerNotificationsEnabled;

  // Check if dua notifications are enabled
  bool get isDuaNotificationsEnabled => state.duaNotificationsEnabled;
}

// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier();
    });
