// lib/widgets/banner_ad_widget.dart - Simplified Version

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner, this.margin});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  @override
  void initState() {
    super.initState();
    // Small delay to ensure AdMob is initialized
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  void _loadBannerAd() async {
    if (_isLoading || _loadAttempts >= _maxLoadAttempts) return;

    // Check if AdMob is initialized
    if (!AdMobService.isInitialized) {
      if (kDebugMode) print('AdMob not initialized yet');
      return;
    }

    final adUnitId = AdMobService.instance.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      if (kDebugMode) print('Banner Ad Unit ID is empty');
      return;
    }

    _isLoading = true;
    _loadAttempts++;

    if (kDebugMode) {
      print('Loading Banner Ad (Attempt $_loadAttempts) with ID: $adUnitId');
    }

    // Dispose previous ad
    _bannerAd?.dispose();
    _bannerAd = null;

    try {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: widget.adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) print('✅ Banner Ad loaded successfully');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('❌ Banner Ad failed: ${error.message} (${error.code})');
            }
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isLoading = false;
              });
              
              // Retry with delay if attempts remaining
              if (_loadAttempts < _maxLoadAttempts) {
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) _loadBannerAd();
                });
              }
            }
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      if (kDebugMode) print('Banner Ad exception: $e');
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show actual ad if loaded
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin,
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Show nothing if ad not loaded (clean approach)
    return const SizedBox.shrink();
  }
}

// Preset banner ads for different screens
class HomeBannerAd extends StatelessWidget {
  const HomeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget(
      adSize: AdSize.banner,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class SettingsLargeBannerAd extends StatelessWidget {
  const SettingsLargeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget(
      adSize: AdSize.largeBanner,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class DuaDetailBannerAd extends StatelessWidget {
  const DuaDetailBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget(
      adSize: AdSize.banner,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class CounterBannerAd extends StatelessWidget {
  const CounterBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget(
      adSize: AdSize.banner,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }
}