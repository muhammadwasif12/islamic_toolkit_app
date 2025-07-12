import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_toolkit_app/models/dua_category_model.dart';
import 'package:islamic_toolkit_app/views/dua_detail_screen.dart';

class CategoryDuaListScreen extends StatelessWidget {
  final DuaCategory category;

  const CategoryDuaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final duas = category.duas;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
        centerTitle: true,
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(60),
            bottomLeft: Radius.circular(60),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: duas.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final dua = duas[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DuaDetailScreen(dua: dua,currentIndex: index,totalCount: category.duas.length,),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dua.title,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua.latin,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
