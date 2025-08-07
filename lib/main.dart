import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/widgets/app_rebuilder.dart';
import 'package:islamic_toolkit_app/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

  await NotificationService.init();
  await NotificationService.scheduleDailyDuas();

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

class MyApp extends StatelessWidget {
  final Key? key;
  const MyApp({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      title: 'Islamic Tool Kit App',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(81, 187, 149, 1),
        ),
        useMaterial3: true,
        fontFamily: 'Mycustomfont',
      ),
      home: const SplashScreen(),
    );
  }
}
