import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic_toolkit_app/widgets/build_hijri_calender.dart';
import '../models/daily_dua_model.dart';
import '../models/prayer_times_model.dart';
import '../services/home_widget_service.dart';
import '../services/notification_service.dart';
import '../view_model/daily_dua_provider.dart';
import '../view_model/prayer_times_provider.dart';
import '../view_model/time_format_provider.dart';
import '../widgets/build_prayer_time_card.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/fallback_dua_widget.dart';
import '../widgets/dua_content_widget.dart';
import '../widgets/formatted_time_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  bool _widgetInitialized = false;
  bool _hasScheduled = false;
  DateTime? _lastWidgetUpdate;
  static const platform = MethodChannel(
    'com.example.islamic_toolkit_app/widget',
  );

  @override
  void initState() {
    super.initState();
    _startTimer();
    _setupWidgetRefreshHandler();
    // DELAY WIDGET INITIALIZATION TO AVOID INITIAL BLINK
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _initializeHomeWidget();
      }
    });
  }

  void _setupWidgetRefreshHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetRefreshRequested') {
        debugPrint(' Widget refresh requested from native');
        await _handleWidgetRefresh();
      }
    });
  }

  Future<void> _handleWidgetRefresh() async {
    try {
      debugPrint(' Handling widget refresh...');

      // AVOID FREQUENT REFRESHES - CHECK LAST UPDATE TIME
      final now = DateTime.now();
      if (_lastWidgetUpdate != null &&
          now.difference(_lastWidgetUpdate!).inSeconds < 5) {
        debugPrint(' Skipping refresh - too recent');
        return;
      }

      // Invalidate providers to force fresh data
      ref.invalidate(prayerTimesProvider);
      ref.invalidate(dailyDuaProvider);

      // Wait a bit for providers to refresh
      await Future.delayed(const Duration(milliseconds: 500));

      // Force widget update
      await HomeWidgetService.manualUpdate();
      _lastWidgetUpdate = now;

      debugPrint(' Widget refresh completed');
    } catch (e) {
      debugPrint(' Error handling widget refresh: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(currentTimeProvider.notifier).state = DateTime.now();

        // REDUCE WIDGET UPDATE FREQUENCY - ONLY EVERY 30 SECONDS
        if (DateTime.now().second % 30 == 0 && _widgetInitialized) {
          _updateHomeWidgetSimple();
        }
      }
    });
  }

  void _initializeHomeWidget() async {
    if (!_widgetInitialized) {
      debugPrint(' Initializing widget...');
      await HomeWidgetService.initialize(ref: ref);
      _widgetInitialized = true;

      // REDUCE DELAY AND AVOID IMMEDIATE UPDATE
      await Future.delayed(const Duration(milliseconds: 800));
      await HomeWidgetService.manualUpdate();
      _lastWidgetUpdate = DateTime.now();
    }
  }

  void _updateHomeWidgetSimple() async {
    if (_widgetInitialized) {
      final now = DateTime.now();

      // PREVENT TOO FREQUENT UPDATES
      if (_lastWidgetUpdate != null &&
          now.difference(_lastWidgetUpdate!).inSeconds < 10) {
        return;
      }

      await HomeWidgetService.manualUpdate();
      _lastWidgetUpdate = now;
    }
  }

  void _scheduleNotifications(PrayerTimesModel prayerTimes) async {
    if (_hasScheduled) {
      return;
    }

    try {
      _hasScheduled = true;

      final prayerTimesMap = {
        'fajr': prayerTimes.fajr,
        'dhuhr': prayerTimes.dhuhr,
        'asr': prayerTimes.asr,
        'maghrib': prayerTimes.maghrib,
        'isha': prayerTimes.isha,
      };

      await NotificationService.schedulePrayerNotifications(prayerTimesMap);
      await NotificationService.getPendingNotifications();

      debugPrint(' Prayer notifications scheduled successfully');
    } catch (e) {
      debugPrint(' Error scheduling notifications: $e');
      _hasScheduled = false;
    }
  }

  void _showHijriCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FullReadOnlyHijriCalendar(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    HomeWidgetService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ref
          .watch(prayerTimesProvider)
          .when(
            data: (prayerTimes) {
              // Schedule notifications only once
              if (!_hasScheduled && prayerTimes != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scheduleNotifications(prayerTimes);
                });
              }

              return _buildMainContent(prayerTimes);
            },
            loading: () => const LoadingStateWidget(),
            error: (error, stack) => ErrorStateWidget(error: error, ref: ref),
          ),
    );
  }

  Widget _buildMainContent(PrayerTimesModel prayerTimes) {
    final currentTime = ref.watch(currentTimeProvider);

    final updatedPrayerTimes = PrayerTimesModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      location: prayerTimes.location,
      hijriDate: prayerTimes.hijriDate,
      currentTime: currentTime,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        return Stack(
          children: [
            // Green background section
            Container(
              color: const Color.fromRGBO(62, 180, 137, 1),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(updatedPrayerTimes),
                    _buildMainPrayerDisplay(updatedPrayerTimes),
                    _buildPrayerTimesRow(updatedPrayerTimes, screenWidth),
                  ],
                ),
              ),
            ),

            // White bottom section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _getBottomContainerHeight(screenHeight),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildDynamicDuaSection(screenHeight),
              ),
            ),
          ],
        );
      },
    );
  }

  double _getBottomContainerHeight(double screenHeight) {
    if (screenHeight < 600) {
      return screenHeight * 0.50;
    } else if (screenHeight < 750) {
      return screenHeight * 0.53;
    } else {
      return screenHeight * 0.55;
    }
  }

  Widget _buildHeader(PrayerTimesModel prayerTimes) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showHijriCalendarDialog(context),
                  child: Text(
                    getLocalizedHijriDate(prayerTimes.hijriDate),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getResponsiveFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Text(
                  prayerTimes.location,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: _getResponsiveFontSize(14),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/home_images/bell.png',
            fit: BoxFit.contain,
            width: _getResponsiveIconSize(24),
            height: _getResponsiveIconSize(24),
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPrayerDisplay(PrayerTimesModel prayerTimes) {
    final timeLeft = prayerTimes.timeToNextPrayer;
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;
    final use24Hour = ref.watch(use24HourFormatProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Column(
        children: [
          _buildFormattedTime(prayerTimes.currentTime, use24Hour),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            "${prayerTimes.nextPrayer.tr()} $hours ${'hour'.tr()} $minutes ${'min'.tr()} ${'left'.tr()}",
            style: TextStyle(
              color: Colors.white,
              fontSize: _getResponsiveFontSize(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedTime(DateTime time, bool use24Hour) {
    return FormattedTimeWidget(
      time: time,
      use24Hour: use24Hour,
      getResponsiveFontSize: _getResponsiveFontSize,
    );
  }

  Widget _buildPrayerTimesRow(
    PrayerTimesModel prayerTimes,
    double screenWidth,
  ) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: SvgPicture.asset(
            'assets/home_images/Vector.svg',
            alignment: Alignment.bottomCenter,
            fit: BoxFit.fitWidth,
            width: screenWidth,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.055,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: PrayerTimeCard(
                  name: 'fajr'.tr(),
                  time: prayerTimes.fajr,
                  iconPath: 'assets/home_images/fajr.png',
                  isNext: prayerTimes.nextPrayer == 'fajr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'zuhr'.tr(),
                  time: prayerTimes.dhuhr,
                  iconPath: 'assets/home_images/zuhr.png',
                  isNext: prayerTimes.nextPrayer == 'zuhr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'asr'.tr(),
                  time: prayerTimes.asr,
                  iconPath: 'assets/home_images/asr.png',
                  isNext: prayerTimes.nextPrayer == 'asr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'maghrib'.tr(),
                  time: prayerTimes.maghrib,
                  iconPath: 'assets/home_images/maghrib.png',
                  isNext: prayerTimes.nextPrayer == 'maghrib',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'isha'.tr(),
                  time: prayerTimes.isha,
                  iconPath: 'assets/home_images/isha.png',
                  isNext: prayerTimes.nextPrayer == 'isha',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicDuaSection(double screenHeight) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/home_images/islamic.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.9,
                height: screenHeight * 0.4,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.10,
              screenHeight * 0.03,
              MediaQuery.of(context).size.width * 0.10,
              screenHeight * 0.02,
            ),
            child: Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final dailyDuaAsync = ref.watch(dailyDuaProvider);

                  return dailyDuaAsync.when(
                    data: (dua) {
                      if (dua == null) {
                        return _buildFallbackDua(screenHeight);
                      }
                      return _buildDuaContent(dua, screenHeight);
                    },
                    loading:
                        () => CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[700]!,
                          ),
                        ),
                    error: (error, stack) {
                      debugPrint('Error loading dua: $error');
                      return _buildFallbackDua(screenHeight);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaContent(DailyDua dua, double screenHeight) {
    return DuaContentWidget(
      dua: dua,
      screenHeight: screenHeight,
      getResponsiveFontSize: _getResponsiveFontSize,
    );
  }

  Widget _buildFallbackDua(double screenHeight) {
    return FallbackDuaWidget(
      screenHeight: screenHeight,
      getResponsiveFontSize: _getResponsiveFontSize,
    );
  }

  // Helper methods for responsive sizing
  double _getResponsiveFontSize(double baseFontSize) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) {
      return baseFontSize * 0.85;
    } else if (screenHeight < 750) {
      return baseFontSize * 0.95;
    } else {
      return baseFontSize;
    }
  }

  double _getResponsiveIconSize(double baseSize) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) {
      return baseSize * 0.8;
    } else if (screenHeight < 750) {
      return baseSize * 0.9;
    } else {
      return baseSize;
    }
  }
}
