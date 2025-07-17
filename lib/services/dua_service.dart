import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class DuaService {
  static Future<Map<String, String>> getRandomDua() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/daily_duas.json',
    );
    final Map<String, dynamic> allData = json.decode(jsonString);

    final List<Map<String, dynamic>> allDuas = [];

    allData.forEach((category, duas) {
      for (var dua in duas) {
        allDuas.add(Map<String, dynamic>.from(dua));
      }
    });

    if (allDuas.isEmpty) return {};

    final random = Random();
    final selected = allDuas[random.nextInt(allDuas.length)];

    return {
      'title': selected['title'] ?? '',
      'arabic': selected['arabic'] ?? '',
      'translation': selected['translation'] ?? '',
    };
  }
}
