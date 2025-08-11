import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/main_screen.dart';
import 'package:islamic_toolkit_app/services/admob_service.dart';
import 'package:islamic_toolkit_app/view_model/ad_manager_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _opacity = 0.0;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted || _hasNavigated) return;

      _hasNavigated = true;

      AdMobService.instance.markFirstLaunchComplete();
      ref.read(adManagerProvider.notifier).markFirstLaunchComplete();

      await ref.read(adManagerProvider.notifier).forceShowAppOpenAd();

      if (mounted) {
        _navigateToMainScreen();
      }
    } catch (e) {
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        AdMobService.instance.markFirstLaunchComplete();
        _navigateToMainScreen();
      }
    }
  }

  void _navigateToMainScreen() {
    if (!mounted) return;

    try {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const MainScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 30,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _opacity,
              curve: Curves.easeInOut,
              child: SvgPicture.asset(
                'assets/splash_images/icon1.svg',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _opacity,
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/splash_images/icon.svg',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _opacity,
                child: const Text(
                  'Copyright @ Islamic Daily',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
