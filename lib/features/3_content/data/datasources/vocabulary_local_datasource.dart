import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

class VocabularyLocalDataSource {
  final String keyPrefix;

  VocabularyLocalDataSource({this.keyPrefix = 'vocabulary_'});

  String _keyFor(String userId) => '$keyPrefix$userId';

  Future<List<VocabularyItem>> loadAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(userId));
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    return jsonList
        .map((e) => VocabularyItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveAll(String userId, List<VocabularyItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_keyFor(userId), raw);
  }
}
