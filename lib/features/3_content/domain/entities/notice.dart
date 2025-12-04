// lib/features/3_content/domain/entities/notice.dart
class Notice {
  final String id;
  final String title;
  final String language;
  final String description;
  final DateTime date;

  const Notice({
    required this.id,
    required this.title,
    required this.language,
    required this.description,
    required this.date,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String? ?? (json['docId'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      language: json['language'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date:
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          (json['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'language': language,
    'description': description,
    'date': date.toIso8601String(),
  };
}
