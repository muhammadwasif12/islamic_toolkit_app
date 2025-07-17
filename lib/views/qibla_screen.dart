import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_app_bar.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  double? _heading;
  double? _qiblaDirection;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserLocation();
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getUserLocation(); // Retry location fetch when user returns to app
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    _positionSub?.cancel(); // Prevent multiple subscriptions
    _positionSub = Geolocator.getPositionStream().listen((Position position) {
      double qibla = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _qiblaDirection = qibla;
      });
    });
  }

  double _calculateQiblaDirection(double userLat, double userLng) {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    final lat1 = _degreesToRadians(userLat);
    final lon1 = _degreesToRadians(userLng);
    final lat2 = _degreesToRadians(kaabaLat);
    final lon2 = _degreesToRadians(kaabaLng);

    final deltaLon = lon2 - lon1;
    final y = sin(deltaLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);

    final qiblaAngle = atan2(y, x);
    return (_radiansToDegrees(qiblaAngle) + 360) % 360;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
  double _radiansToDegrees(double radians) => radians * 180 / pi;

  @override
  Widget build(BuildContext context) {
    final angle = ((_qiblaDirection ?? 0) - (_heading ?? 0)) * (pi / 180);

    return Scaffold(
      appBar: CustomAppBar(title: "qibla_direction".tr()),
      backgroundColor: const Color(0xffFDFCF7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: GestureDetector(
                onTap: () => _showSurahBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/qibla_images/Al-Fatihah.png',
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child:
                      (_heading == null || _qiblaDirection == null)
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 0,
                                child: Image.asset(
                                  'assets/qibla_images/north.png',
                                  height: 30,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Image.asset(
                                  'assets/qibla_images/south.png',
                                  height: 30,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: Image.asset(
                                  'assets/qibla_images/west.png',
                                  height: 30,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                child: Image.asset(
                                  'assets/qibla_images/east.png',
                                  height: 30,
                                ),
                              ),

                              // Static compass background
                              Image.asset('assets/qibla_images/lastline.png'),
                              Image.asset(
                                'assets/qibla_images/stronglineInner.png',
                              ),
                              Image.asset('assets/qibla_images/innerline1.png'),
                              Image.asset('assets/qibla_images/innerline.png'),
                              Image.asset('assets/qibla_images/outerline.png'),

                              // Rotating Compass Needle
                              Transform.rotate(
                                angle: angle,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/qibla_images/backNeedles.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/needle2.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/needle1.png',
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                        offset: const Offset(-50, 0),
                                        child: Image.asset(
                                          'assets/qibla_images/needle3.png',
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                        offset: const Offset(60, 0),
                                        child: Image.asset(
                                          'assets/qibla_images/needle4.png',
                                          height: 25,
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/dottedcircle.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/greencircle.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/blackcircle.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/mainNeedle.png',
                                    ),
                                    Image.asset(
                                      'assets/qibla_images/mainpoint.png',
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: Image.asset(
                                        'assets/qibla_images/qibla.png',
                                        height: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFe8f5e9), Color(0xFFc8e6c9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "surah_al_fatihah".tr(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Mycustomfont',
                            color: Color(0xFFB7935F),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n"
                            "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n"
                            "الرَّحْمَٰنِ الرَّحِيمِ\n"
                            "مَالِكِ يَوْمِ الدِّينِ\n"
                            "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n"
                            "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n"
                            "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ "
                            "غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Mycustomfont',
                              height: 2,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
