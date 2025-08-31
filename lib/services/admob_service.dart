// lib/services/admob_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  // Check if dotenv is initialized and get ad unit IDs - ONLY from ENV
  static String get _envBannerAdUnitId {
    try {
      return dotenv.isInitialized
          ? (dotenv.env['BANNER_AD_UNIT_ID'] ?? '')
          : '';
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing BANNER_AD_UNIT_ID: $e');
      }
      return '';
    }
  }

  static String get _envAppOpenAdUnitId {
    try {
      return dotenv.isInitialized
          ? (dotenv.env['APP_OPEN_AD_UNIT_ID'] ?? '')
          : '';
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing APP_OPEN_AD_UNIT_ID: $e');
      }
      return '';
    }
  }

  static String get _envInterstitialAdUnitId {
    try {
      return dotenv.isInitialized
          ? (dotenv.env['INTERSTITIAL_AD_UNIT_ID'] ?? '')
          : '';
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing INTERSTITIAL_AD_UNIT_ID: $e');
      }
      return '';
    }
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

  // AdMob initialization status
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Initialize AdMob with better error handling
  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('AdMob already initialized');
      }
      return;
    }

    try {
      // Initialize with request configuration
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds:
            kDebugMode
                ? ['TEST_DEVICE_ID']
                : null, // Add your test device ID here
      );

      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      _isInitialized = true;

      if (kDebugMode) {
        print('AdMob initialized successfully');
        print('Banner Ad Unit ID: ${instance.bannerAdUnitId}');
        print('App Open Ad Unit ID: ${instance.appOpenAdUnitId}');
        print('Interstitial Ad Unit ID: ${instance.interstitialAdUnitId}');
      }

      // Load first ads after successful initialization
      await Future.wait([
        instance.loadAppOpenAd(),
        instance.loadInterstitialAd(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('AdMob initialization error: $e');
      }
      _isInitialized = false;
    }
  }

  // Get Ad Unit IDs - ONLY from environment variables
  String get bannerAdUnitId {
    final envId = _envBannerAdUnitId;
    if (kDebugMode) {
      print('Banner Ad Unit ID from env: $envId');
    }
    return envId;
  }

  String get appOpenAdUnitId {
    final envId = _envAppOpenAdUnitId;
    if (kDebugMode) {
      print('App Open Ad Unit ID from env: $envId');
    }
    return envId;
  }

  String get interstitialAdUnitId {
    final envId = _envInterstitialAdUnitId;
    if (kDebugMode) {
      print('Interstitial Ad Unit ID from env: $envId');
    }
    return envId;
  }

  // Load App Open Ad with improved error handling
  Future<void> loadAppOpenAd() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('❌ AdMob not initialized, cannot load App Open Ad');
      }
      return;
    }

    if (_isAppOpenAdLoading ||
        _appOpenAd != null ||
        _appOpenAdLoadAttempts >= _maxLoadAttempts) {
      if (kDebugMode) {
        print(
          '⏭️ Skipping App Open Ad load - already loading/loaded or max attempts reached',
        );
      }
      return;
    }

    _isAppOpenAdLoading = true;
    _appOpenAdLoadAttempts++;

    if (kDebugMode) {
      print('🔄 Loading App Open Ad (Attempt $_appOpenAdLoadAttempts)...');
    }

    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('✅ App Open Ad loaded successfully');
            }
            _appOpenAd = ad;
            _appOpenLoadTime = DateTime.now();
            _isAppOpenAdLoading = false;
            _appOpenAdLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print(
                '❌ App Open Ad failed to load: ${error.message} (Code: ${error.code})',
              );
            }
            _isAppOpenAdLoading = false;

            // Retry logic based on error type
            int retryDelay = _getRetryDelay(error.code);

            if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
              if (kDebugMode) {
                print('🔄 Retrying App Open Ad in ${retryDelay}s...');
              }
              Future.delayed(Duration(seconds: retryDelay), loadAppOpenAd);
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ App Open Ad load exception: $e');
      }
      _isAppOpenAdLoading = false;
      if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
        Future.delayed(const Duration(seconds: 5), loadAppOpenAd);
      }
    }
  }

  // Get retry delay based on error code
  int _getRetryDelay(int errorCode) {
    switch (errorCode) {
      case 0: // ERROR_CODE_INTERNAL_ERROR
        return 10;
      case 1: // ERROR_CODE_INVALID_REQUEST
        return 30;
      case 2: // ERROR_CODE_NETWORK_ERROR
        return 5;
      case 3: // ERROR_CODE_NO_FILL
        return 30;
      case 8: // ERROR_CODE_REQUEST_ID_MISMATCH
        return 15;
      default:
        return 15;
    }
  }

  // Show App Open Ad with improved logic
  Future<void> showAppOpenAd({
    VoidCallback? onAdClosed,
    bool forceShow = false,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('❌ AdMob not initialized, cannot show App Open Ad');
      }
      onAdClosed?.call();
      return;
    }

    // Don't show ad on absolute first launch unless forced
    if (_isFirstLaunch && !forceShow) {
      if (kDebugMode) {
        print('⏭️ Skipping App Open Ad - First launch');
      }
      onAdClosed?.call();
      return;
    }

    // Check if enough time has passed since background (unless forced)
    if (_lastBackgroundTime != null && !forceShow) {
      final timeSinceBackground = DateTime.now().difference(
        _lastBackgroundTime!,
      );
      if (timeSinceBackground < _backgroundThreshold) {
        if (kDebugMode) {
          print('⏭️ Skipping App Open Ad - Not enough time since background');
        }
        onAdClosed?.call();
        return;
      }
    }

    // Mark that we're showing an ad
    if (!_hasShownFirstAd && !_isFirstLaunch) {
      _hasShownFirstAd = true;
    }

    if (_appOpenAd == null) {
      if (kDebugMode) {
        print('⚠️ App Open Ad not available, attempting to load...');
      }

      if (_appOpenAdLoadAttempts < _maxLoadAttempts) {
        await loadAppOpenAd();
        int waitTime = 0;
        while (_isAppOpenAdLoading && waitTime < 5000) {
          await Future.delayed(const Duration(milliseconds: 100));
          waitTime += 100;
        }
      }

      if (_appOpenAd == null) {
        if (kDebugMode) {
          print('❌ App Open Ad still not available after loading attempt');
        }
        onAdClosed?.call();
        return;
      }
    }

    // Check if ad is too old (4 hours)
    if (_appOpenLoadTime != null) {
      final timeSinceLoad = DateTime.now().difference(_appOpenLoadTime!);
      if (timeSinceLoad.inHours >= 4) {
        if (kDebugMode) {
          print('⏰ App Open Ad expired, disposing and reloading');
        }
        _appOpenAd?.dispose();
        _appOpenAd = null;
        await loadAppOpenAd();
        onAdClosed?.call();
        return;
      }
    }

    try {
      if (kDebugMode) {
        print('📱 Showing App Open Ad...');
      }

      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('✅ App Open Ad showed full screen content');
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('✅ App Open Ad dismissed');
          }
          ad.dispose();
          _appOpenAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), () {
            _appOpenAdLoadAttempts = 0;
            loadAppOpenAd();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            print('❌ App Open Ad failed to show: ${error.message}');
          }
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
      if (kDebugMode) {
        print('❌ Error showing App Open Ad: $e');
      }
      onAdClosed?.call();
    }
  }

  // Load Interstitial Ad with improved error handling
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('❌ AdMob not initialized, cannot load Interstitial Ad');
      }
      return;
    }

    if (_isInterstitialAdLoading || _interstitialAd != null) {
      if (kDebugMode) {
        print('⏭️ Skipping Interstitial Ad load - already loading/loaded');
      }
      return;
    }

    _isInterstitialAdLoading = true;

    if (kDebugMode) {
      print('🔄 Loading Interstitial Ad...');
    }

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('✅ Interstitial Ad loaded successfully');
            }
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print(
                '❌ Error loading Interstitial Ad: ${error.message} (Code: ${error.code})',
              );
            }
            _isInterstitialAdLoading = false;

            // Retry after delay for certain error codes
            if (error.code == 2 || error.code == 3) {
              // Network error or no fill
              Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Interstitial Ad load exception: $e');
      }
      _isInterstitialAdLoading = false;
    }
  }

  // Show Interstitial Ad with improved error handling
  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('❌ AdMob not initialized, cannot show Interstitial Ad');
      }
      onAdClosed?.call();
      return;
    }

    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('⚠️ Interstitial Ad not available, attempting to load...');
      }
      await loadInterstitialAd();

      // Wait a bit for the ad to load
      int waitTime = 0;
      while (_isInterstitialAdLoading && waitTime < 3000) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitTime += 100;
      }

      if (_interstitialAd == null) {
        if (kDebugMode) {
          print('❌ Interstitial Ad still not available after loading attempt');
        }
        onAdClosed?.call();
        return;
      }
    }

    try {
      if (kDebugMode) {
        print('📱 Showing Interstitial Ad...');
      }

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('✅ Interstitial Ad showed full screen content');
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('✅ Interstitial Ad dismissed');
          }
          ad.dispose();
          _interstitialAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            print('❌ Interstitial Ad failed to show: ${error.message}');
          }
          ad.dispose();
          _interstitialAd = null;
          onAdClosed?.call();
          Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Interstitial Ad show exception: $e');
      }
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
    if (kDebugMode) {
      print('📱 App went to background');
    }
  }

  void onAppForeground() {
    if (_isFirstLaunch) _isFirstLaunch = false;
    if (kDebugMode) {
      print('📱 App came to foreground');
    }
  }

  void onAppResumed() {
    if (_isFirstLaunch) _isFirstLaunch = false;
    if (kDebugMode) {
      print('📱 App resumed');
    }
  }

  void onAppPaused() {
    if (kDebugMode) {
      print('📱 App paused');
    }
  }

  void markFirstLaunchComplete() {
    _isFirstLaunch = false;
    if (kDebugMode) {
      print('✅ First launch marked as complete');
    }
  }

  // Getters for app state
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasShownFirstAd => _hasShownFirstAd;
  DateTime? get lastBackgroundTime => _lastBackgroundTime;
  Duration get backgroundThreshold => _backgroundThreshold;

  // Dispose
  void dispose() {
    if (kDebugMode) {
      print('🗑️ Disposing AdMob Service');
    }
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
