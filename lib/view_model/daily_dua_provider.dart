import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/daily_dua_model.dart';

final dailyDuaProvider = FutureProvider<DailyDua?>((ref) async {
  try {
    // Load JSON file
    final String jsonString = await rootBundle.loadString(
      'assets/json/daily_short_duas.json',
    );
    final dynamic jsonData = json.decode(jsonString);

    // Handle both array and object formats
    List<DailyDua> allDuas = [];

    if (jsonData is List) {
      // Direct array format
      for (var dua in jsonData) {
        final originalDua = DailyDua.fromJson(dua);
        final ellipsedTitle = _ellipseTitle(originalDua.title);
        allDuas.add(originalDua.copyWithEllipsedTitle(ellipsedTitle));
      }
    } else if (jsonData is Map<String, dynamic>) {
      // Category-wise object format
      jsonData.forEach((category, duas) {
        if (duas is List) {
          for (var dua in duas) {
            final originalDua = DailyDua.fromJson(dua);
            final ellipsedTitle = _ellipseTitle(originalDua.title);
            allDuas.add(originalDua.copyWithEllipsedTitle(ellipsedTitle));
          }
        }
      });
    }

    if (allDuas.isEmpty) return null;

    // Generate seed based on current date (changes daily)
    final now = DateTime.now();
    final daysSinceEpoch =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        (24 * 60 * 60 * 1000);
    final random = Random(daysSinceEpoch);

    // Select random dua for today
    final selectedDua = allDuas[random.nextInt(allDuas.length)];
    return selectedDua;
  } catch (e) {
    debugPrint('Error loading daily dua: $e');
    return null;
  }
});

// Helper function to ellipse title to 2 lines max
String _ellipseTitle(String title) {
  // Split title into words
  List<String> words = title.split(' ');

  // If title is short enough, return as is
  if (words.length <= 8) return title; // Approximate 2 lines

  // Calculate approximate character limit for 2 lines
  // Assuming average 40-50 characters per line
  const int maxChars = 80;

  if (title.length <= maxChars) return title;

  // Find the best cut-off point
  String ellipsedTitle = '';
  for (int i = 0; i < words.length; i++) {
    String temp =
        ellipsedTitle.isEmpty ? words[i] : '$ellipsedTitle ${words[i]}';

    if (temp.length > maxChars - 3) {
      // -3 for "..."
      break;
    }
    ellipsedTitle = temp;
  }

  return ellipsedTitle.isEmpty ? title : '$ellipsedTitle...';
}
