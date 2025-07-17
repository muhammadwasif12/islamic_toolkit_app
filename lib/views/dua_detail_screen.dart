import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_toolkit_app/models/dua_model.dart';
import 'package:islamic_toolkit_app/view_model/duas_category_provider.dart';
import 'package:islamic_toolkit_app/widgets/dua_progress_indicator.dart';
import 'package:easy_localization/easy_localization.dart'; // Make sure this is imported

class DuaDetailScreen extends ConsumerWidget {
  final int currentIndex;
  final int totalCount;
  final Dua dua;

  const DuaDetailScreen({
    super.key,
    required this.dua,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          dua.title,
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [Icon(Icons.more_vert, color: Colors.black)],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Progress Bar
            DuaProgressIndicator(
              currentIndex: currentIndex,
              totalCount: totalCount,
            ),

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
                            borderRadius: BorderRadius.circular(4),
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

            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final isFavorite = ref.watch(favoriteDuasProvider).contains(dua.id);

          return FloatingActionButton(
            onPressed: () {
              final isNowFavorite =
                  !ref.read(favoriteDuasProvider).contains(dua.id);
              ref.read(favoriteDuasProvider.notifier).toggleFavorite(dua.id);

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
    );
  }
}
