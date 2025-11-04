// lib/models/lesson.dart
class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String languageId;

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.languageId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      languageId: json['languageId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'languageId': languageId,
    };
  }
}
