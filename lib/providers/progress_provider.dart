import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/mistake_model.dart';
import '../models/unit_model.dart';
import '../services/api_service.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;
  final ApiService? _api;

  Map<int, int> _scores = {};
  Map<int, int> _writingScores = {};
  List<Mistake> _mistakes = [];
  bool _loaded = false;

  ProgressProvider(this._progressService, [this._api]);

  Map<int, int> get scores => _scores;
  Map<int, int> get writingScores => _writingScores;
  List<Mistake> get mistakes => _mistakes;
  bool get loaded => _loaded;

  Future<void> loadProgress() async {
    _scores = await _progressService.getAllScores();
    _writingScores = await _progressService.getAllWritingScores();
    _mistakes = await _progressService.getMistakes();
    _loaded = true;
    notifyListeners();

    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        final remote = await api.fetchProgress();
        final remoteScores = _parseIntMap(remote['scores']);
        final remoteWriting = _parseIntMap(remote['writingScores']);
        final remoteMistakes = ((remote['mistakes'] as List?) ?? const [])
            .map((e) => Mistake.fromJson(e as Map<String, dynamic>))
            .toList();
        _scores = remoteScores;
        _writingScores = remoteWriting;
        _mistakes = remoteMistakes;
        notifyListeners();
      } catch (_) {
        // Keep local values when the server is unreachable.
      }
    }
  }

  Map<int, int> _parseIntMap(dynamic value) {
    final map = <int, int>{};
    if (value is Map) {
      value.forEach((key, val) {
        final unit = int.tryParse('$key');
        if (unit != null && val is num) map[unit] = val.toInt();
      });
    }
    return map;
  }

  int getBestScore(int unitNumber) {
    return _scores[unitNumber] ?? 0;
  }

  int getWritingBestScore(int unitNumber) {
    return _writingScores[unitNumber] ?? 0;
  }

  bool canOpenUnit(int unitNumber) {
    if (unitNumber == 1) return true;
    return getBestScore(unitNumber - 1) >= AppConstants.passThreshold;
  }

  Future<void> updateScore(int unitNumber, int score) async {
    await _progressService.saveBestScore(unitNumber, score);
    final current = _scores[unitNumber] ?? 0;
    if (score > current) {
      _scores[unitNumber] = score;
      notifyListeners();
    }
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        await api.saveScore(unitNumber, score);
      } catch (_) {}
    }
  }

  Future<void> updateWritingScore(int unitNumber, int score) async {
    await _progressService.saveWritingBestScore(unitNumber, score);
    final current = _writingScores[unitNumber] ?? 0;
    if (score > current) {
      _writingScores[unitNumber] = score;
      notifyListeners();
    }
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        await api.saveWritingScore(unitNumber, score);
      } catch (_) {}
    }
  }

  Future<void> resetProgress() async {
    await _progressService.resetAllProgress();
    await _progressService.clearMistakes();
    _scores = {};
    _writingScores = {};
    _mistakes = [];
    notifyListeners();
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        await api.resetProgress();
      } catch (_) {}
    }
  }

  Future<void> recordMistakes(List<Mistake> mistakes) async {
    await _progressService.addMistakes(mistakes);
    _mistakes = await _progressService.getMistakes();
    notifyListeners();
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        await api.saveMistakes(_mistakes);
      } catch (_) {}
    }
  }

  Future<void> clearMistakes() async {
    await _progressService.clearMistakes();
    _mistakes = [];
    notifyListeners();
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        await api.saveMistakes([]);
      } catch (_) {}
    }
  }

  void applyScoreToUnit(Unit unit) {
    final score = _scores[unit.unitNumber] ?? 0;
    unit.bestScore = score;
    unit.writingBestScore = _writingScores[unit.unitNumber] ?? 0;
    unit.completed = score >= AppConstants.passThreshold;
    unit.locked = !canOpenUnit(unit.unitNumber);
  }
}
