class QuizResult {
  final int unitNumber;
  final int score;
  final int totalQuestions;
  final List<bool> answers;

  QuizResult({
    required this.unitNumber,
    required this.score,
    required this.totalQuestions,
    required this.answers,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0.0;

  String get performance {
    if (percentage >= 0.9) return 'Excellent';
    if (percentage >= 0.7) return 'Good';
    if (percentage >= 0.5) return 'Needs Practice';
    return 'Keep Trying';
  }

  int get stars {
    if (percentage >= 0.9) return 3;
    if (percentage >= 0.7) return 2;
    if (percentage >= 0.5) return 1;
    return 0;
  }

  bool get isNewBest => percentage >= 0.9;
  bool get isPerfect => score == totalQuestions;
}
