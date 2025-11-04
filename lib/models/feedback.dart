// lib/models/feedback.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String practiceAttemptId;
  final double overallScore;
  final double fluencyScore;
  final double accuracyScore;
  final DateTime timestamp;

  const FeedbackModel({
    required this.id,
    required this.practiceAttemptId,
    required this.overallScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.timestamp,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
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

    return FeedbackModel(
      id: json['id'] as String,
      practiceAttemptId: json['practiceAttemptId'] as String,
      overallScore: (json['overallScore'] as num).toDouble(),
      fluencyScore: (json['fluencyScore'] as num).toDouble(),
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      timestamp: dt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'practiceAttemptId': practiceAttemptId,
      'overallScore': overallScore,
      'fluencyScore': fluencyScore,
      'accuracyScore': accuracyScore,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
