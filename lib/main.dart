// main.dart - Updated with Stream Support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/utils/app_rebuilder.dart';
import 'package:islamic_toolkit_app/services/notification_service.dart';
import 'package:islamic_toolkit_app/services/fcm_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'services/admob_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('ar'),
        Locale('fa'),
      ],
      path: 'assets/languageChange',
      fallbackLocale: const Locale('en'),
      child: DevicePreview(
        enabled: false, 
        builder: (context) => const ProviderScope(child: AppRebuilder()),
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  // Initialize Firebase f
  await Firebase.initializeApp();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Parallel initialization for better performance
  await Future.wait([_loadEnvironment(), _initializeTimezone()]);

  // Initialize services sequentially
  await NotificationService.init();
  await FCMService.initialize();

  // Background tasks that can be delayed
  _scheduleBackgroundTasks();

  // Initialize AdMob last
  await AdMobService.initialize();
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Silently use fallback - no performance impact
  }
}

Future<void> _initializeTimezone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
}

void _scheduleBackgroundTasks() {
  // Run after frame to avoid blocking UI
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.microtask(() async {
      await NotificationService.scheduleDailyDuasIfEnabled();
    });
  });
}

class MyApp extends StatefulWidget {
  final Key? key;
  const MyApp({this.key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Delayed initialization to prevent frame drops
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          AdMobService.instance.markFirstLaunchComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ADDED: Dispose FCM stream controller
    FCMService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optimize lifecycle handling
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _handleAppResumed() {
    // Run in next frame to avoid blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdMobService.instance.onAppForeground();
      AdMobService.instance.onAppResumed();

      // Refresh notification stream when app is resumed
      FCMService.initializeNotificationStream();
    });
  }

  void _handleAppPaused() {
    // Immediate execution for pause events
    AdMobService.instance.onAppPaused();
    AdMobService.instance.onAppBackground();
  }

  @override
  Widget build(BuildContext context) {
    // Set FCM context after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FCMService.setContext(context);
      }
    });

    return MaterialApp(
      key: widget.key,
      title: 'Islamic Tool Kit App',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context) ?? context.locale,
      builder: DevicePreview.appBuilder,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(81, 187, 149, 1),
        ),
        useMaterial3: true,
        fontFamily: 'Mycustomfont',
        // Performance optimizations
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),

      // Performance settings
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
