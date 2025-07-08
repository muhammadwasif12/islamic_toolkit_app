import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/splash_screen.dart';
import 'package:islamic_toolkit_app/views/home_screen.dart';
import 'package:islamic_toolkit_app/views/qibla_screen.dart';
import 'package:islamic_toolkit_app/views/duas_screen.dart';
import 'package:islamic_toolkit_app/views/counter_screen.dart';
import 'package:islamic_toolkit_app/views/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Tool Kit App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(81, 187, 149, 1),
        ),
        useMaterial3: true,
        fontFamily: 'Mycustomfont',
      ),

      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/qibla': (context) => const QiblaScreen(),
        '/duas': (context) => const DuasScreen(),
        '/counter': (context) => const CounterScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
