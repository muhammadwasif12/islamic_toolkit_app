import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/prayer_times_model.dart';
import '../view_model/prayer_times_provider.dart';
import '../view_model/location_service_provider.dart';
import '../widgets/build_prayer_time_card.dart';
import 'package:islamic_toolkit_app/services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  bool _hasScheduled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    //  Schedule prayer notifications after loading prayer times
    Future.delayed(Duration.zero, () {
      final prayerTimes = ref
          .read(prayerTimesProvider)
          .maybeWhen(data: (times) => times, orElse: () => null);

      if (prayerTimes != null && !_hasScheduled) {
        _hasScheduled = true;
        NotificationService.schedulePrayerNotifications({
          'fajr': prayerTimes.fajr,
          'dhuhr': prayerTimes.dhuhr,
          'asr': prayerTimes.asr,
          'maghrib': prayerTimes.maghrib,
          'isha': prayerTimes.isha,
        });
      }
    });
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
            error: (error, stack) => _buildErrorState(error, ref),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.43,
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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            child: _buildAdhkarSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(62, 180, 137, 1)),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'loading_prayer_times'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(62, 180, 137, 1)),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                'unable_to_load_prayer'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(locationServiceProvider);
                  ref.invalidate(cityNameProvider);
                  ref.invalidate(prayerTimesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
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
                  getLocalizedHijriDate(prayerTimes.hijriDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayerTimes.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const ImageIcon(
              AssetImage('assets/home_images/bell.png'),
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {},
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
            color: Colors.amber,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${prayerTimes.nextPrayer.tr()} $hours ${'hour'.tr()} $minutes ${'min'.tr()} ${'left'.tr()}",
          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                  name: 'fajr'.tr(),
                  time: prayerTimes.fajr,
                  iconPath: 'assets/home_images/fajr.png',
                  isNext: prayerTimes.nextPrayer == 'fajr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'zuhr'.tr(),
                  time: prayerTimes.dhuhr,
                  iconPath: 'assets/home_images/zuhr.png',
                  isNext: prayerTimes.nextPrayer == 'zuhr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'asr'.tr(),
                  time: prayerTimes.asr,
                  iconPath: 'assets/home_images/asr.png',
                  isNext: prayerTimes.nextPrayer == 'asr',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'maghrib'.tr(),
                  time: prayerTimes.maghrib,
                  iconPath: 'assets/home_images/maghrib.png',
                  isNext: prayerTimes.nextPrayer == 'maghrib',
                ),
              ),
              Expanded(
                child: PrayerTimeCard(
                  name: 'isha'.tr(),
                  time: prayerTimes.isha,
                  iconPath: 'assets/home_images/isha.png',
                  isNext: prayerTimes.nextPrayer == 'isha',
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
        image: const DecorationImage(
          image: AssetImage('assets/home_images/islamic.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الأذكار المفضلة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 11),
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
          const SizedBox(height: 9),
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
