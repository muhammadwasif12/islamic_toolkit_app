import 'package:easy_localization/easy_localization.dart';

class PrayerTimesModel {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String location;
  final String hijriDate;
  final DateTime currentTime;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.location,
    required this.hijriDate,
    required this.currentTime,
  });

  Map<String, DateTime> get prayerTimes => {
    'fajr': fajr,
    'zuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  String get nextPrayer {
    final now = currentTime;
    final prayers = prayerTimes.entries.toList();

    for (final prayer in prayers) {
      if (now.isBefore(prayer.value)) {
        return prayer.key;
      }
    }
    return 'fajr';
  }

  Duration get timeToNextPrayer {
    final now = currentTime;
    final nextPrayerTime = prayerTimes[nextPrayer];

    if (nextPrayerTime != null && now.isBefore(nextPrayerTime)) {
      return nextPrayerTime.difference(now);
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowFajr = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      fajr.hour,
      fajr.minute,
    );
    return tomorrowFajr.difference(now);
  }
}

String getLocalizedHijriDate(String hijriDate) {
  // Input format: "19 Muharram, 1447 H"
  // Split: ["19", "Muharram,", "1447", "H"]
  try {
    final parts = hijriDate.split(" ");
    if (parts.length < 3) return hijriDate;

    final day = parts[0]; // 19
    String month = parts[1].replaceAll(",", ""); // Muharram
    final year = parts.sublist(2).join(" "); // "1447 H"

    final localizedMonth = month.toLowerCase().replaceAll("-", "_").tr();
    return "$day $localizedMonth, $year";
  } catch (e) {
    return hijriDate;
  }
}
