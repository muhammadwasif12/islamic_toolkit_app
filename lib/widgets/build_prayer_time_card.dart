import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/time_format_provider.dart';

class PrayerTimeCard extends ConsumerWidget {
  final String name;
  final DateTime time;
  final String iconPath;
  final bool isNext;

  const PrayerTimeCard({
    super.key,
    required this.name,
    required this.time,
    required this.iconPath,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(use24HourFormatProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = _getResponsiveWidth(screenHeight, 65, 70, 75);
    final iconSize = _getResponsiveSize(screenHeight, 20, 24, 28);
    final nameSize = _getResponsiveSize(screenHeight, 10, 11, 12);
    final timeSize = _getResponsiveSize(screenHeight, 9, 10, 11);

    // Format time parts
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? "PM" : "AM";
    final full24Hour = "${time.hour.toString().padLeft(2, '0')}:$minute";

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            color: isNext ? Colors.amber : Colors.white,
          ),

          const SizedBox(height: 8),

          // Prayer Name
          Text(
            name,
            style: TextStyle(
              fontSize: nameSize,
              fontWeight: FontWeight.bold,
              color: isNext ? Colors.amber : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Time + AM/PM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child:
                use24Hour
                    ? Text(
                      full24Hour,
                      style: TextStyle(
                        fontSize: timeSize,
                        fontWeight: FontWeight.bold,
                        color: isNext ? Colors.amber : Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$hour:$minute",
                          style: TextStyle(
                            fontSize: timeSize,
                            fontWeight: FontWeight.bold,
                            color: isNext ? Colors.amber : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            ampm,
                            style: TextStyle(
                              fontSize: timeSize * 0.6,
                              fontWeight: FontWeight.w600,
                              color: isNext ? Colors.amber : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  double _getResponsiveWidth(
    double screenHeight,
    double small,
    double medium,
    double large,
  ) {
    if (screenHeight < 650) return small;
    if (screenHeight < 750) return medium;
    return large;
  }

  double _getResponsiveSize(
    double screenHeight,
    double small,
    double medium,
    double large,
  ) {
    if (screenHeight < 650) return small;
    if (screenHeight < 750) return medium;
    return large;
  }
}
