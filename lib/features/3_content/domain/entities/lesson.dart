// lib/features/3_content/domain/entities/lesson.dart
class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String languageId;
  final String moduleId;

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.languageId,
    required this.moduleId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      languageId: json['languageId'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'languageId': languageId,
      'moduleId': moduleId,
    };
  }
}
