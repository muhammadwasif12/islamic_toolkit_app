import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0) {
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('tasbeeh_counter') ?? 0;
  }

  Future<void> increment() async {
    if (state < 99) {
      state++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbeeh_counter', state);
    }
  }

  Future<void> reset() async {
    state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_counter', 0);
  }
}
