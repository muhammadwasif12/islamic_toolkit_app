import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/splash_screen.dart';
//import 'package:device_preview/device_preview.dart';
//import 'package:flutter/foundation.dart';

void main() {
  runApp(
    // DevicePreview(
    //  enabled: !kReleaseMode,
    //builder: (context) =>
    const ProviderScope(child: MyApp()),
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Tool Kit App',
      debugShowCheckedModeBanner: false,

      //locale: DevicePreview.locale(context),
      //builder: DevicePreview.appBuilder,
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
