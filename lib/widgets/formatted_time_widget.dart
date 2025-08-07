import 'package:flutter/material.dart';

class FormattedTimeWidget extends StatelessWidget {
  final DateTime time;
  final bool use24Hour;
  final double Function(double) getResponsiveFontSize;

  const FormattedTimeWidget({
    Key? key,
    required this.time,
    required this.use24Hour,
    required this.getResponsiveFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (use24Hour) {
      return Text(
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
        style: TextStyle(
          color: Colors.amber,
          fontSize: getResponsiveFontSize(40),
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final ampm = time.hour >= 12 ? "PM" : "AM";

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$hour:$minute",
            style: TextStyle(
              color: Colors.amber,
              fontSize: getResponsiveFontSize(40),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              ampm,
              style: TextStyle(
                color: Colors.amber,
                fontSize: getResponsiveFontSize(16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }
  }
}
