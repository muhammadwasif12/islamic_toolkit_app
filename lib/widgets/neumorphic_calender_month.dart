import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NeumorphicCalendarMonth extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final Color lightColor;
  final Color textColor;
  final Color shadowColor;
  final String monthName;
  final bool isCurrentMonth;
  final HijriCalendar today;
  final List<HijriCalendar> monthDays;

  const NeumorphicCalendarMonth({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.lightColor,
    required this.textColor,
    required this.shadowColor,
    required this.monthName,
    required this.isCurrentMonth,
    required this.today,
    required this.monthDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 15,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: const Color(0xFFF7F9F9),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Header with Neumorphic effect
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      isCurrentMonth ? primaryColor : accentColor,
                      isCurrentMonth ? accentColor : primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(3, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Weekday headers
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final weekdays = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Calendar days with beautiful animations
              AnimationLimiter(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthDays.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final hDay = monthDays[index];
                    final isToday =
                        (hDay.hDay == today.hDay &&
                            hDay.hMonth == today.hMonth &&
                            hDay.hYear == today.hYear);

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 7,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday ? primaryColor : lightColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (!isToday)
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 5,
                                    offset: const Offset(-3, -3),
                                  ),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                              gradient:
                                  isToday
                                      ? LinearGradient(
                                        colors: [primaryColor, accentColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  hDay.hDay.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isToday ? Colors.white : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
