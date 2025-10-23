// lib/models/lesson.dart
class Lesson {
  final String id;
  final String title;
  final String subtitle;

  Lesson({required this.id, required this.title, required this.subtitle});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}
