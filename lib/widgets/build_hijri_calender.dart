import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:islamic_toolkit_app/widgets/custom_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/neumorphic_calender_month.dart';

class FullReadOnlyHijriCalendar extends StatelessWidget {
  const FullReadOnlyHijriCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal("ar");

    final today = HijriCalendar.now();
    final primaryColor = const Color(0xFF3EB489);
    final accentColor = const Color(0xFF2D8B6B);
    final lightColor = const Color(0xFFE8F5F1);
    final backgroundColor = const Color(0xFFF7F9F9);
    final textColor = const Color(0xFF333333);
    final shadowColor = Colors.black.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: tr("hijri_calendar")),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: 12,
          itemBuilder: (context, monthIndex) {
            final List<HijriCalendar> monthDays = [];
            final int currentYear = today.hYear;

            for (int day = 1; day <= 30; day++) {
              try {
                final hDate =
                    HijriCalendar()
                      ..hYear = currentYear
                      ..hMonth = monthIndex + 1
                      ..hDay = day;

                if (hDate.hMonth == monthIndex + 1) {
                  monthDays.add(hDate);
                }
              } catch (_) {
                break;
              }
            }

            final temp = HijriCalendar()..hMonth = monthIndex + 1;
            final isCurrentMonth = (monthIndex + 1 == today.hMonth);

            return AnimationConfiguration.staggeredList(
              position: monthIndex,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isCurrentMonth ? 8 : 12,
                    ),
                    child: NeumorphicCalendarMonth(
                      primaryColor: primaryColor,
                      accentColor: accentColor,
                      lightColor: lightColor,
                      textColor: textColor,
                      shadowColor: shadowColor,
                      monthName: '${temp.getLongMonthName()} $currentYear هـ',
                      isCurrentMonth: isCurrentMonth,
                      today: today,
                      monthDays: monthDays,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: AlwaysStoppedAnimation(1.0),
        child: FloatingActionButton(
          onPressed: () {
            final currentMonth = today.hMonth - 1;
            Scrollable.ensureVisible(
              context,
              alignment: 0.1,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutQuart,
            );
          },
          backgroundColor: primaryColor,
          elevation: 8,
          child: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ),
    );
  }
}
