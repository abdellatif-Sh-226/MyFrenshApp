import '../core/constants/app_constants.dart';
import 'question_model.dart';

class Unit {
  final int unitNumber;
  final String difficulty;
  final List<Question> questions;
  int bestScore;
  bool completed;
  bool locked;

  Unit({
    required this.unitNumber,
    required this.difficulty,
    required this.questions,
    this.bestScore = 0,
    this.completed = false,
    this.locked = false,
  });

  int get totalQuestions => questions.length;

  String get progressStatus {
    if (bestScore == 0) return 'Not Attempted';
    if (bestScore >= AppConstants.passThreshold) return 'Completed';
    return 'In Progress';
  }

  double get progressPercentage => totalQuestions > 0 ? bestScore / totalQuestions : 0.0;
}
