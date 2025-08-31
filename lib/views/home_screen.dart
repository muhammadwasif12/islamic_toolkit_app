// home_screen.dart - Cleaned with Utils Integration
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic_toolkit_app/widgets/build_hijri_calender.dart';
import '../models/daily_dua_model.dart';
import '../models/prayer_times_model.dart';
import '../view_model/daily_dua_provider.dart';
import '../view_model/prayer_times_provider.dart';
import '../view_model/time_format_provider.dart';
import '../widgets/build_prayer_time_card.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/fallback_dua_widget.dart';
import '../widgets/dua_content_widget.dart';
import '../widgets/formatted_time_widget.dart';
import '../view_model/ad_manager_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../view_model/notification_history_provider.dart';
import '../views/notification_history_screen.dart';
import '../utils/home_screen_utils.dart';
import '../utils/home_widget_utils.dart';
import '../utils/home_screen_timer_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _widgetUpdateTimer;
  bool _widgetInitialized = false;
  bool _hasScheduled = false;
  bool _settingsLoaded = false;
  DateTime? _lastWidgetUpdate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    _setupWidgetRefreshHandler();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForSettingsAndInitialize();
    });
  }

  void _waitForSettingsAndInitialize() async {
    await HomeScreenUtils.waitForSettingsToLoad();

    if (mounted) {
      _settingsLoaded = true;
      print('Settings loaded, ready for scheduling');

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _initializeHomeWidget();
        }
      });

      _startWidgetUpdateTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _refreshWidgetData();

        // Refresh notification providers when app resumes
        ref.refresh(notificationHistoryProvider);
        ref.refresh(unreadNotificationCountProvider);
        ref.refresh(notificationHistoryNotifierProvider);

        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _setupWidgetRefreshHandler() {
    HomeWidgetUtils.setupWidgetRefreshHandler(
      onRefreshRequested: () async {
        await HomeWidgetUtils.handleWidgetRefresh(
          ref: ref,
          lastUpdate: _lastWidgetUpdate,
        );
        _lastWidgetUpdate = DateTime.now();
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(currentTimeProvider.notifier).state = DateTime.now();

        if (HomeScreenTimerUtils.shouldUpdateWidget(DateTime.now()) &&
            _widgetInitialized) {
          _updateHomeWidgetSimple();
        }
      }
    });
  }

  void _startWidgetUpdateTimer() {
    _widgetUpdateTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (mounted && _widgetInitialized) {
        _refreshWidgetData();
      }
    });
  }

  void _refreshWidgetData() async {
    _lastWidgetUpdate = await HomeWidgetUtils.refreshWidgetData(
      lastUpdate: _lastWidgetUpdate,
    );
  }

  void _initializeHomeWidget() async {
    if (!_widgetInitialized) {
      _widgetInitialized = await HomeWidgetUtils.initializeWidget(ref: ref);
      _lastWidgetUpdate = DateTime.now();
    }
  }

  void _updateHomeWidgetSimple() async {
    if (_widgetInitialized) {
      await HomeWidgetUtils.updateWidgetSimple(lastUpdate: _lastWidgetUpdate);
      _lastWidgetUpdate = DateTime.now();
    }
  }

  void _scheduleNotifications(PrayerTimesModel prayerTimes) async {
    if (_hasScheduled) return;

    final success = await HomeScreenUtils.scheduleNotifications(
      ref: ref,
      prayerTimes: prayerTimes,
      settingsLoaded: _settingsLoaded,
    );

    if (success) {
      _hasScheduled = true;
    }
  }

  void _showHijriCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FullReadOnlyHijriCalendar(),
    );
  }

  //  HomeScreenState to manually refresh notifications
  void _refreshNotifications() {
    if (mounted) {
      ref.refresh(notificationHistoryProvider);
      ref.refresh(unreadNotificationCountProvider);
      ref.refresh(notificationHistoryNotifierProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _widgetUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowBannerAd = ref.watch(shouldShowBannerAdsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ref
          .watch(prayerTimesProvider)
          .when(
            data: (prayerTimes) {
              if (!_hasScheduled && prayerTimes != null && _settingsLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scheduleNotifications(prayerTimes);
                });
              }

              return _buildMainContent(prayerTimes, shouldShowBannerAd);
            },
            loading: () => const LoadingStateWidget(),
            error: (error, stack) => ErrorStateWidget(error: error, ref: ref),
          ),
    );
  }

  Widget _buildMainContent(PrayerTimesModel prayerTimes, bool showBannerAd) {
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
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

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
                height: HomeScreenUtils.getBottomContainerHeight(
                  screenHeight,
                  showBannerAd,
                ),
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
                child: Column(
                  children: [
                    Expanded(child: _buildDynamicDuaSection(screenHeight)),
                    if (showBannerAd)
                      Container(
                        height: 60,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: const BannerAdWidget(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(PrayerTimesModel prayerTimes) {
    return Consumer(
      builder: (context, ref, child) {
        final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

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
                        HomeScreenUtils.getLocalizedHijriDate(
                          prayerTimes.hijriDate,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: HomeScreenUtils.getResponsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    Text(
                      prayerTimes.location,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: HomeScreenUtils.getResponsiveFontSize(
                          context,
                          14,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Notification Bell with Badge
              GestureDetector(
                onTap: () {
                  // Refresh notifications before navigating
                  _refreshNotifications();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationHistoryScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/home_images/bell.png',
                      fit: BoxFit.contain,
                      width: HomeScreenUtils.getResponsiveIconSize(context, 24),
                      height: HomeScreenUtils.getResponsiveIconSize(
                        context,
                        24,
                      ),
                      filterQuality: FilterQuality.high,
                    ),

                    // Notification Badge
                    unreadCountAsync.when(
                      data: (unreadCount) {
                        if (unreadCount > 0) {
                          return Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainPrayerDisplay(PrayerTimesModel prayerTimes) {
    final timeComponents = HomeScreenTimerUtils.getTimeComponents(
      prayerTimes.timeToNextPrayer,
    );
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
            "${prayerTimes.nextPrayer.tr()} ${timeComponents['hours']} ${'hour'.tr()} ${timeComponents['minutes']} ${'min'.tr()} ${'left'.tr()}",
            style: TextStyle(
              color: Colors.white,
              fontSize: HomeScreenUtils.getResponsiveFontSize(context, 12),
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
      getResponsiveFontSize:
          (size) => HomeScreenUtils.getResponsiveFontSize(context, size),
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
      getResponsiveFontSize:
          (size) => HomeScreenUtils.getResponsiveFontSize(context, size),
    );
  }

  Widget _buildFallbackDua(double screenHeight) {
    return FallbackDuaWidget(
      screenHeight: screenHeight,
      getResponsiveFontSize:
          (size) => HomeScreenUtils.getResponsiveFontSize(context, size),
    );
  }
}
