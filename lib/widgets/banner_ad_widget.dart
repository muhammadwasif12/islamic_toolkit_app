import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final bool showCloseButton;
  final String? dismissKey;
  final Duration? dismissDuration;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.showCloseButton = true,
    this.dismissKey,
    this.dismissDuration = const Duration(minutes: 30),
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _checkDismissStatus();
  }

  Future<void> _checkDismissStatus() async {
    if (widget.dismissKey == null) {
      _loadBannerAd();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissedTime = prefs.getInt('banner_dismissed_${widget.dismissKey}');

    if (dismissedTime != null) {
      final dismissedDateTime = DateTime.fromMillisecondsSinceEpoch(
        dismissedTime,
      );
      final now = DateTime.now();

      if (widget.dismissDuration != null &&
          now.difference(dismissedDateTime) < widget.dismissDuration!) {
        setState(() {
          _isDismissed = true;
        });
        return;
      } else {
        await prefs.remove('banner_dismissed_${widget.dismissKey}');
      }
    }

    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (_isAdLoading || _bannerAd != null || _isDismissed) return;

    _isAdLoading = true;

    _bannerAd = BannerAd(
      adUnitId: AdMobService.instance.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
              _isAdLoading = false;
            });
          }
        },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
      ),
    );

    _bannerAd!.load();
  }

  Future<void> _dismissAd() async {
    if (widget.dismissKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'banner_dismissed_${widget.dismissKey}',
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    setState(() {
      _isDismissed = true;
    });

    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: SizedBox(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
          if (widget.showCloseButton)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _dismissAd,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Home Screen Banner Ad
class HomeBannerAd extends StatelessWidget {
  const HomeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.banner,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 8,
      ),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.white.withOpacity(0.9),
      showCloseButton: true,
      dismissKey: 'home_banner',
      dismissDuration: const Duration(minutes: 30),
    );
  }
}

// Settings Screen Large Banner Ad
class SettingsLargeBannerAd extends StatelessWidget {
  const SettingsLargeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.largeBanner,
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.white,
      showCloseButton: true,
      dismissKey: 'settings_large_banner',
      dismissDuration: const Duration(minutes: 30),
    );
  }
}
