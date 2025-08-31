import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <-- added this
import 'package:geolocator/geolocator.dart';

import '../widgets/custom_app_bar.dart';
import '../utils/surah_bottom_sheet.dart';

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
      _getUserLocation();
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

    _positionSub?.cancel();
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: GestureDetector(
                onTap: () => showSurahBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    'assets/qibla_images/Al-Fatihah.svg',
                    fit: BoxFit.contain,
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
                              // Cardinal directions
                              Positioned(
                                top: -1,
                                child: SvgPicture.asset(
                                  'assets/qibla_images/north.svg',
                                  height: 25,
                                ),
                              ),
                              Positioned(
                                bottom: -0.9,
                                child: SvgPicture.asset(
                                  'assets/qibla_images/south.svg',
                                  height: 25,
                                ),
                              ),
                              Positioned(
                                left: 14,
                                child: SvgPicture.asset(
                                  'assets/qibla_images/west.svg',
                                  height: 23,
                                ),
                              ),
                              Positioned(
                                right: 19,
                                child: SvgPicture.asset(
                                  'assets/qibla_images/east.svg',
                                  height: 23,
                                ),
                              ),

                              // Background layers
                              SvgPicture.asset(
                                'assets/qibla_images/blackcircle.svg',
                              ),
                              SvgPicture.asset(
                                'assets/qibla_images/stronglineInner.svg',
                              ),
                              SvgPicture.asset(
                                'assets/qibla_images/innerline1.svg',
                              ),
                              SvgPicture.asset(
                                'assets/qibla_images/innerline.svg',
                              ),
                              SvgPicture.asset(
                                'assets/qibla_images/outerline.svg',
                              ),

                              // Rotating Compass Needle
                              Transform.rotate(
                                angle: angle,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/qibla_images/backNeedleShell.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/needle2.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/needle1.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/sideNeedleShell.svg',
                                    ),

                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                        offset: const Offset(-67, 0),
                                        child: SvgPicture.asset(
                                          'assets/qibla_images/needle3.svg',
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                        offset: const Offset(62, 0),
                                        child: SvgPicture.asset(
                                          'assets/qibla_images/needle4.svg',
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/dottedcircle.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/greencircle.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/blackcircle.svg',
                                    ),
                                    SvgPicture.asset(
                                      'assets/qibla_images/backShellMainNeedle.svg',
                                    ),

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Transform.translate(
                                        offset: const Offset(153.5, 66),
                                        child: SvgPicture.asset(
                                          'assets/qibla_images/mainNeedle2.svg',
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Transform.translate(
                                        offset: const Offset(-154, -66),
                                        child: SvgPicture.asset(
                                          'assets/qibla_images/mainNeedle1.svg',
                                        ),
                                      ),
                                    ),

                                    SvgPicture.asset(
                                      'assets/qibla_images/mainpoint.svg',
                                    ),
                                    Positioned(
                                      top: -6,
                                      child: Image.asset(
                                        'assets/qibla_images/qiblaDirection.png',
                                        height: 55,
                                        filterQuality: FilterQuality.high,
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
}
