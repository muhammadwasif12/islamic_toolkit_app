import 'package:flutter/material.dart';
import 'package:islamic_toolkit_app/views/splash_screen.dart';

void main() {
  runApp(MyApp());
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
          seedColor: Color.fromRGBO(81, 187, 149, 1),
        ),
        useMaterial3: true,
        fontFamily: 'Mycustomfont',
      ),

      home: SplashScreen(),
    );
  }
}
