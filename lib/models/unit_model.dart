import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'question_model.dart';

enum UnitCategory {
  noms,
  verbes,
  phrases;

  static UnitCategory fromString(String? value) {
    switch (value) {
      case 'verbes':
        return UnitCategory.verbes;
      case 'phrases':
        return UnitCategory.phrases;
      case 'noms':
      default:
        return UnitCategory.noms;
    }
  }

  String get label {
    switch (this) {
      case UnitCategory.noms:
        return 'Les Noms';
      case UnitCategory.verbes:
        return 'Les Verbes';
      case UnitCategory.phrases:
        return 'Les Phrases';
    }
  }

  String get labelSingular {
    switch (this) {
      case UnitCategory.noms:
        return 'Nom';
      case UnitCategory.verbes:
        return 'Verbe';
      case UnitCategory.phrases:
        return 'Phrase';
    }
  }

  IconData get icon {
    switch (this) {
      case UnitCategory.noms:
        return Icons.category_outlined;
      case UnitCategory.verbes:
        return Icons.directions_run;
      case UnitCategory.phrases:
        return Icons.forum_outlined;
    }
  }
}

class Unit {
  final int unitNumber;
  final String title;
  final UnitCategory category;
  final String difficulty;
  final int order;
  final List<int> prerequisites;
  final List<Question> questions;
  int bestScore;
  int writingBestScore;
  bool completed;
  bool locked;

  Unit({
    required this.unitNumber,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.order,
    required this.prerequisites,
    required this.questions,
    this.bestScore = 0,
    this.writingBestScore = 0,
    this.completed = false,
    this.locked = false,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitNumber: (json['unitNumber'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      category: UnitCategory.fromString(json['category'] as String?),
      difficulty: json['difficulty'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 1,
      prerequisites: ((json['prerequisites'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      questions: ((json['questions'] as List?) ?? const [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isPhrase => category == UnitCategory.phrases;

  String get displayTitle {
    if (title.isNotEmpty) return title;
    return 'Unit $unitNumber';
  }

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
