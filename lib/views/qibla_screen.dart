import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: const CustomAppBar(title: "Qibla Direction"),
      backgroundColor: const Color(0xffFDFCF7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: GestureDetector(
                onTap: () => _showSurahBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/qibla_images/Al-Fatihah.png',
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    semanticLabel: 'Surah Al-Fatihah Image',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/qibla_images/campus.png',
                  height: 300,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'Qibla compass image',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFe8f5e9), Color(0xFFc8e6c9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "سورة الفاتحة",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Mycustomfont',
                            color: Color(0xFFB7935F),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n"
                            "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n"
                            "الرَّحْمَٰنِ الرَّحِيمِ\n"
                            "مَالِكِ يَوْمِ الدِّينِ\n"
                            "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n"
                            "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n"
                            "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ "
                            "غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Mycustomfont',
                              height: 2,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
