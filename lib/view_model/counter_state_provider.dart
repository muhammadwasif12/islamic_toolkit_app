import 'package:flutter_riverpod/flutter_riverpod.dart';


final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});


class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() {
    if (state < 99) {
      state++;
    }
  }

  void reset() {
    state = 0;
  }
}