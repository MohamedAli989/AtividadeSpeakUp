// lib/features/3_content/domain/entities/phrase.dart
class Phrase {
  final String id;
  final String text;
  final String lessonId;

  Phrase({required this.id, required this.text, required this.lessonId});

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      id: json['id'] as String,
      text: json['text'] as String,
      lessonId: json['lessonId'] as String,
    );
  }
}
