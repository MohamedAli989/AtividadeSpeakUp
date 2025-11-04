// lib/models/language.dart
class Language {
  final String id;
  final String name;
  final String flagEmoji;

  const Language({
    required this.id,
    required this.name,
    required this.flagEmoji,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String,
      name: json['name'] as String,
      flagEmoji: json['flagEmoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'flagEmoji': flagEmoji};
  }
}
