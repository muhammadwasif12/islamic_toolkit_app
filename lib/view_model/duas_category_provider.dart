import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/models/dua_model.dart';
import 'package:islamic_toolkit_app/models/dua_category_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

final favoriteDuasProvider =
    StateNotifierProvider<FavoriteDuasNotifier, List<String>>((ref) {
      return FavoriteDuasNotifier();
    });

class FavoriteDuasNotifier extends StateNotifier<List<String>> {
  FavoriteDuasNotifier() : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_duas') ?? [];
    state = [...saved];
  }

  void toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final updatedList = [...state];

    if (updatedList.contains(id)) {
      updatedList.remove(id);
    } else {
      updatedList.add(id);
    }

    await prefs.setStringList('favorite_duas', updatedList);
    state = updatedList;
  }
}

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/json/duas.json');
  final Map<String, dynamic> jsonData = json.decode(jsonStr);

  List<DuaCategory> categories = [];

  jsonData.forEach((categoryName, duasList) {
    if (duasList is List) {
      final duas =
          duasList.asMap().entries.map((entry) {
            final Map<String, dynamic> duaData = Map<String, dynamic>.from(
              entry.value,
            );
            final uniqueId = '${categoryName}_${entry.key}';
            return Dua.fromJson({'id': uniqueId, ...duaData});
          }).toList();

      categories.add(DuaCategory(name: categoryName, duas: duas));
    }
  });

  return categories;
});
