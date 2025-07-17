import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/views/home_screen.dart';
import 'package:islamic_toolkit_app/views/qibla_screen.dart';
import 'package:islamic_toolkit_app/views/duas_screen.dart';
import 'package:islamic_toolkit_app/views/counter_screen.dart';
import 'package:islamic_toolkit_app/views/settings_screen.dart';
import 'package:islamic_toolkit_app/view_model/selected_index_provider.dart';
import 'package:islamic_toolkit_app/view_model/prayer_times_provider.dart';
import 'package:islamic_toolkit_app/widgets/build_nav_item.dart';
import 'package:easy_localization/easy_localization.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    final List<Widget> screens = const [
      HomeScreen(),
      QiblaScreen(),
      DuasScreen(),
      CounterScreen(),
      SettingsScreen(),
    ];

    final bool hideNavBarForHome =
        selectedIndex == 0 &&
        (prayerTimesAsync.isLoading || prayerTimesAsync.hasError);

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar:
          hideNavBarForHome
              ? null
              : Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        NavItemWidget(
                          iconPath: 'assets/home_images/home1.png',
                          label: "home".tr(),
                          index: 0,
                        ),
                        NavItemWidget(
                          iconPath: 'assets/home_images/qibla1.png',
                          label: "qibla".tr(),
                          index: 1,
                        ),
                        NavItemWidget(
                          iconPath: 'assets/home_images/dua1.png',
                          label: "duas".tr(),
                          index: 2,
                        ),
                        NavItemWidget(
                          iconPath: 'assets/home_images/counter1.png',
                          label: "counter".tr(),
                          index: 3,
                        ),
                        NavItemWidget(
                          iconPath: 'assets/home_images/setting1.png',
                          label: "settings".tr(),
                          index: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
    );
  }
}
