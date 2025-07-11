import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import '../models/prayer_times_model.dart';
import 'location_service_provider.dart';

final cityNameProvider = FutureProvider<String>((ref) async {
  try {
    final position = await ref.watch(locationServiceProvider.future);
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.locality}, ${place.country}';
    }
    return 'Unknown Location';
  } catch (e) {
    throw Exception("City name fetch failed: $e");
  }
});

final prayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  try {
    final position = await ref.watch(locationServiceProvider.future);
    final cityName = await ref.watch(cityNameProvider.future);

    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    final hijriDate = HijriCalendar.now();

    return PrayerTimesModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      location: cityName,
      hijriDate:
          '${hijriDate.hDay} ${hijriDate.longMonthName}, ${hijriDate.hYear} H',
      currentTime: DateTime.now(),
    );
  } catch (e) {
    throw Exception("Prayer time fetch failed: $e");
  }
});

final currentTimeProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
