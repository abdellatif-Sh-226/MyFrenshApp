import '../core/constants/app_constants.dart';
import 'question_model.dart';

class Unit {
  final int unitNumber;
  final String difficulty;
  final List<Question> questions;
  int bestScore;
  int writingBestScore;
  bool completed;
  bool locked;

  Unit({
    required this.unitNumber,
    required this.difficulty,
    required this.questions,
    this.bestScore = 0,
    this.writingBestScore = 0,
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

  int get quizStars => Unit.starsForScore(bestScore);

  int get writingStars => Unit.starsForScore(writingBestScore);

  static int starsForScore(int score) {
    if (score >= AppConstants.starThreeMin) return 3;
    if (score >= AppConstants.starTwoMin) return 2;
    if (score >= AppConstants.starOneMin) return 1;
    return 0;
  }
}
