// widgets/dua_popup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class ContentPopupDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? type; // 'dua', 'hadees', or null for general

  const ContentPopupDialog({
    Key? key,
    required this.title,
    required this.content,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors and icons based on type
    Color primaryColor;
    Color gradientStart;
    Color gradientEnd;
    String iconPath;

    switch (type) {
      case 'dua':
        primaryColor = const Color.fromRGBO(76, 175, 80, 1);
        gradientStart = const Color.fromRGBO(76, 175, 80, 1);
        gradientEnd = const Color.fromRGBO(102, 187, 106, 1);
        iconPath = 'assets/bottom_nav_images/dua1.png'; // Use your dua icon
        break;
      case 'hadees':
        primaryColor = const Color.fromRGBO(33, 150, 243, 1);
        gradientStart = const Color.fromRGBO(33, 150, 243, 1);
        gradientEnd = const Color.fromRGBO(66, 165, 245, 1);
        iconPath = ''; // Use book icon for hadees
        break;
      default:
        primaryColor = const Color.fromRGBO(62, 180, 137, 1);
        gradientStart = const Color.fromRGBO(62, 180, 137, 1);
        gradientEnd = const Color.fromRGBO(81, 187, 149, 1);
        iconPath = '';
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Icon based on type
                  if (type == 'dua' && iconPath.isNotEmpty)
                    Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      color: Colors.white,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.handshake_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                    )
                  else
                    Icon(
                      type == 'hadees'
                          ? Icons.book_outlined
                          : Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic Text (if available)
                    if (arabicText != null && arabicText!.isNotEmpty) ...[
                      _buildSectionTitle("Arabic".tr(), Icons.language),
                      const SizedBox(height: 8),
                      _buildArabicText(arabicText!),
                      const SizedBox(height: 16),
                    ],

                    // Transliteration (if available)
                    if (transliteration != null &&
                        transliteration!.isNotEmpty) ...[
                      _buildSectionTitle(
                        "Transliteration".tr(),
                        Icons.text_fields,
                      ),
                      const SizedBox(height: 8),
                      _buildContentText(transliteration!),
                      const SizedBox(height: 16),
                    ],

                    // Translation or general content
                    if (translation != null && translation!.isNotEmpty) ...[
                      _buildSectionTitle("Translation".tr(), Icons.translate),
                      const SizedBox(height: 8),
                      _buildContentText(translation!),
                    ] else ...[
                      _buildContentText(content),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy),
                      label: Text("Copy".tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        "OK".tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildArabicText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 2.0,
          fontFamily: 'Arabic', // Use your Arabic font
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    String textToCopy = '';

    if (arabicText != null && arabicText!.isNotEmpty) {
      textToCopy += '$arabicText\n\n';
    }
    if (transliteration != null && transliteration!.isNotEmpty) {
      textToCopy += '$transliteration\n\n';
    }
    if (translation != null && translation!.isNotEmpty) {
      textToCopy += translation!;
    } else {
      textToCopy += content;
    }

    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied to clipboard".tr()),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}
