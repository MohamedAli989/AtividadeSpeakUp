// lib/models/user_progress.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final int totalXp;
  final int currentStreak;
  final DateTime lastPracticeDate;
  final List<String> completedLessonIds;
  final List<String> achievedAchievementIds;
  final List<String> completedChallengeIds;

  const UserProgress({
    required this.userId,
    required this.totalXp,
    required this.currentStreak,
    required this.lastPracticeDate,
    required this.completedLessonIds,
    required this.achievedAchievementIds,
    required this.completedChallengeIds,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final ts = json['lastPracticeDate'];
    DateTime dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      dt = DateTime.parse(ts);
    } else {
      dt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    final list =
        (json['completedLessonIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        <String>[];
    final achievements =
        (json['achievedAchievementIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        <String>[];
    final challenges =
        (json['completedChallengeIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        <String>[];

    return UserProgress(
      userId: json['userId'] as String,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      lastPracticeDate: dt,
      completedLessonIds: list,
      achievedAchievementIds: achievements,
      completedChallengeIds: challenges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'lastPracticeDate': Timestamp.fromDate(lastPracticeDate),
      'completedLessonIds': completedLessonIds,
      'achievedAchievementIds': achievedAchievementIds,
      'completedChallengeIds': completedChallengeIds,
    };
  }

  UserProgress copyWith({
    String? userId,
    int? totalXp,
    int? currentStreak,
    DateTime? lastPracticeDate,
    List<String>? completedLessonIds,
    List<String>? achievedAchievementIds,
    List<String>? completedChallengeIds,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      achievedAchievementIds:
          achievedAchievementIds ?? this.achievedAchievementIds,
      completedChallengeIds:
          completedChallengeIds ?? this.completedChallengeIds,
    );
  }
}
