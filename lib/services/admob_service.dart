// lib/services/admob_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  // YOUR REAL Ad Unit IDs (Replace with your actual IDs from AdMob Console)
  static const String _realBannerAdUnitId = 'YOUR_BANNER_UNIT_ID_HERE';
  static const String _realAppOpenAdUnitId = 'YOUR_APP_OPEN_UNIT_ID_HERE';
  static const String _realInterstitialAdUnitId =
      'YOUR_INTERSTITIAL_UNIT_ID_HERE';

  // Test Ad Unit IDs
  static String get _testBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get _testAppOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5662855259';
    }
    return 'ca-app-pub-3940256099942544/9257395921';
  }

  static String get _testInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  // Ad instances
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  bool _isAppOpenAdLoading = false;
  bool _isInterstitialAdLoading = false;
  DateTime? _appOpenLoadTime;
  int _appOpenAdLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  // App lifecycle tracking
  DateTime? _lastBackgroundTime;
  bool _isFirstLaunch = true;
  bool _hasShownFirstAd = false;
  static const Duration _backgroundThreshold = Duration(seconds: 30);

  // Initialize AdMob
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      await instance.loadAppOpenAd();
    } catch (e) {
      // Silent error handling
    }
  }

  // Get Ad Unit IDs
  String get bannerAdUnitId =>
      kDebugMode ? _testBannerAdUnitId : _realBannerAdUnitId;
  String get appOpenAdUnitId =>
      kDebugMode ? _testAppOpenAdUnitId : _realAppOpenAdUnitId;
  String get interstitialAdUnitId =>
      kDebugMode ? _testInterstitialAdUnitId : _realInterstitialAdUnitId;

  // Load App Open Ad
  Future<void> loadAppOpenAd() async {
    if (_isAppOpenAdLoading ||
        _appOpenAd != null ||
        _appOpenAdLoadAttempts >= _maxLoadAttempts) {
      return;
    }

    _isAppOpenAdLoading = true;
    _appOpenAdLoadAttempts++;

    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _appOpenLoadTime = DateTime.now();
            _isAppOpenAdLoading = false;
            _appOpenAdLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            _isAppOpenAdLoading = false;

            // Retry logic based on error type
            int retryDelay = 5;
            switch (error.code) {
              case 0:
                retryDelay = 10;
                break;
              case 2:
                retryDelay = 5;
                break;
              case 3:
                retryDelay = 30;
                break;
              default:
                retryDelay = 15;
                break;
            }

            if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
              Future.delayed(Duration(seconds: retryDelay), loadAppOpenAd);
            }
          },
        ),
      );
    } catch (e) {
      _isAppOpenAdLoading = false;
      if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
        Future.delayed(const Duration(seconds: 5), loadAppOpenAd);
      }
    }
  }

  // Show App Open Ad
  Future<void> showAppOpenAd({
    VoidCallback? onAdClosed,
    bool forceShow = false,
  }) async {
    // Don't show ad on absolute first launch unless forced
    if (_isFirstLaunch && !forceShow) {
      onAdClosed?.call();
      return;
    }

    // Check if enough time has passed since background (unless forced)
    if (_lastBackgroundTime != null && !forceShow) {
      final timeSinceBackground = DateTime.now().difference(
        _lastBackgroundTime!,
      );
      if (timeSinceBackground < _backgroundThreshold) {
        onAdClosed?.call();
        return;
      }
    }

    // Mark that we're showing an ad
    if (!_hasShownFirstAd && !_isFirstLaunch) {
      _hasShownFirstAd = true;
    }

    if (_appOpenAd == null) {
      if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
        await loadAppOpenAd();
        int waitTime = 0;
        while (_isAppOpenAdLoading && waitTime < 5000) {
          await Future.delayed(const Duration(milliseconds: 100));
          waitTime += 100;
        }
      }

      if (_appOpenAd == null) {
        onAdClosed?.call();
        return;
      }
    }

    // Check if ad is too old (4 hours)
    if (_appOpenLoadTime != null) {
      final timeSinceLoad = DateTime.now().difference(_appOpenLoadTime!);
      if (timeSinceLoad.inHours >= 4) {
        _appOpenAd?.dispose();
        _appOpenAd = null;
        await loadAppOpenAd();
        onAdClosed?.call();
        return;
      }
    }

    try {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {},
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), () {
            _appOpenAdLoadAttempts = 0;
            loadAppOpenAd();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), () {
            _appOpenAdLoadAttempts = 0;
            loadAppOpenAd();
          });
        },
      );

      await _appOpenAd!.show();
    } catch (e) {
      onAdClosed?.call();
    }
  }

  // Load Interstitial Ad
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;

    _isInterstitialAdLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoading = false;
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoading = false;
    }
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (_interstitialAd == null) {
      onAdClosed?.call();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {},
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      onAdClosed?.call();
    }
  }

  // Status checks
  bool get isAppOpenAdAvailable => _appOpenAd != null;
  bool get isInterstitialAdAvailable => _interstitialAd != null;
  bool get isAppOpenAdLoading => _isAppOpenAdLoading;
  bool get isInterstitialAdLoading => _isInterstitialAdLoading;

  void resetAppOpenAdAttempts() => _appOpenAdLoadAttempts = 0;

  // App lifecycle methods
  void onAppBackground() {
    _lastBackgroundTime = DateTime.now();
    if (_isFirstLaunch) _isFirstLaunch = false;
  }

  void onAppForeground() {
    if (_isFirstLaunch) _isFirstLaunch = false;
  }

  void onAppResumed() {
    if (_isFirstLaunch) _isFirstLaunch = false;
  }

  void onAppPaused() {}

  void markFirstLaunchComplete() => _isFirstLaunch = false;

  // Getters for app state
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasShownFirstAd => _hasShownFirstAd;
  DateTime? get lastBackgroundTime => _lastBackgroundTime;
  Duration get backgroundThreshold => _backgroundThreshold;

  // Dispose
  void dispose() {
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd = null;
    _interstitialAd = null;
    _appOpenAdLoadAttempts = 0;
    _lastBackgroundTime = null;
    _isFirstLaunch = true;
    _hasShownFirstAd = false;
  }
}
