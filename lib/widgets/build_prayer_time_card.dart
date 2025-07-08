import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimeCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final IconData icon;
  final bool isNext;

  const PrayerTimeCard({
    super.key,
    required this.name,
    required this.time,
    required this.icon,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: isNext ? Colors.orange : Colors.white,
            fontSize: 14,
            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isNext ? Colors.orange.withOpacity(0.3) : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isNext ? Colors.orange : Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            color: isNext ? Colors.orange : Colors.white,
            fontSize: 12,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
