import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/mistake_model.dart';

class ProgressService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<int> getBestScore(int unitNumber) async {
    final key = '${AppConstants.prefsKeyPrefix}$unitNumber';
    return _prefs?.getInt(key) ?? 0;
  }

  Future<void> saveBestScore(int unitNumber, int score) async {
    final key = '${AppConstants.prefsKeyPrefix}$unitNumber';
    final current = await getBestScore(unitNumber);
    if (score > current) {
      await _prefs?.setInt(key, score);
    }
  }

  Future<Map<int, int>> getAllScores() async {
    final Map<int, int> scores = {};
    for (int i = 1; i <= AppConstants.totalUnits; i++) {
      scores[i] = await getBestScore(i);
    }
    return scores;
  }

  Future<void> resetAllProgress() async {
    for (int i = 1; i <= AppConstants.totalUnits; i++) {
      final key = '${AppConstants.prefsKeyPrefix}$i';
      await _prefs?.remove(key);
    }
  }

  Future<List<Mistake>> getMistakes() async {
    final raw = _prefs?.getString(AppConstants.mistakesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => Mistake.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addMistakes(List<Mistake> mistakes) async {
    if (mistakes.isEmpty) return;
    final existing = await getMistakes();
    final existingKeys =
        existing.map((m) => '${m.unitNumber}_${m.word}').toSet();
    final toAdd = mistakes
        .where((m) => !existingKeys.contains('${m.unitNumber}_${m.word}'))
        .toList();
    if (toAdd.isEmpty) return;
    final merged = [...toAdd, ...existing].take(100).toList();
    final encoded =
        json.encode(merged.map((m) => m.toJson()).toList());
    await _prefs?.setString(AppConstants.mistakesKey, encoded);
  }

  Future<void> clearMistakes() async {
    await _prefs?.remove(AppConstants.mistakesKey);
  }

  Future<bool> getDarkMode() async {
    return _prefs?.getBool(AppConstants.prefsDarkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(AppConstants.prefsDarkModeKey, value);
  }
}
