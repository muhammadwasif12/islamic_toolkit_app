import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

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

  // Pre-calculated weekdays to avoid repeated creation
  static const weekdays = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  // Pre-calculated common shadows to avoid repeated creation
  static const commonShadow = [
    BoxShadow(color: Colors.white, blurRadius: 5, offset: Offset(-3, -3)),
    BoxShadow(
      color: Color(0x33808080), // Pre-calculated grey with opacity
      blurRadius: 5,
      offset: Offset(3, 3),
    ),
  ];

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
          const BoxShadow(
            color: Color(0xE6FFFFFF), // Pre-calculated white with opacity
            blurRadius: 15,
            offset: Offset(-5, -5),
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
            mainAxisSize: MainAxisSize.min, // Optimize column size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optimized month header
              _buildMonthHeader(),
              const SizedBox(height: 20),
              // Optimized weekday headers
              _buildWeekdayHeaders(),
              const SizedBox(height: 12),
              // Optimized calendar days without heavy animations
              _buildCalendarDays(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // Pre-calculated black with opacity
            blurRadius: 10,
            offset: Offset(3, 3),
          ),
          BoxShadow(
            color: Color(0x80FFFFFF), // Pre-calculated white with opacity
            blurRadius: 10,
            offset: Offset(-3, -3),
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
    );
  }

  Widget _buildWeekdayHeaders() {
    return SizedBox(
      height: 30, // Fixed height to avoid layout calculations
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            weekdays
                .map(
                  (weekday) => Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarDays() {
    // Pre-calculate today values to avoid repeated comparisons
    final todayDay = today.hDay;
    final todayMonth = today.hMonth;
    final todayYear = today.hYear;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: monthDays.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0, // Fixed aspect ratio for consistent layout
      ),
      itemBuilder: (context, index) {
        final hDay = monthDays[index];
        final isToday =
            (hDay.hDay == todayDay &&
                hDay.hMonth == todayMonth &&
                hDay.hYear == todayYear);

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? null : lightColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isToday ? null : commonShadow,
            gradient:
                isToday
                    ? LinearGradient(
                      colors: [primaryColor, accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: Text(
            hDay.hDay.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : textColor,
            ),
          ),
        );
      },
    );
  }
}
