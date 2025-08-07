import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/view_model/duas_category_provider.dart';
import 'package:islamic_toolkit_app/models/dua_model.dart';
import 'package:islamic_toolkit_app/views/dua_detail_screen.dart';
import 'package:islamic_toolkit_app/views/category_dua_list_screen.dart';
import 'package:islamic_toolkit_app/models/dua_category_model.dart';
import 'package:islamic_toolkit_app/widgets/dua_tab_selector.dart';
import '../widgets/custom_app_bar.dart';

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final favorites = ref.watch(favoriteDuasProvider);

    return Scaffold(
      appBar: CustomAppBar(title: "all_duas".tr()),
      backgroundColor: const Color(0xffFDFCF7),
      body: SafeArea(
        child: Column(
          children: [
            const DuaTabSelector(),
            Expanded(
              child: categoriesAsync.when(
                data:
                    (categories) =>
                        selectedTab == 0
                            ? _buildAllDuasTab(categories, context, ref)
                            : _buildFavoritesTab(
                              categories,
                              favorites,
                              context,
                            ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDuasTab(
    List<DuaCategory> categories,
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CategoryDuaListScreen(category: category),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.folder_open,
                            color: Color.fromRGBO(62, 180, 137, 1),
                            size: 24,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${category.subCategoriesCount} ${'sub_categories'.tr()}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${category.duasCount}',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'duas'.tr(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(
    List<DuaCategory> categories,
    List<String> favorites,
    BuildContext context,
  ) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'no_favorites_yet'.tr(),
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Create a special category for favorites with navigation support
    List<Dua> favoriteDuas = [];
    Map<String, int> duaToOriginalIndex = {};
    Map<String, DuaCategory> duaToCategory = {};

    for (var category in categories) {
      for (int i = 0; i < category.duas.length; i++) {
        var dua = category.duas[i];
        if (favorites.contains(dua.id)) {
          favoriteDuas.add(dua);
          duaToOriginalIndex[dua.id] = i;
          duaToCategory[dua.id] = category;
        }
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: favoriteDuas.length,
      itemBuilder: (context, index) {
        final dua = favoriteDuas[index];
        final originalCategory = duaToCategory[dua.id]!;
        final originalIndex = duaToOriginalIndex[dua.id]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              // Navigate to the original category's dua detail screen
              // This allows navigation between all duas in that category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DuaDetailScreen(
                        initialIndex: originalIndex,
                        category: originalCategory,
                      ),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              dua.title,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua.latin,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'from_category'.tr() + ': ${originalCategory.name.tr()}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.favorite, color: Colors.red),
          ),
        );
      },
    );
  }
}
