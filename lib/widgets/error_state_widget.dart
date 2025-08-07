import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../view_model/prayer_times_provider.dart';
import '../view_model/location_service_provider.dart';

class ErrorStateWidget extends StatefulWidget {
  final Object error;
  final WidgetRef ref;

  const ErrorStateWidget({super.key, required this.error, required this.ref});

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(62, 180, 137, 1)),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/home_images/no_wifi.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                Text(
                  'unable_to_load_prayer'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.error.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap:
                      _loading
                          ? null
                          : () {
                            setState(() => _loading = true);
                            widget.ref.invalidate(locationServiceProvider);
                            widget.ref.invalidate(cityNameProvider);
                            widget.ref.invalidate(prayerTimesProvider);
                          },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF3EB489),
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF3EB489),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'retry'.tr(),
                                  style: const TextStyle(
                                    color: Color(0xFF3EB489),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
