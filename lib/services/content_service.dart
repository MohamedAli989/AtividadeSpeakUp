// lib/services/content_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';
import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';
import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/entities/daily_challenge.dart';

class ContentService {
  final _supabase = Supabase.instance.client;

  /// Load languages from Firestore 'languages' collection.
  /// Returns an empty list if the query fails.
  Future<List<Language>> loadLanguages() async {
    try {
      final resp = await _supabase.from('languages').select();
      final list = (resp as List<dynamic>?) ?? [];
      return list
          .map((e) => Language.fromJson(Map<String, dynamic>.from(e as Map)))
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
      final resp = await _supabase
          .from('modules')
          .select()
          .eq('languageId', languageId)
          .order('order');
      final list = (resp as List<dynamic>?) ?? [];
      return list
          .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
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
      final resp = await _supabase
          .from('lessons')
          .select()
          .eq('moduleId', moduleId)
          .order('order');
      final list = (resp as List<dynamic>?) ?? [];
      return list
          .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
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
      final resp = await _supabase
          .from('phrases')
          .select()
          .eq('lessonId', lessonId);
      final list = (resp as List<dynamic>?) ?? [];
      return list
          .map((e) => Phrase.fromJson(Map<String, dynamic>.from(e as Map)))
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
      final today = DateTime.now();
      final dateStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final resp = await _supabase
          .from('daily_challenges')
          .select()
          .eq('languageId', languageId)
          .eq('dateStr', dateStr)
          .limit(1);
      final list = (resp as List<dynamic>?) ?? [];
      if (list.isEmpty) return null;
      return DailyChallenge.fromJson(
        Map<String, dynamic>.from(list.first as Map),
      );
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
