import 'package:flutter/material.dart';
import '../models/daily_dua_model.dart';

class DuaContentWidget extends StatelessWidget {
  final DailyDua dua;
  final double screenHeight;
  final double Function(double) getResponsiveFontSize;

  const DuaContentWidget({
    Key? key,
    required this.dua,
    required this.screenHeight,
    required this.getResponsiveFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          dua.title,
          style: TextStyle(
            fontSize: getResponsiveFontSize(22),
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenHeight * 0.015),
        Text(
          dua.arabic,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getResponsiveFontSize(18),
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Text(
          dua.english,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getResponsiveFontSize(13),
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
