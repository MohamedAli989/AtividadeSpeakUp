// lib/models/practice_attempt.dart
// Removed Firestore dependency; timestamps handled as primitives

class PracticeAttempt {
  final String id;
  final String userId;
  final String phraseId;
  final String lessonId;
  final String audioUrl;
  final DateTime timestamp;

  const PracticeAttempt({
    required this.id,
    required this.userId,
    required this.phraseId,
    required this.lessonId,
    required this.audioUrl,
    required this.timestamp,
  });

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    DateTime dt;
    if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      dt = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }

    return PracticeAttempt(
      id: json['id'] as String,
      userId: json['userId'] as String,
      phraseId: json['phraseId'] as String,
      lessonId: json['lessonId'] as String,
      audioUrl: json['audioUrl'] as String,
      timestamp: dt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phraseId': phraseId,
      'lessonId': lessonId,
      'audioUrl': audioUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
