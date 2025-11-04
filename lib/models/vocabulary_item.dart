// lib/models/vocabulary_item.dart
class VocabularyItem {
  final String id;
  final String userId;
  final String word;
  final String translation;
  final String originalPhraseId;
  final String? audioUrl;

  const VocabularyItem({
    required this.id,
    required this.userId,
    required this.word,
    required this.translation,
    required this.originalPhraseId,
    this.audioUrl,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      originalPhraseId: json['originalPhraseId'] as String,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'word': word,
      'translation': translation,
      'originalPhraseId': originalPhraseId,
      'audioUrl': audioUrl,
    };
  }
}
