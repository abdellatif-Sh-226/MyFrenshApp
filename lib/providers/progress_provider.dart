import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/mistake_model.dart';
import '../models/unit_model.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;
  Map<int, int> _scores = {};
  Map<int, int> _writingScores = {};
  List<Mistake> _mistakes = [];
  bool _loaded = false;

  ProgressProvider(this._progressService);

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
  }

  Future<void> updateWritingScore(int unitNumber, int score) async {
    await _progressService.saveWritingBestScore(unitNumber, score);
    final current = _writingScores[unitNumber] ?? 0;
    if (score > current) {
      _writingScores[unitNumber] = score;
      notifyListeners();
    }
  }

  Future<void> resetProgress() async {
    await _progressService.resetAllProgress();
    await _progressService.clearMistakes();
    _scores = {};
    _writingScores = {};
    _mistakes = [];
    notifyListeners();
  }

  Future<void> recordMistakes(List<Mistake> mistakes) async {
    await _progressService.addMistakes(mistakes);
    _mistakes = await _progressService.getMistakes();
    notifyListeners();
  }

  Future<void> clearMistakes() async {
    await _progressService.clearMistakes();
    _mistakes = [];
    notifyListeners();
  }

  void applyScoreToUnit(Unit unit) {
    final score = _scores[unit.unitNumber] ?? 0;
    unit.bestScore = score;
    unit.writingBestScore = _writingScores[unit.unitNumber] ?? 0;
    unit.completed = score >= AppConstants.passThreshold;
    unit.locked = !canOpenUnit(unit.unitNumber);
  }
}
