import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../view_model/counter_state_provider.dart';
import '../view_model/ad_manager_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/vibration_dialog.dart';
import '../widgets/banner_ad_widget.dart'; // Import the banner ad widget

class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  bool _hasShownVibrationDialog = false; // Track if dialog has been shown
  bool _wasCompleted = false; // Track previous completion state

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnimation(bool isCompleted) {
    // Only trigger animation and ad if completion state just changed to true
    if (isCompleted && !_wasCompleted) {
      _controller.forward(from: 0);
      // Delay the ad showing to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInterstitialAdOnCompletion();
      });
    } else if (!isCompleted) {
      _controller.reset();
    }

    _wasCompleted = isCompleted;
  }

  // Show interstitial ad on tasbeeh completion
  Future<void> _showInterstitialAdOnCompletion() async {
    try {
      await ref
          .read(adManagerProvider.notifier)
          .showInterstitialAdOnTasbeehCompletion();
      debugPrint('🟢 Interstitial ad triggered on tasbeeh completion');
    } catch (e) {
      debugPrint('🔴 Error showing interstitial ad: $e');
    }
  }

  // Enhanced vibration check and dialog method
  Future<void> _handleVibrationCheck() async {
    // Check vibration status first
    final vibrationStatus =
        await ref.read(counterProvider.notifier).checkVibrationForUI();

    // Show dialog if vibration is not working and dialog hasn't been shown yet
    if (!_hasShownVibrationDialog &&
        vibrationStatus != VibrationStatus.working) {
      _hasShownVibrationDialog = true;

      showVibrationDialog(context, vibrationStatus);

      return;
    }

    // Proceed with increment and vibration
    await ref.read(counterProvider.notifier).increment(ref);
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);
    final isCompleted = ref.watch(tasbeehCompletedProvider);
    final completedTasbeehCount = ref.watch(completedTasbeehCountProvider);
    final tasbeehMode = ref.watch(tasbeehModeProvider);

    // Check animation after build is complete to avoid provider modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAnimation(isCompleted);
    });

    return Scaffold(
      appBar: CustomAppBar(title: tr('tasbeeh_counter')),
      backgroundColor: const Color(0xffFDFCF7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  // Top section with increased height for larger banner
                  Container(
                    height: 160, // Increased from 115 to 160
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12, // Increased padding
                    ),
                    alignment: Alignment.center,
                    child:
                        isCompleted
                            ? FadeTransition(
                              opacity: _fadeIn,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4DB896,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF4DB896),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  tr("tasbeeh_completed"),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                    fontFamily: 'Mycustomfont',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            )
                            : Container(
                              width: 320, // Increased from 280 to 350
                              child: SvgPicture.asset(
                                'assets/qibla_images/Al-Fatihah.svg',
                                height: 130, // Increased from 100 to 135
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                  ),

                  // Tasbeeh Mode Selection  Switches
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 33 Button
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // Use addPostFrameCallback to avoid modifying provider during build
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  ref
                                      .read(tasbeehModeProvider.notifier)
                                      .setMode(33);
                                  ref.read(counterProvider.notifier).reset();
                                  ref
                                      .read(tasbeehCompletedProvider.notifier)
                                      .state = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    tasbeehMode == 33
                                        ? const Color(0xFF4DB896)
                                        : Colors.grey[300],
                                foregroundColor:
                                    tasbeehMode == 33
                                        ? Colors.white
                                        : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 1,
                              ),
                              child: const Text(
                                "33",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 99 Button
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 12),
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // Use addPostFrameCallback to avoid modifying provider during build
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  ref
                                      .read(tasbeehModeProvider.notifier)
                                      .setMode(99);
                                  ref.read(counterProvider.notifier).reset();
                                  ref
                                      .read(tasbeehCompletedProvider.notifier)
                                      .state = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    tasbeehMode == 99
                                        ? const Color(0xFF4DB896)
                                        : Colors.grey[300],
                                foregroundColor:
                                    tasbeehMode == 99
                                        ? Colors.white
                                        : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 1,
                              ),
                              child: const Text(
                                "99",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Completed Tasbeeh Count Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DB896).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF4DB896).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${tr('tasbeeh')}: $completedTasbeehCount',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                            fontFamily: 'Mycustomfont',
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Counter UI - Main Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Counter Circle
                          GestureDetector(
                            onTap: _handleVibrationCheck,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF52C4A0),
                                    Color(0xFF4DB896),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 6,
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/home_images/islamic.png',
                                    ),
                                    fit: BoxFit.cover,
                                    opacity: 0.9,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF52C4A0).withOpacity(0.8),
                                      const Color(0xFF4DB896).withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$counter',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[700],
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${tr('of')} $tasbeehMode',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Progress bar
                          Container(
                            width: double.infinity,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (counter / tasbeehMode).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF52C4A0),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 38,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(counterProvider.notifier)
                                          .reset();
                                      _hasShownVibrationDialog =
                                          false; // Reset dialog flag
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.grey[700],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      tr('reset'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  height: 38,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _handleVibrationCheck,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[600],
                                      foregroundColor: Colors.black,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      shadowColor: Colors.amber.withOpacity(
                                        0.4,
                                      ),
                                    ),
                                    child: Text(
                                      tr('vibrate'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Banner Ad below the buttons
                          const SizedBox(
                            height: 6,
                          ), // Small space between buttons and ad
                          const CounterBannerAd(), // Add the banner ad here
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
