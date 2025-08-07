// Simple Dua model for daily dua
class DailyDua {
  final int index;
  final String title;
  final String english;
  final String arabic;

  DailyDua({
    required this.index,
    required this.title,
    required this.english,
    required this.arabic,
  });

  factory DailyDua.fromJson(Map<String, dynamic> json) {
    return DailyDua(
      index: json['index'] ?? 0,
      title: json['name'] ?? '',
      english: json['english'] ?? '',
      arabic: json['arabic'] ?? '',
    );
  }

  // Create a copy with ellipsed title
  DailyDua copyWithEllipsedTitle(String ellipsedTitle) {
    return DailyDua(
      index: index,
      title: ellipsedTitle,
      english: english,
      arabic: arabic,
    );
  }
}
