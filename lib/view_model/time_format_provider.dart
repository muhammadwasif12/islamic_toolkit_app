import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final use24HourFormatProvider =
    StateNotifierProvider<TimeFormatNotifier, bool>((ref) {
  return TimeFormatNotifier();
});

class TimeFormatNotifier extends StateNotifier<bool> {
  static const _key = 'use_24_hour_format';

  TimeFormatNotifier() : super(true) {
    _loadFormat();
  }

  void _loadFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key);
    if (saved != null) {
      state = saved;
    }
  }

  void toggleFormat() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_key, state);
  }

  void setFormat(bool use24Hour) async {
    state = use24Hour;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_key, use24Hour);
  }
}
