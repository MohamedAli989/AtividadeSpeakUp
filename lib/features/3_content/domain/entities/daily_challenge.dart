// lib/features/3_content/domain/entities/daily_challenge.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final String id;
  final DateTime date;
  final String title;
  final List<String> phraseIds;
  final int xpBonus;

  const DailyChallenge({
    required this.id,
    required this.date,
    required this.title,
    required this.phraseIds,
    required this.xpBonus,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final ts = json['date'];
    DateTime dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      dt = DateTime.parse(ts);
    } else {
      dt = DateTime.now();
    }

    final list =
        (json['phraseIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        <String>[];

    return DailyChallenge(
      id: json['id'] as String,
      date: dt,
      title: json['title'] as String? ?? '',
      phraseIds: list,
      xpBonus: (json['xpBonus'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'title': title,
      'phraseIds': phraseIds,
      'xpBonus': xpBonus,
    };
  }
}
