// utils/widget_utils.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/home_widget_service.dart';
import '../view_model/daily_dua_provider.dart';
import '../view_model/prayer_times_provider.dart';

class HomeWidgetUtils {
  static const platform = MethodChannel(
    'com.example.islamic_toolkit_app/widget',
  );

  // Setup method call handler for widget refresh
  static void setupWidgetRefreshHandler({
    required Function() onRefreshRequested,
  }) {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetRefreshRequested') {
        print('Widget refresh requested from native');
        await onRefreshRequested();
      }
    });
  }

  // Handle widget refresh with proper error handling
  static Future<void> handleWidgetRefresh({
    required WidgetRef ref,
    required DateTime? lastUpdate,
  }) async {
    try {
      print('Handling widget refresh...');

      final now = DateTime.now();
      if (lastUpdate != null && now.difference(lastUpdate).inSeconds < 5) {
        print('Skipping refresh - too recent');
        return;
      }

      // Invalidate providers to force fresh data
      ref.invalidate(prayerTimesProvider);
      ref.invalidate(dailyDuaProvider);

      // Wait for providers to refresh
      await Future.delayed(const Duration(milliseconds: 500));

      // Force widget update
      await HomeWidgetService.manualUpdate();

      print('Widget refresh completed');
    } catch (e) {
      print('Error handling widget refresh: $e');
    }
  }

  // Initialize widget with proper error handling
  static Future<bool> initializeWidget({required WidgetRef ref}) async {
    try {
      print('Initializing widget...');
      await HomeWidgetService.initialize(ref: ref);

      await Future.delayed(const Duration(milliseconds: 800));
      await HomeWidgetService.manualUpdate();

      print('Widget initialization completed');
      return true;
    } catch (e) {
      print('Error initializing widget: $e');
      return false;
    }
  }

  // Update widget with rate limiting
  static Future<void> updateWidgetSimple({
    required DateTime? lastUpdate,
  }) async {
    try {
      final now = DateTime.now();

      if (lastUpdate != null && now.difference(lastUpdate).inSeconds < 60) {
        return;
      }

      await HomeWidgetService.manualUpdate();
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  // Refresh widget data with rate limiting
  static Future<DateTime?> refreshWidgetData({
    required DateTime? lastUpdate,
  }) async {
    try {
      final now = DateTime.now();

      if (lastUpdate != null && now.difference(lastUpdate).inSeconds < 120) {
        return lastUpdate;
      }

      await HomeWidgetService.manualUpdate();
      return now;
    } catch (e) {
      print('Error refreshing widget data: $e');
      return lastUpdate;
    }
  }
}
