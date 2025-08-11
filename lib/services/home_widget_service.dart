import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_times_model.dart';
import '../view_model/prayer_times_provider.dart';
import '../view_model/daily_dua_provider.dart';
import 'dart:async';

class HomeWidgetService {
  static const String _widgetName = 'HomeWidgetProvider';
  static const String _androidProviderName = 'HomeWidgetProvider';
  static Timer? _updateTimer;
  static WidgetRef? _ref;
  static bool _isInitialized = false;
  static int _duaIndex = 0;

  // Short Arabic-only duas for widget
  static final List<String> shortArabicDuas = [
    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
    'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ',
    'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    'اللَّهُ أَكْبَرُ',
    'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
  ];

  /// Helper function to capitalize prayer names
  static String _capitalizePrayerName(String prayerName) {
    if (prayerName.isEmpty) return prayerName;
    return prayerName[0].toUpperCase() + prayerName.substring(1).toLowerCase();
  }

  /// 🚀 Initialize HomeWidget Service
  static Future<void> initialize({required WidgetRef ref}) async {
    if (_isInitialized) {
      debugPrint(' [INIT] Already initialized');
      return;
    }

    try {
      _ref = ref;
      debugPrint('[INIT] Starting HomeWidget initialization...');

      // Setup widget with proper configuration
      await HomeWidget.setAppGroupId('group.islamic_toolkit_app');
      await HomeWidget.registerBackgroundCallback(backgroundCallback);

      // Force immediate data update
      await _performDataUpdate(force: true);

      _isInitialized = true;

      // Start periodic updates
      startPeriodicUpdates();

      debugPrint('[INIT] HomeWidget initialized successfully');
    } catch (e) {
      debugPrint(' [INIT] Initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Manual Update (Called from HomeScreen or refresh button)
  static Future<void> manualUpdate() async {
    if (!_isInitialized || _ref == null) {
      debugPrint(
        ' [MANUAL] Not ready - Init: $_isInitialized, Ref: ${_ref != null}',
      );
      return;
    }

    debugPrint('[MANUAL] Manual update triggered...');
    await _performDataUpdate(force: true);
  }

  ///  Core Data Update Logic
  static Future<void> _performDataUpdate({bool force = false}) async {
    if (_ref == null) {
      debugPrint(' [UPDATE] Ref is null');
      return;
    }

    try {
      debugPrint(' [UPDATE] Getting fresh data...');

      // Force refresh providers if needed
      if (force) {
        _ref!.invalidate(prayerTimesProvider);
        _ref!.invalidate(dailyDuaProvider);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Get fresh data
      final prayerTimesAsync = _ref!.read(prayerTimesProvider);
      final dailyDuaAsync = _ref!.read(dailyDuaProvider);

      String duaArabicOnly = shortArabicDuas[_duaIndex];

      // Get daily dua (Arabic part only)
      await dailyDuaAsync.when(
        data: (dua) async {
          if (dua != null && dua.arabic.isNotEmpty) {
            // Use only Arabic text for widget
            duaArabicOnly = dua.arabic;
            debugPrint(
              '[DUA] Got daily dua Arabic: ${dua.arabic.substring(0, 30)}...',
            );
          } else {
            debugPrint('[DUA] Daily dua is null, using fallback');
          }
        },
        loading: () async {
          debugPrint(' [DUA] Daily dua loading...');
        },
        error: (error, stack) async {
          debugPrint(' [DUA] Error loading daily dua: $error');
        },
      );

      // If no daily dua Arabic, use rotating fallback
      if (duaArabicOnly.isEmpty ||
          duaArabicOnly == shortArabicDuas[_duaIndex]) {
        _duaIndex = (_duaIndex + 1) % shortArabicDuas.length;
        duaArabicOnly = shortArabicDuas[_duaIndex];
        debugPrint('📿 [DUA] Using fallback Arabic dua index: $_duaIndex');
      }

      // Handle prayer times
      await prayerTimesAsync.when(
        data: (prayerTimes) async {
          if (prayerTimes != null) {
            debugPrint(' [PRAYER] Prayer times available');
            await _saveRealPrayerData(prayerTimes, duaArabicOnly);
          } else {
            debugPrint(' [PRAYER] Prayer times null, using default');
            await _saveDefaultData(duaArabicOnly);
          }
        },
        loading: () async {
          debugPrint(' [PRAYER] Prayer times loading');
          await _saveLoadingData(duaArabicOnly);
        },
        error: (error, stack) async {
          debugPrint(' [PRAYER] Prayer times error: $error');
          await _saveDefaultData(duaArabicOnly);
        },
      );

      // Force widget update
      await _forceWidgetUpdate();
    } catch (e) {
      debugPrint(' [UPDATE] Data update failed: $e');
    }
  }

  /// Save Real Prayer Data
  static Future<void> _saveRealPrayerData(
    PrayerTimesModel prayerTimes,
    String duaArabic,
  ) async {
    try {
      final currentTime = DateTime.now();
      final currentPrayer = _getCurrentPrayer(prayerTimes, currentTime);
      final nextPrayer = _capitalizePrayerName(prayerTimes.nextPrayer); // 🔥 CAPITALIZE
      final timeRemaining = _formatTimeLeft(prayerTimes.timeToNextPrayer);

      debugPrint(' [SAVE] Saving real prayer data:');
      debugPrint('   Current: $currentPrayer');
      debugPrint('   Next: $nextPrayer');
      debugPrint('   Time: $timeRemaining');
      debugPrint('   Dua Arabic: ${duaArabic.substring(0, 30)}...');

      // Save with multiple key formats for maximum compatibility
      final dataMap = {
        // Primary keys with flutter prefix
        'flutter.app_name': 'Islamic Toolkit',
        'flutter.current_prayer': currentPrayer,
        'flutter.next_prayer_name': nextPrayer,
        'flutter.next_prayer_time': timeRemaining,
        'flutter.random_dua': duaArabic, // Only Arabic text
        'flutter.next_prayer': '$nextPrayer in $timeRemaining',

        // Backup keys without prefix
        'app_name': 'Islamic Toolkit',
        'current_prayer': currentPrayer,
        'next_prayer_name': nextPrayer,
        'next_prayer_time': timeRemaining,
        'random_dua': duaArabic, // Only Arabic text
        'next_prayer': '$nextPrayer in $timeRemaining',
        'prayer_status': 'Current: $currentPrayer',
      };

      // Save each key with error handling
      for (String key in dataMap.keys) {
        try {
          await HomeWidget.saveWidgetData<String>(key, dataMap[key]!);
        } catch (e) {
          debugPrint('❌ [SAVE] Failed to save $key: $e');
        }
      }

      debugPrint('[SAVE] Real prayer data saved successfully');
    } catch (e) {
      debugPrint(' [SAVE] Error saving prayer data: $e');
    }
  }

  ///  Save Default Data
  static Future<void> _saveDefaultData(String duaArabic) async {
    try {
      final dataMap = {
        'flutter.app_name': 'Islamic Toolkit',
        'flutter.current_prayer': 'Maghrib',
        'flutter.next_prayer_name': 'Isha', // Already capitalized
        'flutter.next_prayer_time': '01:45:30',
        'flutter.random_dua': duaArabic,
        'flutter.next_prayer': 'Isha in 01:45:30',

        'app_name': 'Islamic Toolkit',
        'current_prayer': 'Maghrib',
        'next_prayer_name': 'Isha', // Already capitalized
        'next_prayer_time': '01:45:30',
        'random_dua': duaArabic,
        'next_prayer': 'Isha in 01:45:30',
      };

      for (String key in dataMap.keys) {
        await HomeWidget.saveWidgetData<String>(key, dataMap[key]!);
      }

      debugPrint(' [DEFAULT] Default data saved');
    } catch (e) {
      debugPrint(' [DEFAULT] Error saving default data: $e');
    }
  }

  ///  Save Loading Data
  static Future<void> _saveLoadingData(String duaArabic) async {
    try {
      final dataMap = {
        'flutter.app_name': 'Islamic Toolkit',
        'flutter.current_prayer': 'Loading...',
        'flutter.next_prayer_name': 'Loading...',
        'flutter.next_prayer_time': '--:--:--',
        'flutter.random_dua': duaArabic,
        'flutter.next_prayer': 'Loading... in --:--:--',

        'app_name': 'Islamic Toolkit',
        'current_prayer': 'Loading...',
        'next_prayer_name': 'Loading...',
        'next_prayer_time': '--:--:--',
        'random_dua': duaArabic,
        'next_prayer': 'Loading... in --:--:--',
      };

      for (String key in dataMap.keys) {
        await HomeWidget.saveWidgetData<String>(key, dataMap[key]!);
      }

      debugPrint(' [LOADING] Loading data saved');
    } catch (e) {
      debugPrint(' [LOADING] Error saving loading data: $e');
    }
  }

  /// Force Widget Update
  static Future<void> _forceWidgetUpdate() async {
    try {
      debugPrint('📱 [WIDGET] Forcing widget update...');

      // Multiple update attempts for better reliability
      final updateResults = await Future.wait([
        HomeWidget.updateWidget(name: _widgetName),
        HomeWidget.updateWidget(androidName: _androidProviderName),
        HomeWidget.updateWidget(),
      ]);

      bool anySuccess = updateResults.any((result) => result == true);

      if (anySuccess) {
        debugPrint(' [WIDGET] Widget updated successfully!');
      } else {
        debugPrint(' [WIDGET] All update attempts returned false');
      }
    } catch (e) {
      debugPrint('[WIDGET] Widget update error: $e');
    }
  }

  /// Start Periodic Updates
  static void startPeriodicUpdates() {
    if (!_isInitialized) {
      debugPrint('[TIMER] Cannot start - not initialized');
      return;
    }

    _updateTimer?.cancel();

    // Update every 60 seconds for better performance
    _updateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      final now = DateTime.now();
      debugPrint(' [TIMER] Auto update at ${now.toString().substring(11, 19)}');
      _performDataUpdate();
    });

    debugPrint(' [TIMER] Started periodic updates (60s interval)');
  }

  ///  Background Callback
  static Future<void> backgroundCallback(Uri? data) async {
    debugPrint(' [CALLBACK] Background triggered: ${data?.toString()}');

    if (_ref != null && _isInitialized) {
      await _performDataUpdate(force: true);
      debugPrint(' [CALLBACK] Background update completed');
    }
  }

  ///  Get Current Prayer
  static String _getCurrentPrayer(PrayerTimesModel prayerTimes, DateTime now) {
    if (now.isBefore(prayerTimes.fajr)) return 'Isha';
    if (now.isBefore(prayerTimes.sunrise)) return 'Fajr';
    if (now.isBefore(prayerTimes.dhuhr)) return 'Sunrise';
    if (now.isBefore(prayerTimes.asr)) return 'Dhuhr';
    if (now.isBefore(prayerTimes.maghrib)) return 'Asr';
    if (now.isBefore(prayerTimes.isha)) return 'Maghrib';
    return 'Isha';
  }

  ///  Format Time Remaining
  static String _formatTimeLeft(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ///  Cleanup
  static void dispose() {
    debugPrint(' [DISPOSE] Disposing HomeWidgetService...');

    _updateTimer?.cancel();
    _updateTimer = null;
    _ref = null;
    _isInitialized = false;
    _duaIndex = 0;

    debugPrint(' [DISPOSE] HomeWidgetService disposed');
  }

  ///  Debug Status
  static void debugStatus() {
    debugPrint(' [DEBUG] HomeWidgetService Status:');
    debugPrint('   Initialized: $_isInitialized');
    debugPrint('   Ref Available: ${_ref != null}');
    debugPrint('   Timer Active: ${_updateTimer?.isActive ?? false}');
    debugPrint('   Current Dua Index: $_duaIndex');
    debugPrint('   Widget Name: $_widgetName');
    debugPrint('   Android Provider: $_androidProviderName');
  }
}