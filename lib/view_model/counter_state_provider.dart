import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier(ref);
});

final tasbeehCompletedProvider = StateProvider<bool>((ref) => false);

final completedTasbeehCountProvider =
    StateNotifierProvider<CompletedTasbeehNotifier, int>((ref) {
  return CompletedTasbeehNotifier();
});

// New provider for tasbeeh mode (33 or 99)
final tasbeehModeProvider = StateNotifierProvider<TasbeehModeNotifier, int>((ref) {
  return TasbeehModeNotifier();
});

// New provider to track first-time vibration check
final vibrationCheckedProvider = StateProvider<bool>((ref) => false);

class TasbeehModeNotifier extends StateNotifier<int> {
  TasbeehModeNotifier() : super(99) {
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('tasbeeh_mode') ?? 99;
  }

  // Updated setMode method to reset counter and completion status
  Future<void> setMode(int mode) async {
    if (mode == 33 || mode == 99) {
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbeeh_mode', mode);
    }
  }
}

class CompletedTasbeehNotifier extends StateNotifier<int> {
  CompletedTasbeehNotifier() : super(0) {
    _loadCompletedCount();
  }

  Future<void> _loadCompletedCount() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('completed_tasbeeh_count') ?? 0;
  }

  Future<void> increment() async {
    state++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completed_tasbeeh_count', state);
  }

  Future<void> reset() async {
    state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completed_tasbeeh_count', 0);
  }
}

class CounterNotifier extends StateNotifier<int> {
  final Ref ref;

  CounterNotifier(this.ref) : super(0) {
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('tasbeeh_counter') ?? 0;
  }

  // Enhanced vibration checker method
  Future<VibrationStatus> _checkVibrationStatus() async {
    try {
      // Check if device has vibrator hardware
      final hasVibrator = await Vibration.hasVibrator();
      
      if (hasVibrator == true) {
        // Test vibration to see if it actually works
        await Vibration.vibrate(duration: 50);
        return VibrationStatus.working;
      } else if (hasVibrator == false) {
        return VibrationStatus.noHardware;
      } else {
        return VibrationStatus.unknown;
      }
    } catch (e) {
      return VibrationStatus.disabled;
    }
  }

  Future<void> increment(WidgetRef widgetRef) async {
    final prefs = await SharedPreferences.getInstance();
    final currentMode = ref.read(tasbeehModeProvider);

    if (state >= currentMode) {
      state = 1;
      await prefs.setInt('tasbeeh_counter', state);
      ref.read(tasbeehCompletedProvider.notifier).state = false;
      await _performVibration(VibrationIntensity.normal);
      return;
    }

    state++;
    await prefs.setInt('tasbeeh_counter', state);

    if (state == currentMode) {
      ref.read(tasbeehCompletedProvider.notifier).state = true;
      await _performVibration(VibrationIntensity.strong);
      await ref.read(completedTasbeehCountProvider.notifier).increment();
    } else {
      await _performVibration(VibrationIntensity.normal);
    }
  }

  // Enhanced vibration method with multiple fallbacks
  Future<void> _performVibration(VibrationIntensity intensity) async {
    try {
      // Method 1: Try Vibration package first
      final hasVibrator = await Vibration.hasVibrator();
      
      if (hasVibrator == true) {
        switch (intensity) {
          case VibrationIntensity.normal:
            await Vibration.vibrate(duration: 80);
            break;
          case VibrationIntensity.strong:
            // Double vibration for completion
            await Vibration.vibrate(duration: 150);
            await Future.delayed(Duration(milliseconds: 100));
            await Vibration.vibrate(duration: 150);
            break;
        }
        return; // Exit if vibration worked
      }
    } catch (e) {
      // Continue to fallback methods
    }

    try {
      // Method 2: Fallback to HapticFeedback
      switch (intensity) {
        case VibrationIntensity.normal:
          await HapticFeedback.lightImpact();
          break;
        case VibrationIntensity.strong:
          await HapticFeedback.heavyImpact();
          await Future.delayed(Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (e) {
      try {
        // Method 3: Last fallback - selection click
        await HapticFeedback.selectionClick();
      } catch (e) {
        // All vibration methods failed - silent operation
      }
    }
  }

  Future<void> reset() async {
    state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_counter', 0);
    ref.read(tasbeehCompletedProvider.notifier).state = false;
  }

  // Method to check and return vibration status for UI
  Future<VibrationStatus> checkVibrationForUI() async {
    return await _checkVibrationStatus();
  }
}

// Enums for better code organization
enum VibrationIntensity {
  normal,
  strong,
}

enum VibrationStatus {
  working,
  disabled,
  noHardware,
  unknown,
}

