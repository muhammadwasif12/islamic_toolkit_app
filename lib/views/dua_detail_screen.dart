import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_toolkit_app/models/dua_category_model.dart';
import 'package:islamic_toolkit_app/view_model/duas_category_provider.dart';
import 'package:islamic_toolkit_app/widgets/dua_progress_indicator.dart';
import 'package:islamic_toolkit_app/widgets/banner_ad_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class DuaDetailScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final DuaCategory category;

  const DuaDetailScreen({
    super.key,
    required this.initialIndex,
    required this.category,
  });

  @override
  ConsumerState<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends ConsumerState<DuaDetailScreen> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigateToPrevious() {
    if (currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void navigateToNext() {
    if (currentIndex < widget.category.duas.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDua = widget.category.duas[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          currentDua.title,
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Progress Bar
              DuaProgressIndicator(
                currentIndex: currentIndex,
                totalCount: widget.category.duas.length,
              ),

              // PageView for duas - bottom padding add kiya hai banner ad ke liye
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemCount: widget.category.duas.length,
                  itemBuilder: (context, index) {
                    final dua = widget.category.duas[index];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Dua Content
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dua.title,
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dua.arabic,
                                    style: GoogleFonts.amiri(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.8,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  dua.latin,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  dua.translation,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'reference'.tr(),
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.book,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dua.source,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Navigation Buttons
                          Row(
                            children: [
                              // Previous Button
                              Expanded(
                                child: Container(
                                  height: 38,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        currentIndex > 0
                                            ? navigateToPrevious
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          currentIndex > 0
                                              ? Colors.red
                                              : Colors.grey[300],
                                      foregroundColor:
                                          currentIndex > 0
                                              ? Colors.white
                                              : Colors.grey[700],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chevron_left,
                                          color:
                                              currentIndex > 0
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'previous'.tr(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Next Button
                              Expanded(
                                child: Container(
                                  height: 38,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        currentIndex <
                                                widget.category.duas.length - 1
                                            ? navigateToNext
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          currentIndex <
                                                  widget.category.duas.length -
                                                      1
                                              ? Colors.green
                                              : Colors.grey[300],
                                      foregroundColor:
                                          currentIndex <
                                                  widget.category.duas.length -
                                                      1
                                              ? Colors.white
                                              : Colors.grey[700],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'next'.tr(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          color:
                                              currentIndex <
                                                      widget
                                                              .category
                                                              .duas
                                                              .length -
                                                          1
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Extra bottom padding banner ad ke liye space dene ke liye
                          const SizedBox(
                            height: 80,
                          ), // Banner ad height + padding
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: const DuaDetailBannerAd(),
            ),
          ),
        ],
      ),

      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60), // Banner ad ke upar margin
        child: Consumer(
          builder: (context, ref, _) {
            final isFavorite = ref
                .watch(favoriteDuasProvider)
                .contains(currentDua.id);

            return FloatingActionButton(
              onPressed: () {
                final isNowFavorite =
                    !ref.read(favoriteDuasProvider).contains(currentDua.id);
                ref
                    .read(favoriteDuasProvider.notifier)
                    .toggleFavorite(currentDua.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isNowFavorite
                          ? 'add_to_favorites'.tr()
                          : 'remove_from_favorites'.tr(),
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                    backgroundColor:
                        isNowFavorite ? const Color(0xFF4CAF50) : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: isFavorite ? Colors.red : Colors.grey[400],
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
