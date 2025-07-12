class Dua {
  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String notes;
  final String fawaid;
  final String source;

  Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.notes,
    required this.fawaid,
    required this.source,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['translation'] ?? '',
      notes: json['notes'] ?? '',
      fawaid: json['fawaid'] ?? json['benefits'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
