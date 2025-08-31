import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_toolkit_app/view_model/language_provider.dart';
import 'package:islamic_toolkit_app/utils/app_rebuilder.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLanguageProvider);
    final languages = ["English", "Arabic", "Farsi", "Urdu"];
    final localeMap = {
      "English": const Locale('en'),
      "Arabic": const Locale('ar'),
      "Farsi": const Locale('fa'),
      "Urdu": const Locale('ur'),
    };

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70),
              bottomLeft: Radius.circular(70),
            ),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "change_language".tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xffFDFCF7),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.6,
              ),
              itemBuilder: (_, index) {
                final lang = languages[index];
                final isSelected = selected == lang;

                return GestureDetector(
                  onTap: () async {
                    ref.read(selectedLanguageProvider.notifier).state = lang;
                    await context.setLocale(localeMap[lang]!);

                    //  Rebuild the entire app
                    AppRebuilder.of(context)?.rebuildApp();
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.amber[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        lang,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
