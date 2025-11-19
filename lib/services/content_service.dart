// lib/services/content_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';
import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';
import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/entities/daily_challenge.dart';

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

  /// Load modules filtered by `languageId` (ordered by `order`).
  Future<List<Module>> loadModules(String languageId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('modules')
          .where('languageId', isEqualTo: languageId)
          .orderBy('order')
          .get();
      return snap.docs
          .map((d) => Module.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      final data = await rootBundle.loadString('assets/data/lessons_data.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      final list = (jsonMap['modules'] as List<dynamic>?) ?? [];
      return list
          .map((e) => Module.fromJson(e as Map<String, dynamic>))
          .where((m) => m.languageId == languageId)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    }
  }

  /// Load lessons that belong to a specific module.
  Future<List<Lesson>> loadLessonsForModule(String moduleId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('lessons')
          .where('moduleId', isEqualTo: moduleId)
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
          .where((l) => l.moduleId == moduleId)
          .toList();
    }
  }

  /// Load phrases for a given lesson. Tries Firestore, falls back to bundled
  /// asset JSON.
  Future<List<Phrase>> loadPhrasesForLesson(String lessonId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('phrases')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      return snap.docs
          .map((d) => Phrase.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      final data = await rootBundle.loadString('assets/data/lessons_data.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      final list = (jsonMap['phrases'] as List<dynamic>?) ?? [];
      return list
          .map((e) => Phrase.fromJson(e as Map<String, dynamic>))
          .where((p) => p.lessonId == lessonId)
          .toList();
    }
  }

  /// Get today's challenge for a given language, or null if none.
  Future<DailyChallenge?> getTodaysChallenge(String languageId) async {
    try {
      // Build a UTC start and end timestamp for today and query by the
      // Timestamp field named 'date'. This avoids relying on string fields.
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day);
      final startOfNextDay = startOfDay.add(const Duration(days: 1));

      final snap = await FirebaseFirestore.instance
          .collection('daily_challenges')
          .where('languageId', isEqualTo: languageId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(startOfNextDay))
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return DailyChallenge.fromJson({'id': d.id, ...d.data()});
    } catch (_) {
      // Fallback: try to read from bundled asset. Accept either 'dateStr'
      // (YYYY-MM-DD) or 'date' string to maximize compatibility with older
      // asset formats.
      try {
        final data = await rootBundle.loadString(
          'assets/data/lessons_data.json',
        );
        final jsonMap = json.decode(data) as Map<String, dynamic>;
        final list = (jsonMap['daily_challenges'] as List<dynamic>?) ?? [];
        final today = DateTime.now();
        final dateStr =
            '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final found = list.cast<Map<String, dynamic>?>().firstWhere(
          (e) =>
              e != null &&
              (e['languageId'] as String? ?? '') == languageId &&
              ((e['dateStr'] as String? ?? '') == dateStr ||
                  (e['date'] as String? ?? '') == dateStr),
          orElse: () => null,
        );
        if (found == null) return null;
        return DailyChallenge.fromJson(found);
      } catch (_) {
        return null;
      }
    }
  }
}
