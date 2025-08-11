// lib/view_model/ad_manager_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admob_service.dart';

// Ad Manager State
class AdManagerState {
  final bool isAppOpenAdLoaded;
  final bool isInterstitialAdLoaded;
  final DateTime? lastAppOpenAdShown;
  final int tasbeehCompletionCount;

  const AdManagerState({
    this.isAppOpenAdLoaded = false,
    this.isInterstitialAdLoaded = false,
    this.lastAppOpenAdShown,
    this.tasbeehCompletionCount = 0,
  });

  AdManagerState copyWith({
    bool? isAppOpenAdLoaded,
    bool? isInterstitialAdLoaded,
    DateTime? lastAppOpenAdShown,
    int? tasbeehCompletionCount,
  }) {
    return AdManagerState(
      isAppOpenAdLoaded: isAppOpenAdLoaded ?? this.isAppOpenAdLoaded,
      isInterstitialAdLoaded: isInterstitialAdLoaded ?? this.isInterstitialAdLoaded,
      lastAppOpenAdShown: lastAppOpenAdShown ?? this.lastAppOpenAdShown,
      tasbeehCompletionCount: tasbeehCompletionCount ?? this.tasbeehCompletionCount,
    );
  }
}

// Ad Manager Notifier
class AdManagerNotifier extends StateNotifier<AdManagerState> {
  AdManagerNotifier() : super(const AdManagerState()) {
    _initialize();
  }

  final AdMobService _adMobService = AdMobService.instance;

  // Initialize ads
  Future<void> _initialize() async {
    await _loadAppOpenAd();
    await _loadInterstitialAd();
  }

  // Load App Open Ad
  Future<void> _loadAppOpenAd() async {
    try {
      await _adMobService.loadAppOpenAd();
      state = state.copyWith(isAppOpenAdLoaded: _adMobService.isAppOpenAdAvailable);
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading App Open Ad: $e');
    }
  }

  // Load Interstitial Ad
  Future<void> _loadInterstitialAd() async {
    try {
      await _adMobService.loadInterstitialAd();
      state = state.copyWith(isInterstitialAdLoaded: _adMobService.isInterstitialAdAvailable);
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading Interstitial Ad: $e');
    }
  }

  // Show App Open Ad after splash (Every app launch)
  Future<void> showAppOpenAdAfterSplash() async {
    if (!state.isAppOpenAdLoaded) {
      await _loadAppOpenAd();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      await _adMobService.showAppOpenAd(
        onAdClosed: () {
          state = state.copyWith(
            lastAppOpenAdShown: DateTime.now(),
            isAppOpenAdLoaded: false,
          );
          Future.delayed(const Duration(seconds: 2), _loadAppOpenAd);
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error showing App Open Ad: $e');
    }
  }

  // Show Interstitial Ad on Tasbeeh completion
  Future<void> showInterstitialAdOnTasbeehCompletion() async {
    final newCount = state.tasbeehCompletionCount + 1;
    state = state.copyWith(tasbeehCompletionCount: newCount);

    // Show ad every 2nd completion
    if (newCount % 2 == 0) {
      if (!state.isInterstitialAdLoaded) {
        await _loadInterstitialAd();
      }

      try {
        await _adMobService.showInterstitialAd(
          onAdClosed: () {
            state = state.copyWith(isInterstitialAdLoaded: false);
            _loadInterstitialAd();
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error showing Interstitial Ad: $e');
      }
    }
  }

  // Force show app open ad (for testing)
  Future<void> forceShowAppOpenAd() async {    
    if (!state.isAppOpenAdLoaded) {
      await _loadAppOpenAd();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      await _adMobService.showAppOpenAd(
        forceShow: true,
        onAdClosed: () {
          state = state.copyWith(
            lastAppOpenAdShown: DateTime.now(),
            isAppOpenAdLoaded: false,
          );
          _loadAppOpenAd();
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error force showing App Open Ad: $e');
    }
  }

  // Refresh ads
  Future<void> refreshAds() async {
    await _loadAppOpenAd();
    await _loadInterstitialAd();
  }

  // Reset Tasbeeh count
  void resetTasbeehCount() {
    state = state.copyWith(tasbeehCompletionCount: 0);
  }

  // Mark first launch complete
  void markFirstLaunchComplete() {
    _adMobService.markFirstLaunchComplete();
  }
}

// Providers
final adManagerProvider = StateNotifierProvider<AdManagerNotifier, AdManagerState>((ref) {
  return AdManagerNotifier();
});

final shouldShowBannerAdsProvider = Provider<bool>((ref) => true);

final appOpenAdLoadedProvider = Provider<bool>((ref) {
  return ref.watch(adManagerProvider).isAppOpenAdLoaded;
});

final interstitialAdLoadedProvider = Provider<bool>((ref) {
  return ref.watch(adManagerProvider).isInterstitialAdLoaded;
});