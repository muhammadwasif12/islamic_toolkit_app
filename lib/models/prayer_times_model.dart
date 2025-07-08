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
    'Fajr': fajr,
    'Zuhr': dhuhr,
    'Asr': asr,
    'Maghrib': maghrib,
    'Isha': isha,
  };

  String get nextPrayer {
    final now = currentTime;
    final prayers = prayerTimes.entries.toList();

    for (final prayer in prayers) {
      if (now.isBefore(prayer.value)) {
        return prayer.key;
      }
    }
    return 'Fajr';
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
