import 'package:islamic_toolkit_app/models/dua_model.dart';

class DuaCategory {
  final String name;
  final List<Dua> duas;

  DuaCategory({required this.name, required this.duas});

  factory DuaCategory.fromJson(String name, List<dynamic> list) {
    return DuaCategory(
      name: name,
      duas: list.map((e) => Dua.fromJson(e)).toList(),
    );
  }

  int get subCategoriesCount => duas.length;
  int get duasCount => duas.length;
}
