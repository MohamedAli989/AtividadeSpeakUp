// lib/services/content_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import '../models/phrase.dart';
import '../models/language.dart';

class ContentService {
  /// Load languages from Firestore 'languages' collection.
  /// Returns an empty list if the query fails.
  Future<List<Language>> loadLanguages() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('languages')
          .get();
      return snap.docs
          .map((d) => Language.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      // Fallback to bundled asset if Firestore is not available / on error.
      final data = await rootBundle.loadString('assets/data/lessons_data.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      final list = (jsonMap['languages'] as List<dynamic>?) ?? [];
      return list
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  /// Load lessons filtered by `languageId`.
  /// This will try Firestore first; on failure it will fall back to bundled data.
  Future<List<Lesson>> loadLessons(String languageId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('lessons')
          .where('languageId', isEqualTo: languageId)
          .get();
      return snap.docs
          .map((d) => Lesson.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      final data = await rootBundle.loadString('assets/data/lessons_data.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      final list = (jsonMap['lessons'] as List<dynamic>?) ?? [];
      return list
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .where((l) => l.languageId == languageId)
          .toList();
    }
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
