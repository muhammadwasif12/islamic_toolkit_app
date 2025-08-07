import 'package:flutter/material.dart';

class FallbackDuaWidget extends StatelessWidget {
  final double screenHeight;
  final double Function(double) getResponsiveFontSize;

  const FallbackDuaWidget({
    Key? key,
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
          'الأذكار المفضلة',
          style: TextStyle(
            fontSize: getResponsiveFontSize(22),
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.015),
        Text(
          ' "لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ،\nلَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ،\nوَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ"',
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
          'يقول ﷺ: أحبُّ الكلام إلى الله أربع: سبحان الله،\n والحمد لله، ولا إله إلا الله، والله أكبر.\n ويقول: الباقيات الصالحات: سبحان الله،\n والحمد لله، ولا إله إلا الله، والله أكبر،\n ولا حول ولا قوة إلا بالله',
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
