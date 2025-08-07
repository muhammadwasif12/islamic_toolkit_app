// lib/view_model/timezone_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

final timeZoneProvider = StateNotifierProvider<TimeZoneNotifier, tz.Location>((ref) {
  return TimeZoneNotifier();
});

class TimeZoneNotifier extends StateNotifier<tz.Location> {
  static const _key = 'selected_timezone';

  TimeZoneNotifier() : super(tz.local) {
    _loadTimeZone();
  }

  void _loadTimeZone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimeZone = prefs.getString(_key);
    
    if (savedTimeZone != null) {
      try {
        state = tz.getLocation(savedTimeZone);
      } catch (e) {
        // If saved timezone is invalid, use local timezone
        state = tz.local;
        // Clean up invalid data
        prefs.remove(_key);
      }
    }
  }

  void setTimeZone(String timeZoneName) async {
    try {
      final newTimeZone = tz.getLocation(timeZoneName);
      state = newTimeZone;
      
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_key, timeZoneName);
    } catch (e) {
      // Handle invalid timezone
      print('Invalid timezone: $timeZoneName');
    }
  }

  void resetToLocal() async {
    state = tz.local;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }
}