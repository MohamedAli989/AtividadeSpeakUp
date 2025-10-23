// lib/services/content_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/lesson.dart';
import '../models/phrase.dart';

class ContentService {
  Future<List<Lesson>> loadLessons() async {
    final data = await rootBundle.loadString('assets/data/lessons_data.json');
    final jsonMap = json.decode(data) as Map<String, dynamic>;
    final list = (jsonMap['lessons'] as List<dynamic>?) ?? [];
    return list.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Phrase>> loadPhrasesForLesson(String lessonId) async {
    final data = await rootBundle.loadString('assets/data/lessons_data.json');
    final jsonMap = json.decode(data) as Map<String, dynamic>;
    final list = (jsonMap['phrases'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Phrase.fromJson(e as Map<String, dynamic>))
        .where((p) => p.lessonId == lessonId)
        .toList();
  }
}
