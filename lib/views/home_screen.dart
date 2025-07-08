import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/prayer_times_model.dart';
import 'package:islamic_toolkit_app/view_model/prayer_times_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic_toolkit_app/widgets/build_prayer_time_card.dart';
import 'package:islamic_toolkit_app/widgets/build_nav_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(currentTimeProvider.notifier).state = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigation(context, ref),
      body: ref
          .watch(prayerTimesProvider)
          .when(
            data: (prayerTimes) => _buildMainContent(prayerTimes),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error),
          ),
    );
  }

  Widget _buildMainContent(PrayerTimesModel prayerTimes) {
    final currentTime = ref.watch(currentTimeProvider);
    final updatedPrayerTimes = PrayerTimesModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      location: prayerTimes.location,
      hijriDate: prayerTimes.hijriDate,
      currentTime: currentTime,
    );

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(62, 180, 137, 1),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(updatedPrayerTimes),
                _buildMainPrayerDisplay(updatedPrayerTimes),
                _buildPrayerTimesRow(updatedPrayerTimes),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: _buildAdhkarSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(62, 180, 137, 1)),
      child: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading Prayer Times...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(62, 180, 137, 1)),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Unable to load prayer times',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(prayerTimesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PrayerTimesModel prayerTimes) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerTimes.hijriDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayerTimes.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPrayerDisplay(PrayerTimesModel prayerTimes) {
    final timeLeft = prayerTimes.timeToNextPrayer;
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;

    return Column(
      children: [
        Text(
          "${prayerTimes.currentTime.hour.toString().padLeft(2, '0')}:${prayerTimes.currentTime.minute.toString().padLeft(2, '0')}",
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${prayerTimes.nextPrayer} $hours hour $minutes min left",
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesRow(PrayerTimesModel prayerTimes) {
    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(width: 22),
            SvgPicture.asset(
              'assets/home_images/Vector.svg',
              alignment: Alignment.bottomCenter,
              fit: BoxFit.cover,
              width: 300,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: PrayerTimeCard(
                  name: 'Fajr',
                  time: prayerTimes.fajr,
                  icon: Icons.wb_sunny_outlined,
                  isNext: prayerTimes.nextPrayer == 'Fajr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Zuhr',
                  time: prayerTimes.dhuhr,
                  icon: Icons.wb_sunny,
                  isNext: prayerTimes.nextPrayer == 'Zuhr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Asr',
                  time: prayerTimes.asr,
                  icon: Icons.wb_cloudy,
                  isNext: prayerTimes.nextPrayer == 'Asr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Maghrib',
                  time: prayerTimes.maghrib,
                  icon: Icons.wb_twilight,
                  isNext: prayerTimes.nextPrayer == 'Maghrib',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Isha',
                  time: prayerTimes.isha,
                  icon: Icons.bedtime,
                  isNext: prayerTimes.nextPrayer == 'Isha',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdhkarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/home_images/adhkar.svg',
            width: 300,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.black45,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavItemWidget(icon: Icons.home, label: "Home", index: 0),
          NavItemWidget(icon: Icons.explore, label: "Qibla", index: 1),
          NavItemWidget(icon: Icons.pan_tool, label: "Dua's", index: 2),
          NavItemWidget(icon: Icons.timer, label: "Counter", index: 3),
          NavItemWidget(icon: Icons.settings, label: "Settings", index: 4),
        ],
      ),
    );
  }
}
