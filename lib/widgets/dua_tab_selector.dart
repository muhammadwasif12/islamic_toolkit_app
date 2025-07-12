import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_toolkit_app/view_model/duas_category_provider.dart';

class DuaTabSelector extends ConsumerWidget {
  const DuaTabSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => ref.read(selectedTabProvider.notifier).state = 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selectedTab == 0 ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: selectedTab == 0 ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'All Duas',
                  style: GoogleFonts.roboto(
                    color: selectedTab == 0 ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selectedTab == 1 ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: selectedTab == 1 ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'My Favorites',
                  style: GoogleFonts.roboto(
                    color: selectedTab == 1 ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
