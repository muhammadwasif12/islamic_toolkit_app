import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/prayer_times_model.dart';
import 'package:islamic_toolkit_app/view_model/prayer_times_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic_toolkit_app/widgets/build_prayer_time_card.dart';

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

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.70,
          color: const Color.fromRGBO(62, 180, 137, 1),
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
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Image.asset(
              "assets/home_images/Ellipse.png",
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/home_images/islamic.png'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 25),
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
            fontSize: 45,
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
      fit: StackFit.loose,
      children: [
        Row(
          children: [
            const SizedBox(width: 5),
            SvgPicture.asset(
              'assets/home_images/Vector.svg',
              alignment: Alignment.bottomCenter,
              fit: BoxFit.contain,
              width: 340,
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
                  iconPath: 'assets/home_images/fajr.png',
                  isNext: prayerTimes.nextPrayer == 'Fajr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Zuhr',
                  time: prayerTimes.dhuhr,
                  iconPath: 'assets/home_images/zuhr.png',
                  isNext: prayerTimes.nextPrayer == 'Zuhr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Asr',
                  time: prayerTimes.asr,
                  iconPath: 'assets/home_images/asr.png',
                  isNext: prayerTimes.nextPrayer == 'Asr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Maghrib',
                  time: prayerTimes.maghrib,
                  iconPath: 'assets/home_images/maghrib.png',
                  isNext: prayerTimes.nextPrayer == 'Maghrib',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'Isha',
                  time: prayerTimes.isha,
                  iconPath: 'assets/home_images/isha.png',
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('assets/home_images/islamic.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الأذكار المفضلة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            ' "لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ،\nلَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ،\nوَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'يقول ﷺ: أحبُّ الكلام إلى الله أربع: سبحان الله،\n والحمد لله، ولا إله إلا الله، والله أكبر.\n ويقول: الباقيات الصالحات: سبحان الله،\n والحمد لله، ولا إله إلا الله، والله أكبر،\n ولا حول ولا قوة إلا بالله',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
