import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import '../models/prayer_times_model.dart';
import 'package:hijri/hijri_calendar.dart';

final locationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
});

final cityNameProvider = FutureProvider<String>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    return '${place.locality}, ${place.country}';
  }
  return 'Unknown Location';
});

final prayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  final position = await ref.watch(locationProvider.future);
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
});

final currentTimeProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
